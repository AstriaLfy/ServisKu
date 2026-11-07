import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_cubit.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_state.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';

class AddressListView extends StatefulWidget {
  const AddressListView({super.key});

  @override
  State<AddressListView> createState() => _AddressListViewState();
}

class _AddressListViewState extends State<AddressListView> {
  String? _pendingId;

  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().load();
  }

  Future<void> _confirmSelection() async {
    final id = _pendingId;
    if (id == null) return;

    final cubit = context.read<AddressCubit>();
    final success = await cubit.select(id);
    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.errorMessage ?? 'Gagal memilih alamat.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final recipient = authState is AuthSuccess ? authState.user.fullName : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            return Column(
              children: [
                const CustomerPageHeader(title: 'Kelola Alamat'),
                Expanded(child: _buildList(context, state, recipient)),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: CustomButton(
                    text: 'Pilih Alamat',
                    isLoading: state.isSaving,
                    onPressed: _pendingId == null || state.isSaving ? null : _confirmSelection,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AddressState state, String recipient) {
    if (state.status == AddressStatus.loading && state.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AddressStatus.failure && state.addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Gagal memuat alamat.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<AddressCubit>().load(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        ...state.addresses.map(
          (address) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AddressCard(
              address: address,
              recipient: recipient,
              isHighlighted: address.id == _pendingId,
              isCurrent: address.id == state.selectedAddress?.id,
              onTap: () => setState(() => _pendingId = address.id),
              onEdit: () => context.push('/customer/address/form', extra: address),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => context.push('/customer/address/form'),
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF111827)),
            label: const Text(
              'Tambah alamat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final CustomerAddress address;
  final String recipient;
  final bool isHighlighted;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.recipient,
    required this.isHighlighted,
    required this.isCurrent,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (recipient.isNotEmpty) recipient,
      if (address.phone != null && address.phone!.isNotEmpty) address.phone!,
    ].join(' • ');

    return Material(
      color: isHighlighted ? const Color(0xFFEFF6FF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : const Color(0xFFE5E7EB),
              width: isHighlighted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Utama',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      address.fullAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF111827)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
