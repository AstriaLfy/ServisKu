import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/provider/services/bloc/services_bloc.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';
import 'package:servis_ku/ui/features/provider/services/views/service_photo.dart';

class ServiceAddView extends StatefulWidget {
  final ServiceItem? editItem;

  const ServiceAddView({super.key, this.editItem});

  @override
  State<ServiceAddView> createState() => _ServiceAddViewState();
}

class _ServiceAddViewState extends State<ServiceAddView> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  int? _selectedCategoryId;
  String? _photoFilePath;

  bool get _isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final item = widget.editItem!;
      _nameController.text = item.name;
      _priceController.text = CurrencyFormatter.formatDigits(item.price.toString());
      _selectedCategoryId = item.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final price = CurrencyFormatter.parseClean(_priceController.text);
    return _selectedCategoryId != null && name.isNotEmpty && price > 0;
  }

  void _onPriceChanged(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      _priceController.value = const TextEditingValue(text: '');
      setState(() {});
      return;
    }
    final formatted = CurrencyFormatter.formatDigits(clean);
    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (file == null || !mounted) return;
      setState(() => _photoFilePath = file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka galeri.')),
      );
    }
  }

  void _submit() {
    if (!_isFormValid) return;

    final name = _nameController.text.trim();
    final price = CurrencyFormatter.parseClean(_priceController.text);
    final categoryId = _selectedCategoryId!;

    if (_isEditMode) {
      context.read<ServicesBloc>().add(
            ServiceUpdated(
              id: widget.editItem!.id,
              categoryId: categoryId,
              name: name,
              price: price,
              photoFilePath: _photoFilePath,
              previousPhotoPath: widget.editItem!.photoPath,
            ),
          );
    } else {
      context.read<ServicesBloc>().add(
            ServiceCreated(
              categoryId: categoryId,
              name: name,
              price: price,
              photoFilePath: _photoFilePath,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state.actionStatus == ServiceActionStatus.success) {
          context.pop();
        } else if (state.actionStatus == ServiceActionStatus.failure &&
            state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final categories = state.categories;
        final isSaving = state.actionStatus == ServiceActionStatus.saving;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
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
                      Expanded(
                        child: Text(
                          _isEditMode ? 'Edit Layanan' : 'Tambah Layanan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ServicePhotoPicker(
                            imageUrl: widget.editItem?.photoUrl,
                            filePath: _photoFilePath,
                            onTap: isSaving ? null : _pickPhoto,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Kategori *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dropdown Kategori
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedCategoryId,
                                hint: const Text(
                                  'Pilih Kategori',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Color(0xFF6B7280)),
                                items: categories.map((cat) {
                                  return DropdownMenuItem<int>(
                                    value: cat.id,
                                    child: Text(
                                      cat.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCategoryId = val;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Nama Layanan *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Contoh: Packing Barang',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Harga *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                  ),
                                  child: const Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    onChanged: _onPriceChanged,
                                    decoration: const InputDecoration(
                                      hintText: 'Contoh: 100.000',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 15,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  CustomButton(
                    text: 'Simpan',
                    isLoading: isSaving,
                    onPressed: (_isFormValid && !isSaving) ? _submit : null,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
