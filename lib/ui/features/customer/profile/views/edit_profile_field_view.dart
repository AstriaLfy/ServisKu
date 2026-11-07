import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/utils/phone_formatter.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/form_action_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/labeled_text_field.dart';

class EditProfileFieldView extends StatefulWidget {
  final ProfileField field;

  const EditProfileFieldView({super.key, required this.field});

  @override
  State<EditProfileFieldView> createState() => _EditProfileFieldViewState();
}

class _EditProfileFieldViewState extends State<EditProfileFieldView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final profile = context.read<CustomerProfileCubit>().state.profile;
    _controller = TextEditingController(text: widget.field.valueOf(profile));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final field = widget.field;
    final value = _controller.text.trim();
    final cubit = context.read<CustomerProfileCubit>();
    final current = field.valueOf(cubit.state.profile);

    if (field == ProfileField.phone &&
        PhoneFormatter.format(value) == PhoneFormatter.format(current)) {
      context.pop();
      return;
    }

    if (field != ProfileField.phone && value == current.trim()) {
      context.pop();
      return;
    }

    final success = await cubit.updateField(field, value);
    if (!mounted) return;

    if (!success) {
      _showMessage(cubit.state.errorMessage ?? 'Gagal menyimpan perubahan.');
      return;
    }

    switch (field) {
      case ProfileField.name:
        context.read<AuthBloc>().add(UserProfileRefreshed(newFullName: value));
        _showMessage('Nama berhasil diperbarui');
        context.pop();
        break;
      case ProfileField.bio:
        _showMessage('Bio berhasil diperbarui');
        context.pop();
        break;
      case ProfileField.email:
        _showMessage('Link konfirmasi telah dikirim ke email baru kamu');
        context.pop();
        break;
      case ProfileField.phone:
        context.pushReplacement(
          '/customer/profile/verify-phone',
          extra: PhoneFormatter.format(value) ?? value,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            return Column(
              children: [
                CustomerPageHeader(title: field.title),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        LabeledTextField(
                          label: field.label,
                          controller: _controller,
                          hintText: field.hint,
                          keyboardType: field.keyboardType,
                          textInputAction: TextInputAction.done,
                          validator: field.validate,
                          enabled: !state.isSaving,
                        ),
                        if (field == ProfileField.phone) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Kode OTP akan dikirim ke nomor baru untuk verifikasi.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                        if (field == ProfileField.email) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Link konfirmasi akan dikirim ke email baru.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                FormActionBar(
                  confirmText: 'Ubah',
                  isLoading: state.isSaving,
                  onConfirm: _submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
