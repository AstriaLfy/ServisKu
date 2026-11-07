import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_detail_state.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';

class OrderReviewView extends StatefulWidget {
  const OrderReviewView({super.key});

  @override
  State<OrderReviewView> createState() => _OrderReviewViewState();
}

class _OrderReviewViewState extends State<OrderReviewView> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  static const List<String> _ratingLabels = [
    'Sangat Buruk',
    'Kurang',
    'Cukup',
    'Bagus',
    'Sempurna',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await context.read<CustomerOrderDetailCubit>().submitReview(
      rating: _rating,
      review: _reviewController.text,
    );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerOrderDetailCubit, CustomerOrderDetailState>(
      builder: (context, state) {
        final order = state.order;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const CustomerPageHeader(title: 'Review'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order?.displayNumber ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Center(
                          child: Text(
                            'Pesanan telah selesai.\nMasukkan rating kamu (1-5)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              final value = index + 1;
                              return GestureDetector(
                                onTap: () => setState(() => _rating = value),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 48,
                                    color: value <= _rating
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD1D5DB),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 18,
                          child: _rating > 0
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Bintang $_rating (${_ratingLabels[_rating - 1]})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tuliskan review (opsional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _reviewController,
                          hintText: 'Tuliskan catatan',
                          textInputAction: TextInputAction.done,
                          enabled: !state.isActionInProgress,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Skip',
                          variant: ButtonVariant.outlined,
                          height: 46,
                          onPressed: state.isActionInProgress ? null : () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Kirim Review',
                          height: 46,
                          isLoading: state.isActionInProgress,
                          onPressed: _rating == 0 || order == null ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
