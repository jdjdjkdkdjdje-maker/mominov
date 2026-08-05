import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/banner_model.dart';

class BannerCarousel extends StatelessWidget {
  final List<BannerModel> banners;
  const BannerCarousel({super.key, required this.banners});

  void _onTap(BuildContext context, BannerModel banner) {
    switch (banner.linkType) {
      case 'restaurant':
        if (banner.linkValue != null) context.push('/restaurant/${banner.linkValue}');
        break;
      case 'product':
        if (banner.linkValue != null) context.push('/product/${banner.linkValue}');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();
    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        viewportFraction: 0.9,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: banners.map((banner) {
        return GestureDetector(
          onTap: () => _onTap(context, banner),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (c, u) => Container(color: AppColors.mango.withOpacity(0.1)),
              errorWidget: (c, u, e) => Container(
                color: AppColors.mango.withOpacity(0.1),
                child: const Icon(Icons.image_not_supported_rounded, color: AppColors.lightTextSecondary),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
