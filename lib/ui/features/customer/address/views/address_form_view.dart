import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/phone_formatter.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_cubit.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_state.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_confirm_dialog.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/form_action_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/labeled_text_field.dart';

class AddressFormView extends StatefulWidget {
  final CustomerAddress? address;

  const AddressFormView({super.key, this.address});

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regionController;
  late final TextEditingController _detailController;
  late final TextEditingController _extraController;
  late final TextEditingController _labelController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mapController;

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _regionController = TextEditingController(text: address?.region);
    _detailController = TextEditingController(text: address?.detail);
    _extraController = TextEditingController(text: address?.extraDetail);
    _labelController = TextEditingController(text: address?.label);
    _phoneController = TextEditingController(text: address?.phone);
    _mapController = TextEditingController(text: address?.mapLocation);
  }

  @override
  void dispose() {
    _regionController.dispose();
    _detailController.dispose();
    _extraController.dispose();
    _labelController.dispose();
    _phoneController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? _optional(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _optional(_phoneController);
    final address = CustomerAddress(
      id: widget.address?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      region: _regionController.text.trim(),
      detail: _detailController.text.trim(),
      extraDetail: _optional(_extraController),
      phone: phone == null ? null : (PhoneFormatter.format(phone) ?? phone),
      mapLocation: _optional(_mapController),
    );

    final cubit = context.read<AddressCubit>();
    final success = _isEdit ? await cubit.edit(address) : await cubit.add(address);
    if (!mounted) return;

    if (success) {
      _showMessage(_isEdit ? 'Alamat berhasil diperbarui' : 'Alamat berhasil ditambahkan');
      context.pop();
    } else {
      _showMessage(cubit.state.errorMessage ?? 'Gagal menyimpan alamat.');
    }
  }

  Future<void> _delete() async {
    final address = widget.address;
    if (address == null) return;

    final confirmed = await showCustomerConfirmDialog(
      context,
      title: 'Hapus alamat ini?',
      message: 'Alamat "${address.label}" akan dihapus dari daftar.',
      cancelText: 'Batal',
      confirmText: 'Hapus',
    );
    if (!confirmed || !mounted) return;

    final cubit = context.read<AddressCubit>();
    final success = await cubit.remove(address.id);
    if (!mounted) return;

    if (success) {
      _showMessage('Alamat berhasil dihapus');
      context.pop();
    } else {
      _showMessage(cubit.state.errorMessage ?? 'Gagal menghapus alamat.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<AddressCubit, AddressState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            final enabled = !state.isSaving;

            return Column(
              children: [
                CustomerPageHeader(title: _isEdit ? 'Ubah Alamat' : 'Tambah Alamat'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        LabeledTextField(
                          label: 'Wilayah Administratif',
                          controller: _regionController,
                          hintText: 'Kelurahan, Kecamatan, Kota',
                          enabled: enabled,
                          validator: (value) => _required(value, 'Wilayah administratif'),
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Detail Alamat',
                          controller: _detailController,
                          hintText: 'Nama jalan dan nomor rumah',
                          keyboardType: TextInputType.streetAddress,
                          enabled: enabled,
                          validator: (value) => _required(value, 'Detail alamat'),
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Detail Tambahan',
                          controller: _extraController,
                          hintText: 'Patokan, blok, atau warna pagar (opsional)',
                          enabled: enabled,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Nama Alamat',
                          controller: _labelController,
                          hintText: 'Contoh: Rumah, Kantor',
                          keyboardType: TextInputType.text,
                          enabled: enabled,
                          validator: (value) => _required(value, 'Nama alamat'),
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Nomor Telepon',
                          controller: _phoneController,
                          hintText: '08xxxxxxxxxx',
                          keyboardType: TextInputType.phone,
                          enabled: enabled,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return null;
                            return PhoneFormatter.format(text) == null
                                ? 'Format nomor telepon tidak valid'
                                : null;
                          },
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Lokasi Peta',
                          controller: _mapController,
                          hintText: 'Tautan Google Maps (opsional)',
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          enabled: enabled,
                          prefixIcon: Icons.map_outlined,
                        ),
                        if (_isEdit) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: enabled ? _delete : null,
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                              label: const Text(
                                'Hapus alamat',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                FormActionBar(
                  confirmText: _isEdit ? 'Ubah' : 'Tambah',
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
