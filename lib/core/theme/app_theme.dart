/// 应用主题配置模块
/// 定义TV端应用的明暗主题、颜色方案、文字样式等
/// 被App根组件和所有页面引用以保持视觉一致性

import 'package:flutter/material.dart';

/// 应用亮色主题配置
/// 返回：ThemeData - 配置好的亮色主题数据
/// 副作用：无
ThemeData buildLightTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A91FF),
    brightness: Brightness.light,
  );
  return _buildBaseTheme(colorScheme);
}

/// 应用暗色主题配置（TV端推荐）
/// 返回：ThemeData - 配置好的暗色主题数据
/// 副作用：无
ThemeData buildDarkTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A91FF),
    brightness: Brightness.dark,
  );
  return _buildBaseTheme(colorScheme);
}

/// 构建基础主题，被明暗主题共用
/// 参数：colorScheme - 颜色方案
/// 返回：ThemeData - 基础主题数据
/// 副作用：无
ThemeData _buildBaseTheme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: _buildTextTheme(),
    cardTheme: _buildCardTheme(colorScheme),
    elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

/// 构建TV端文字主题，字号比移动端大以保证远距离可读性
/// 返回：TextTheme - 文字主题数据
/// 副作用：无
TextTheme _buildTextTheme() {
  return const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

/// 构建TV端卡片主题，确保卡片在TV大屏上有足够的视觉层次
/// 参数：colorScheme - 颜色方案
/// 返回：CardThemeData - 卡片主题数据
/// 副作用：无
CardThemeData _buildCardTheme(ColorScheme colorScheme) {
  return CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: colorScheme.surfaceContainerHighest,
    shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
  );
}

/// 构建TV端按钮主题，确保遥控器可聚焦的按钮足够大
/// 参数：colorScheme - 颜色方案
/// 返回：ElevatedButtonThemeData - 按钮主题数据
/// 副作用：无
ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      minimumSize: const Size(120, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
