import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/form_action_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/labeled_text_field.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<CustomerProfileCubit>();
    final success = await cubit.updatePassword(_passwordController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          success
              ? 'Password berhasil diperbarui'
              : (cubit.state.errorMessage ?? 'Gagal memperbarui password.'),
        ),
      ));

    if (success) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            return Column(
              children: [
                const CustomerPageHeader(title: 'Ubah Password'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        LabeledTextField(
                          label: 'Password Baru',
                          controller: _passwordController,
                          hintText: 'Minimal 6 karakter',
                          isPassword: true,
                          enabled: !state.isSaving,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        LabeledTextField(
                          label: 'Konfirmasi Password',
                          controller: _confirmController,
                          hintText: 'Ulangi password baru',
                          isPassword: true,
                          enabled: !state.isSaving,
                          textInputAction: TextInputAction.done,
                          validator: (value) => value != _passwordController.text
                              ? 'Konfirmasi password tidak sama'
                              : null,
                        ),
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
