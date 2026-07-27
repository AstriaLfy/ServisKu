import 'package:flutter/material.dart';
import 'package:servis_ku/data/models/order_model.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onReject;
  final VoidCallback? onAccept;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onReject,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: order.status.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    iconWidget: const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    value: order.distance,
                    label: 'Jarak',
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    iconWidget: Image.asset(
                      'assets/icons/wallet_icon.png',
                      width: 14,
                      height: 14,
                    ),
                    value: order.price,
                    label: 'Estimasi Harga',
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    iconWidget: const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    value: order.estimatedTime,
                    label: 'Estimasi Waktu',
                  ),
                ),
              ],
            ),

            if (onReject != null || onAccept != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: CustomButton(
                        text: 'Tolak',
                        variant: ButtonVariant.outlined,
                        height: 42,
                        borderRadius: 24,
                        onPressed: onReject,
                      ),
                    ),
                  if (onReject != null && onAccept != null)
                    const SizedBox(width: 12),
                  if (onAccept != null)
                    Expanded(
                      child: CustomButton(
                        text: 'Terima',
                        height: 42,
                        borderRadius: 24,
                        onPressed: onAccept,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final Widget iconWidget;
  final String value;
  final String label;

  const _InfoTile({
    required this.iconWidget,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
