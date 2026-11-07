import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/phone_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _initialEmail = '';
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _initialPhone = authState.user.phone;
      _phoneController.text = _initialPhone;
    }
    final cubit = context.read<CustomerProfileCubit>();
    cubit.reset();
    cubit.load();
  }

  void _prefill(CustomerProfile profile) {
    _initialEmail = profile.email;
    _emailController.text = profile.email;
    if (profile.phone.isNotEmpty) {
      _initialPhone = profile.phone;
      _phoneController.text = profile.phone;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<CustomerProfileCubit>();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final emailChanged = email.isNotEmpty && email != _initialEmail;
    final phoneChanged = phone.isNotEmpty &&
        PhoneFormatter.format(phone) != PhoneFormatter.format(_initialPhone);
    final passwordChanged = password.isNotEmpty;

    if (!emailChanged && !phoneChanged && !passwordChanged) {
      _showMessage('Tidak ada perubahan untuk disimpan');
      return;
    }

    final messages = <String>[];

    if (passwordChanged) {
      final ok = await cubit.updatePassword(password);
      if (!mounted) return;
      if (!ok) {
        _showMessage(cubit.state.errorMessage ?? 'Gagal memperbarui password.');
        return;
      }
      _passwordController.clear();
      messages.add('Password diperbarui');
    }

    if (emailChanged) {
      final ok = await cubit.updateField(ProfileField.email, email);
      if (!mounted) return;
      if (!ok) {
        _showMessage(cubit.state.errorMessage ?? 'Gagal memperbarui email.');
        return;
      }
      _initialEmail = email;
      messages.add('Link konfirmasi dikirim ke email baru');
    }

    if (phoneChanged) {
      final ok = await cubit.updateField(ProfileField.phone, phone);
      if (!mounted) return;
      if (!ok) {
        _showMessage(cubit.state.errorMessage ?? 'Gagal mengirim kode OTP.');
        return;
      }
      if (messages.isNotEmpty) _showMessage(messages.join('. '));
      context.push(
        '/customer/profile/verify-phone',
        extra: PhoneFormatter.format(phone) ?? phone,
      );
      return;
    }

    _showMessage(messages.join('. '));
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<CustomerProfileCubit, CustomerProfileState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status && curr.status == ProfileStatus.loaded,
          listener: (context, state) => _prefill(state.profile),
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Akun',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Akun',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _label('Email'),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !state.isSaving,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                return ProfileField.email.validate(text);
                              },
                            ),
                            const SizedBox(height: 24),
                            _label('Phone Number'),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: 'Nomor Telepon',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              enabled: !state.isSaving,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                return ProfileField.phone.validate(text);
                              },
                            ),
                            const SizedBox(height: 24),
                            _label('Password'),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Kata Sandi',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              enabled: !state.isSaving,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                return value.length < 6 ? 'Password minimal 6 karakter' : null;
                              },
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Kosongkan password jika tidak ingin mengubahnya.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Simpan',
                    isLoading: state.isSaving,
                    onPressed: state.isSaving ? null : _save,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
