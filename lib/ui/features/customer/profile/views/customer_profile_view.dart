import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_cubit.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_state.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_state.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_cubit.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_avatar.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_confirm_dialog.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerProfileCubit>().load();
    context.read<AddressCubit>().load();
  }

  Future<void> _logout() async {
    final confirmed = await showCustomerConfirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Kamu perlu login kembali untuk memesan layanan.',
      cancelText: 'Batal',
      confirmText: 'Keluar',
    );
    if (!confirmed || !mounted) return;
    _signOut();
  }

  void _signOut() {
    context.read<CustomerOrderCubit>().reset();
    context.read<AddressCubit>().reset();
    context.read<CartCubit>().clear();
    context.read<CustomerProfileCubit>().reset();
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showCustomerConfirmDialog(
      context,
      title: 'Hapus akun?',
      message: 'Semua data akun akan dihapus dan tindakan ini tidak dapat dikembalikan.',
      cancelText: 'Batal',
      confirmText: 'Hapus',
    );
    if (!confirmed || !mounted) return;

    final cubit = context.read<CustomerProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await cubit.deleteAccount();
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Akun berhasil dihapus')),
      );
      _signOut();
      context.go('/login');
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(cubit.state.errorMessage ?? 'Gagal menghapus akun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) context.go('/login');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<CustomerProfileCubit>().load(),
                context.read<AddressCubit>().load(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
                  builder: (context, state) {
                    final authState = context.watch<AuthBloc>().state;
                    final fallbackName =
                        authState is AuthSuccess ? authState.user.fullName : '';
                    final name = state.profile.fullName.isNotEmpty
                        ? state.profile.fullName
                        : (fallbackName.isNotEmpty ? fallbackName : 'Pelanggan');

                    return Column(
                      children: [
                        CustomerAvatar(imageUrl: state.profile.avatarUrl),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Customer',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _MenuCard(
                  title: 'Kelola Alamat',
                  children: [
                    BlocBuilder<AddressCubit, AddressState>(
                      builder: (context, state) {
                        final address = state.selectedAddress;
                        return _MenuTile(
                          icon: Icons.location_on_outlined,
                          caption: address?.label,
                          title: address?.fullAddress ?? 'Tambahkan alamat',
                          onTap: () => context.push('/customer/address'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  title: 'Manajemen Akun',
                  children: [
                    _MenuTile(
                      icon: Icons.manage_accounts_outlined,
                      title: 'Edit Profile',
                      onTap: () => context.push('/customer/profile/edit'),
                    ),
                    _MenuTile(
                      icon: Icons.key_outlined,
                      title: 'Ubah Password',
                      onTap: () => context.push('/customer/profile/password'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  children: [
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      showChevron: false,
                      onTap: _logout,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  children: [
                    _MenuTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Account',
                      color: AppColors.danger,
                      showChevron: false,
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _MenuCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, title == null ? 4 : 14, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? caption;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.caption,
    this.color = const Color(0xFF111827),
    this.showChevron = true,
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
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null && caption!.isNotEmpty)
                    Text(
                      caption!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
          ],
        ),
      ),
    );
  }
}
