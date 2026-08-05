import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import 'order_list_tile.dart';

/// Buyurtma holati bosqichlarini vertikal chiziq bilan ko'rsatadi
/// (8-band: buyurtma bosqichlari; backend OrderStatus ketma-ketligiga mos).
class StatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const StatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final currentIndex = orderStatusTimeline.indexOf(currentStatus);

    return Column(
      children: List.generate(orderStatusTimeline.length, (i) {
        final status = orderStatusTimeline[i];
        final isDone = i <= currentIndex;
        final isLast = i == orderStatusTimeline.length - 1;
        final (color, label) = orderStatusPresentation(status);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDone ? color : AppColors.lightBorder,
                      shape: BoxShape.circle,
                    ),
                    child: isDone ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: i < currentIndex ? color : AppColors.lightBorder),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                      color: isDone ? null : AppColors.lightTextSecondary,
                    ),
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
