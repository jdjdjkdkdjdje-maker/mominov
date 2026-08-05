import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const CategoryChips({super.key, required this.categories, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedId == category.id;
          return GestureDetector(
            onTap: () => onSelect(isSelected ? null : category.id),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.mango : AppColors.mango.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: category.iconUrl != null
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: CachedNetworkImage(imageUrl: category.iconUrl!, color: isSelected ? Colors.white : null),
                          )
                        : Icon(Icons.restaurant_rounded, color: isSelected ? Colors.white : AppColors.mango),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.localizedName(Localizations.localeOf(context).languageCode),
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
