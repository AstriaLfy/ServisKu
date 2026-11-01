import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/operating_hours_helper.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';
import 'package:servis_ku/ui/features/provider/profile/views/edit_operating_hours_dialog.dart';
import 'package:servis_ku/ui/features/provider/profile/views/edit_service_area_dialog.dart';
import 'package:servis_ku/ui/features/provider/profile/views/edit_shop_info_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ShopProfile shop) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (file != null && mounted) {
      context.read<ShopProfileBloc>().add(ShopPhotoPicked(File(file.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopProfileBloc, ShopProfileState>(
      listener: (context, state) {
        if (state is ShopProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ShopProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ShopProfileLoading && state.shop == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ShopProfileFailure && state.shop == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        context.read<ShopProfileBloc>().add(const ShopProfileStarted());
                      },
                      child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final shop = state.shop;
        if (shop == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<ShopProfileBloc>().add(const ShopProfileStarted());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Opacity(
                          opacity: 0.35,
                          child: Image.asset(
                            'assets/images/texture.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        bottom: 16,
                        child: Text(
                          'Toko',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileTokoCard(shop),
                        const SizedBox(height: 16),

                        _buildAreaLayananCard(shop),
                        const SizedBox(height: 16),

                        _buildJamOperasionalCard(shop),
                        const SizedBox(height: 24),

                        _buildActionButtons(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTokoCard(ShopProfile shop) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ShopProfileBloc>(),
            child: EditShopInfoDialog(shop: shop),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Toko',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF111827),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(shop),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(22),
                          image: (shop.photoUrl != null && shop.photoUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(shop.photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (shop.photoUrl == null || shop.photoUrl!.isEmpty)
                            ? const Icon(Icons.storefront, color: Colors.grey, size: 40)
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name.isNotEmpty ? shop.name : 'Nama Toko',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (shop.tagline != null && shop.tagline!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          shop.tagline!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildVerificationBadge(shop.verificationStatus),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(VerificationStatus status) {
    Color bg;
    Color border;
    Color text;

    switch (status) {
      case VerificationStatus.verified:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        break;
      case VerificationStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFCA5A5);
        text = AppColors.danger;
        break;
      case VerificationStatus.pending:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFCD34D);
        text = const Color(0xFFD97706);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _buildAreaLayananCard(ShopProfile shop) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ShopProfileBloc>(),
            child: EditServiceAreaDialog(shop: shop),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Area Layanan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (shop.serviceArea != null && shop.serviceArea!.trim().isNotEmpty)
                        ? shop.serviceArea!
                        : 'Belum diatur',
                    style: TextStyle(
                      fontSize: 13,
                      color: (shop.serviceArea != null && shop.serviceArea!.trim().isNotEmpty)
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Color(0xFF111827),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJamOperasionalCard(ShopProfile shop) {
    final groups = OperatingHoursHelper.groupHours(shop.hours);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ShopProfileBloc>(),
            child: EditOperatingHoursDialog(shop: shop),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Jam Operasional',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF111827),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: groups.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Belum diatur',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    )
                  : Column(
                      children: groups
                          .map((g) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: _buildScheduleRow(g.dayRange, g.hoursText),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String days, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          days,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hours,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push('/provider/services');
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.engineering_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Layanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push('/provider/account');
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.manage_accounts_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
