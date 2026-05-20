/// 响应式布局适配器模块
/// 自动检测设备类型（电视/手机/平板），提供响应式尺寸配置
/// 被所有UI组件引用，实现多设备自适应布局
library;

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// 设备类型枚举
/// 用于区分不同设备形态，驱动响应式布局策略
enum DeviceType {
  /// 电视设备（通常>=7英寸且无触屏主要支持遥控器）
  tv,

  /// 手机设备（屏幕宽度 < 600逻辑像素）
  phone,

  /// 平板设备（屏幕宽度 >= 600逻辑像素且非TV模式）
  tablet,
}

/// 屏幕宽度阈值 - 手机最大宽度（逻辑像素）
/// 来源：Material Design responsive breakpoints
const double kPhoneMaxWidth = 600.0;

/// 屏幕宽度阈值 - 平板最小宽度（逻辑像素）
const double kTabletMinWidth = 600.0;

/// TV检测最小宽度（逻辑像素）
/// 来源：Android TV 典型分辨率 1920x1080, 逻辑密度换算
const double kTvMinWidth = 960.0;

/// 响应式配置数据
/// 根据设备类型和屏幕尺寸提供自适应的布局参数
class ResponsiveConfig {
  /// 页面水平内边距
  final double pageHorizontalPadding;

  /// 页面垂直内边距
  final double pageVerticalPadding;

  /// 卡片之间水平间距
  final double cardHorizontalSpacing;

  /// 卡片之间垂直间距
  final double cardVerticalSpacing;

  /// 导航栏高度
  final double navBarHeight;

  /// 导航栏项目宽度
  final double navBarItemWidth;

  /// 导航栏项目高度
  final double navBarItemHeight;

  /// 视频卡片宽度
  final double videoCardWidth;

  /// 视频卡片高度
  final double videoCardHeight;

  /// 视频卡片缩略图宽高比
  final double videoCardAspectRatio;

  /// 首页网格列数
  final int homeGridColumns;

  /// 图标尺寸 - 小
  final double iconSizeSmall;

  /// 图标尺寸 - 中
  final double iconSizeMedium;

  /// 图标尺寸 - 大
  final double iconSizeLarge;

  /// 图标尺寸 - 超大
  final double iconSizeExtraLarge;

  /// 焦点高亮边框宽度
  final double focusHighlightBorderWidth;

  /// 焦点高亮边框圆角
  final double focusHighlightBorderRadius;

  /// 焦点缩放比例
  final double focusScaleRatio;

  /// 焦点动画时长（毫秒）
  final int focusAnimationDurationMs;

  /// 卡片圆角半径
  final double cardBorderRadius;

  /// 标题字体大小
  final double titleFontSize;

  /// 正文字体大小
  final double bodyFontSize;

  /// 是否启用焦点效果（手机上禁用缩放和高亮）
  final bool enableFocusEffects;

  /// 构造函数
  const ResponsiveConfig({
    required this.pageHorizontalPadding,
    required this.pageVerticalPadding,
    required this.cardHorizontalSpacing,
    required this.cardVerticalSpacing,
    required this.navBarHeight,
    required this.navBarItemWidth,
    required this.navBarItemHeight,
    required this.videoCardWidth,
    required this.videoCardHeight,
    required this.videoCardAspectRatio,
    required this.homeGridColumns,
    required this.iconSizeSmall,
    required this.iconSizeMedium,
    required this.iconSizeLarge,
    required this.iconSizeExtraLarge,
    required this.focusHighlightBorderWidth,
    required this.focusHighlightBorderRadius,
    required this.focusScaleRatio,
    required this.focusAnimationDurationMs,
    required this.cardBorderRadius,
    required this.titleFontSize,
    required this.bodyFontSize,
    required this.enableFocusEffects,
  });

  /// TV端响应式配置
  /// 基于1920x1080 TV标准分辨率设计
  static const ResponsiveConfig tv = ResponsiveConfig(
    pageHorizontalPadding: 48.0,
    pageVerticalPadding: 24.0,
    cardHorizontalSpacing: 24.0,
    cardVerticalSpacing: 20.0,
    navBarHeight: 72.0,
    navBarItemWidth: 160.0,
    navBarItemHeight: 48.0,
    videoCardWidth: 280.0,
    videoCardHeight: 200.0,
    videoCardAspectRatio: 16.0 / 9.0,
    homeGridColumns: 5,
    iconSizeSmall: 20.0,
    iconSizeMedium: 28.0,
    iconSizeLarge: 40.0,
    iconSizeExtraLarge: 64.0,
    focusHighlightBorderWidth: 3.0,
    focusHighlightBorderRadius: 12.0,
    focusScaleRatio: 1.05,
    focusAnimationDurationMs: 200,
    cardBorderRadius: 16.0,
    titleFontSize: 28.0,
    bodyFontSize: 16.0,
    enableFocusEffects: true,
  );

  /// 手机端响应式配置
  /// 基于360-414逻辑像素宽度的手机屏幕设计
  static const ResponsiveConfig phone = ResponsiveConfig(
    pageHorizontalPadding: 16.0,
    pageVerticalPadding: 12.0,
    cardHorizontalSpacing: 12.0,
    cardVerticalSpacing: 12.0,
    navBarHeight: 56.0,
    navBarItemWidth: 72.0,
    navBarItemHeight: 40.0,
    videoCardWidth: 160.0,
    videoCardHeight: 140.0,
    videoCardAspectRatio: 16.0 / 9.0,
    homeGridColumns: 2,
    iconSizeSmall: 16.0,
    iconSizeMedium: 22.0,
    iconSizeLarge: 32.0,
    iconSizeExtraLarge: 48.0,
    focusHighlightBorderWidth: 0.0,
    focusHighlightBorderRadius: 8.0,
    focusScaleRatio: 1.0,
    focusAnimationDurationMs: 0,
    cardBorderRadius: 12.0,
    titleFontSize: 18.0,
    bodyFontSize: 14.0,
    enableFocusEffects: false,
  );

  /// 平板端响应式配置
  static const ResponsiveConfig tablet = ResponsiveConfig(
    pageHorizontalPadding: 32.0,
    pageVerticalPadding: 20.0,
    cardHorizontalSpacing: 18.0,
    cardVerticalSpacing: 16.0,
    navBarHeight: 64.0,
    navBarItemWidth: 130.0,
    navBarItemHeight: 44.0,
    videoCardWidth: 220.0,
    videoCardHeight: 170.0,
    videoCardAspectRatio: 16.0 / 9.0,
    homeGridColumns: 4,
    iconSizeSmall: 18.0,
    iconSizeMedium: 24.0,
    iconSizeLarge: 36.0,
    iconSizeExtraLarge: 56.0,
    focusHighlightBorderWidth: 2.0,
    focusHighlightBorderRadius: 10.0,
    focusScaleRatio: 1.03,
    focusAnimationDurationMs: 150,
    cardBorderRadius: 14.0,
    titleFontSize: 22.0,
    bodyFontSize: 15.0,
    enableFocusEffects: true,
  );

  /// 根据屏幕宽度计算首页网格列数
  /// 参数：screenWidth - 屏幕逻辑像素宽度
  /// 返回：int - 适合当前宽度的列数
  /// 副作用：无
  static int calculateGridColumns(double screenWidth) {
    if (screenWidth < 600) {
      return 2;
    }
    if (screenWidth < 840) {
      return 3;
    }
    if (screenWidth < 1024) {
      return 4;
    }
    return 5;
  }
}

/// 响应式布局适配器
/// 根据BuildContext检测设备类型和屏幕尺寸，提供响应式配置
class ResponsiveAdapter {
  /// 根据BuildContext检测设备类型
  /// 优先根据平台类型判断（桌面平台强制按TV处理），
  /// 再结合屏幕尺寸和像素密度综合判断
  /// 参数：context - 构建上下文
  /// 返回：DeviceType - 检测到的设备类型
  /// 副作用：无
  static DeviceType detectDeviceType(BuildContext context) {
    final TargetPlatform platform = defaultTargetPlatform;

    // 桌面平台（Windows/macOS/Linux）强制按TV模式处理
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux) {
      return DeviceType.tv;
    }

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final double logicalShortSide =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final double logicalLongSide =
        screenWidth > screenHeight ? screenWidth : screenHeight;

    // TV/大屏设备检测：长边 >= 900 且宽高比接近 16:9 或更大
    if (logicalLongSide >= 900) {
      return DeviceType.tv;
    }

    // 中等屏幕：平板
    if (logicalShortSide >= kTabletMinWidth) {
      return DeviceType.tablet;
    }

    return DeviceType.phone;
  }

  /// 获取当前设备的响应式配置
  /// 参数：context - 构建上下文
  /// 返回：ResponsiveConfig - 响应式配置数据
  /// 副作用：无
  static ResponsiveConfig of(BuildContext context) {
    final DeviceType deviceType = detectDeviceType(context);
    switch (deviceType) {
      case DeviceType.tv:
        return ResponsiveConfig.tv;
      case DeviceType.tablet:
        return ResponsiveConfig.tablet;
      case DeviceType.phone:
        return ResponsiveConfig.phone;
    }
  }

  /// 判断当前是否为TV设备
  /// 参数：context - 构建上下文
  /// 返回：bool - 是否为TV
  /// 副作用：无
  static bool isTv(BuildContext context) {
    return detectDeviceType(context) == DeviceType.tv;
  }

  /// 判断当前是否为手机设备
  /// 参数：context - 构建上下文
  /// 返回：bool - 是否为手机
  /// 副作用：无
  static bool isPhone(BuildContext context) {
    return detectDeviceType(context) == DeviceType.phone;
  }

  /// 判断当前是否为平板设备
  /// 参数：context - 构建上下文
  /// 返回：bool - 是否为平板
  /// 副作用：无
  static bool isTablet(BuildContext context) {
    return detectDeviceType(context) == DeviceType.tablet;
  }

  /// 根据设备类型提供自适应内边距
  /// 参数：context - 构建上下文
  /// 返回：EdgeInsets - 自适应内边距
  /// 副作用：无
  static EdgeInsets safePadding(BuildContext context) {
    final ResponsiveConfig config = of(context);
    return EdgeInsets.symmetric(
      horizontal: config.pageHorizontalPadding,
      vertical: config.pageVerticalPadding,
    );
  }
}