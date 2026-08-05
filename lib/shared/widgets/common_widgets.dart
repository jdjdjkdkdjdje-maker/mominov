import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Narxni "12 000 so'm" ko'rinishida formatlaydi.
String formatSum(num amount) {
  final formatter = NumberFormat.decimalPattern('uz');
  return "${formatter.format(amount)} so'm";
}

class PriceText extends StatelessWidget {
  final double price;
  final double? oldPrice;
  final double fontSize;
  final Color? color;

  const PriceText({super.key, required this.price, this.oldPrice, this.fontSize = 15, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(formatSum(price), style: AppTypography.price.copyWith(fontSize: fontSize, color: c)),
        if (oldPrice != null && oldPrice! > price) ...[
          const SizedBox(width: 6),
          Text(
            formatSum(oldPrice!),
            style: AppTypography.priceStrikethrough.copyWith(color: AppColors.lightTextSecondary),
          ),
        ],
      ],
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  const RatingBadge({super.key, required this.rating, this.reviewsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mango.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.mango),
          const SizedBox(width: 3),
          Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.mangoDark)),
          if (reviewsCount != null) ...[
            const SizedBox(width: 3),
            Text('($reviewsCount)', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
          ]
        ],
      ),
    );
  }
}

class StarRatingInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  final double size;
  const StarRatingInput({super.key, required this.rating, required this.onChanged, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      itemSize: size,
      itemCount: 5,
      itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.mango),
      onRatingUpdate: onChanged,
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: AppColors.mango));
}

class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetryView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.lightTextSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Qayta urinish')),
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateView({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.lightTextSecondary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text("Barchasi", style: TextStyle(color: AppColors.mango, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final double size;

  const QuantityStepper({super.key, required this.quantity, required this.onChanged, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.remove_rounded, () => onChanged(quantity - 1)),
        SizedBox(
          width: 32,
          child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        _button(Icons.add_rounded, () => onChanged(quantity + 1)),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: AppColors.mango, borderRadius: BorderRadius.circular(size / 2)),
          child: Icon(icon, size: size * 0.55, color: Colors.white),
        ),
      );
}

/// Buyurtma holati (8-band) uchun rangli status chipi — order tracking va
/// tarix ekranlarida ishlatiladi.
class OrderStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const OrderStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
