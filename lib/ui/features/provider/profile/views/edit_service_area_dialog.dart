import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class EditServiceAreaDialog extends StatefulWidget {
  final ShopProfile shop;

  const EditServiceAreaDialog({super.key, required this.shop});

  @override
  State<EditServiceAreaDialog> createState() => _EditServiceAreaDialogState();
}

class _EditServiceAreaDialogState extends State<EditServiceAreaDialog> {
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController(text: widget.shop.serviceArea ?? '');
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

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
                    'Edit Area Layanan',
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
                'Area Layanan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _areaController,
                hintText: 'Contoh: Malang, Batu, dan sekitarnya (maks. 100 karakter)',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ShopProfileBloc, ShopProfileState>(
                builder: (context, state) {
                  final isSaving = state is ShopProfileSaving;
                  return CustomButton(
                    text: 'Simpan',
                    isLoading: isSaving,
                    onPressed: isSaving
                        ? null
                        : () {
                            context.read<ShopProfileBloc>().add(
                                  ShopInfoUpdated(
                                    serviceArea: _areaController.text.trim(),
                                  ),
                                );
                          },
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
