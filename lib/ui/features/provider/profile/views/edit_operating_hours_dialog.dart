import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/operating_hours_helper.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class EditOperatingHoursDialog extends StatefulWidget {
  final ShopProfile shop;

  const EditOperatingHoursDialog({super.key, required this.shop});

  @override
  State<EditOperatingHoursDialog> createState() => _EditOperatingHoursDialogState();
}

class _EditOperatingHoursDialogState extends State<EditOperatingHoursDialog> {
  late List<OperatingHour> _hours;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inisialisasi 7 hari (Senin=1 ... Minggu=7)
    final existingMap = {for (final h in widget.shop.hours) h.dayOfWeek: h};
    _hours = List.generate(7, (i) {
      final day = i + 1;
      return existingMap[day] ??
          OperatingHour(
            dayOfWeek: day,
            openTime: '08:00:00',
            closeTime: '17:00:00',
            isClosed: day == 7, // Default minggu tutup jika kosong
          );
    });
  }

  Future<void> _pickTime(int index, bool isOpenTime) async {
    final currentStr = isOpenTime ? _hours[index].openTime : _hours[index].closeTime;
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);

    if (currentStr != null && currentStr.isNotEmpty) {
      final parts = currentStr.replaceAll('.', ':').split(':');
      if (parts.length >= 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      setState(() {
        if (isOpenTime) {
          _hours[index] = _hours[index].copyWith(openTime: formatted);
        } else {
          _hours[index] = _hours[index].copyWith(closeTime: formatted);
        }
        _validate();
      });
    }
  }

  bool _validate() {
    for (final h in _hours) {
      if (!h.isClosed) {
        final openSec = _parseSeconds(h.openTime);
        final closeSec = _parseSeconds(h.closeTime);
        if (openSec >= closeSec) {
          _errorMessage =
              'Jam buka harus lebih awal dari jam tutup (${OperatingHour.dayName(h.dayOfWeek)})';
          return false;
        }
      }
    }
    _errorMessage = null;
    return true;
  }

  int _parseSeconds(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 0;
    final parts = timeStr.replaceAll('.', ':').split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 3600 + m * 60;
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    'Edit Jam Operasional',
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
              const SizedBox(height: 8),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _hours.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final h = _hours[index];
                    return Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            OperatingHour.dayName(h.dayOfWeek),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        Switch(
                          value: !h.isClosed,
                          activeColor: AppColors.primary,
                          onChanged: (isBuka) {
                            setState(() {
                              _hours[index] = _hours[index].copyWith(isClosed: !isBuka);
                              _validate();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        if (h.isClosed)
                          const Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Row(
                            children: [
                              _buildTimeChip(
                                timeText: OperatingHoursHelper.formatTime(h.openTime),
                                onTap: () => _pickTime(index, true),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('–'),
                              ),
                              _buildTimeChip(
                                timeText: OperatingHoursHelper.formatTime(h.closeTime),
                                onTap: () => _pickTime(index, false),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              BlocBuilder<ShopProfileBloc, ShopProfileState>(
                builder: (context, state) {
                  final isSaving = state is ShopProfileSaving;
                  return CustomButton(
                    text: 'Simpan Jam Operasional',
                    isLoading: isSaving,
                    onPressed: isSaving
                        ? null
                        : () {
                            if (_validate()) {
                              context.read<ShopProfileBloc>().add(
                                    OperatingHoursUpdated(_hours),
                                  );
                            }
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

  Widget _buildTimeChip({required String timeText, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(
          timeText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
