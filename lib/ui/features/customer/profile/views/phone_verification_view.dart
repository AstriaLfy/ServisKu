import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';

class PhoneVerificationView extends StatefulWidget {
  final String phone;

  const PhoneVerificationView({super.key, required this.phone});

  @override
  State<PhoneVerificationView> createState() => _PhoneVerificationViewState();
}

class _PhoneVerificationViewState extends State<PhoneVerificationView> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  bool get _isComplete => _otp.length == _otpLength;

  String get _formattedTimer {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resend() async {
    final cubit = context.read<CustomerProfileCubit>();
    final success = await cubit.resendPhoneOtp(widget.phone);
    if (!mounted) return;
    if (success) {
      _startTimer();
      _showMessage('Kode OTP telah dikirim ulang');
    } else {
      _showMessage(cubit.state.errorMessage ?? 'Gagal mengirim ulang kode.');
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<CustomerProfileCubit>();
    final success = await cubit.verifyPhone(phone: widget.phone, token: _otp);
    if (!mounted) return;

    if (success) {
      context.read<AuthBloc>().add(const UserProfileRefreshed());
      _showMessage('Nomor telepon berhasil diperbarui');
      context.pop();
    } else {
      _showMessage(cubit.state.errorMessage ?? 'Verifikasi gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            final canResend = _secondsRemaining == 0 && !state.isSaving;

            return Column(
              children: [
                const CustomerPageHeader(title: 'Verifikasi'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Text(
                        'OTP telah dikirimkan ke ${formatDisplayPhone(widget.phone)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formattedTimer,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_otpLength, (index) {
                          final isFocused = _focusNodes[index].hasFocus;
                          final isFilled = _controllers[index].text.isNotEmpty;

                          return Container(
                            width: 46,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFocused
                                    ? AppColors.primary
                                    : (isFilled ? const Color(0xFFBFDBFE) : Colors.transparent),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              enabled: !state.isSaving,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) => _onDigitChanged(index, value),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: GestureDetector(
                          onTap: canResend ? _resend : null,
                          child: Text(
                            _secondsRemaining > 0
                                ? 'Kirim ulang dalam ${_secondsRemaining}s'
                                : 'Kirim ulang kode?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              color: canResend
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: CustomButton(
                    text: 'Konfirmasi OTP',
                    height: 48,
                    isLoading: state.isSaving,
                    onPressed: _isComplete && !state.isSaving ? _verify : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
