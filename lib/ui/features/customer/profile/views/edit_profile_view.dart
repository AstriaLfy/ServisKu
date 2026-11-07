import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_avatar.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CustomerProfileCubit>();
    if (cubit.state.status != ProfileStatus.loaded) cubit.load();
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image == null || !mounted) return;
      final cubit = context.read<CustomerProfileCubit>();
      final success = await cubit.uploadAvatar(image.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Foto profil berhasil diperbarui'
                : (cubit.state.errorMessage ?? 'Gagal mengunggah foto.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka galeri.')),
      );
    }
  }

  void _openField(ProfileField field) {
    context.push('/customer/profile/edit/${field.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
          builder: (context, state) {
            final profile = state.profile;

            return Column(
              children: [
                const CustomerPageHeader(title: 'Edit Profile'),
                Expanded(
                  child: state.status == ProfileStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            Center(
                              child: CustomerAvatar(
                                imageUrl: profile.avatarUrl,
                                isLoading: state.isUploadingAvatar,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: GestureDetector(
                                onTap: state.isUploadingAvatar ? null : _pickAvatar,
                                child: const Text(
                                  'Ubah foto profil',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF111827),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _InfoCard(
                              title: 'Info Profil',
                              children: [
                                _InfoRow(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Nama',
                                  value: profile.fullName,
                                  onTap: () => _openField(ProfileField.name),
                                ),
                                _InfoRow(
                                  icon: Icons.edit_note_rounded,
                                  label: 'Bio',
                                  value: profile.bio,
                                  onTap: () => _openField(ProfileField.bio),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InfoCard(
                              title: 'Info Pribadi',
                              children: [
                                _InfoRow(
                                  icon: Icons.mail_outline_rounded,
                                  label: 'Email',
                                  value: profile.email,
                                  onTap: () => _openField(ProfileField.email),
                                ),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Nomor Telepon',
                                  value: profile.phone,
                                  onTap: () => _openField(ProfileField.phone),
                                ),
                              ],
                            ),
                          ],
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF111827)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? '-' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
          ],
        ),
      ),
    );
  }
}
