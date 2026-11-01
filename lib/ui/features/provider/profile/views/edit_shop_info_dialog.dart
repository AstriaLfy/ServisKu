import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class EditShopInfoDialog extends StatefulWidget {
  final ShopProfile shop;

  const EditShopInfoDialog({super.key, required this.shop});

  @override
  State<EditShopInfoDialog> createState() => _EditShopInfoDialogState();
}

class _EditShopInfoDialogState extends State<EditShopInfoDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _taglineController = TextEditingController(text: widget.shop.tagline ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopProfileBloc, ShopProfileState>(
      listener: (context, state) {
        if (state is ShopProfileSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profil Toko',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nama Toko / Usaha *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _nameController,
                hintText: 'Minimal 2 karakter',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tagline Toko',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _taglineController,
                hintText: 'Maks. 60 karakter (opsional)',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ShopProfileBloc, ShopProfileState>(
                builder: (context, state) {
                  final isSaving = state is ShopProfileSaving;
                  return CustomButton(
                    text: 'Simpan',
                    isLoading: isSaving,
                    onPressed: (_isValid && !isSaving)
                        ? () {
                            context.read<ShopProfileBloc>().add(
                                  ShopInfoUpdated(
                                    name: _nameController.text.trim(),
                                    tagline: _taglineController.text.trim(),
                                  ),
                                );
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
