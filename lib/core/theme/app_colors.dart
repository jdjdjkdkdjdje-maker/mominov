import 'package:flutter/material.dart';

/// Uzum Tezkor brend rang palitrasi.
/// Admin va restoran paneli bilan bir xil brend tili: to'q ko'k-kulrang "ink",
/// mango-sariq urg'u va yashilroq oq "paper" fon.
class AppColors {
  AppColors._();

  // Brand
  static const Color mango = Color(0xFFFF8A3D);
  static const Color mangoDark = Color(0xFFE86A1C);
  static const Color ink = Color(0xFF14161F);
  static const Color inkLight = Color(0xFF23263280);
  static const Color paper = Color(0xFFF3F5F1);

  // Semantic — Light
  static const Color lightBackground = paper;
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE4E5E0);
  static const Color lightTextPrimary = ink;
  static const Color lightTextSecondary = Color(0xFF6B6E78);

  // Semantic — Dark
  static const Color darkBackground = Color(0xFF0D0E14);
  static const Color darkSurface = Color(0xFF1A1C26);
  static const Color darkBorder = Color(0xFF2C2F3B);
  static const Color darkTextPrimary = Color(0xFFF3F5F1);
  static const Color darkTextSecondary = Color(0xFFA0A3AE);

  // Status
  static const Color success = Color(0xFF34A853);
  static const Color danger = Color(0xFFE24C4C);
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF3B82F6);

  // Order status colors (matches admin/restaurant panel status pipeline)
  static const Color statusCreated = Color(0xFF9CA3AF);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusPreparing = Color(0xFFFFB020);
  static const Color statusReady = Color(0xFF8B5CF6);
  static const Color statusCourier = Color(0xFF06B6D4);
  static const Color statusOnTheWay = mango;
  static const Color statusDelivered = success;
  static const Color statusCancelled = danger;
}
