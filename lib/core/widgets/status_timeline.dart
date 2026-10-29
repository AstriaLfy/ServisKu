import 'package:flutter/material.dart';
import 'package:servis_ku/data/models/order_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusHistoryItem> items;

  const StatusTimeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final bool isLast = index == items.length - 1;

        final Color dotColor = item.isCancelled
            ? const Color(0xFFDC2626)
            : item.isDone
            ? const Color(0xFF1D56CF)
            : const Color(0xFFD1D5DB);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isDone || item.isCancelled
                          ? dotColor
                          : Colors.white,
                      border: Border.all(color: dotColor, width: 2),
                    ),
                    child: item.isDone
                        ? Icon(
                            item.isCancelled ? Icons.close : Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.isDone || item.isCancelled
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.dateTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
