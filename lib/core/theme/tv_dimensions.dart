/// TV尺寸规范定义模块
/// 定义TV大屏UI的尺寸标准，包括间距、字体、图标、卡片等
/// 被所有UI组件引用，确保TV端视觉一致性
/// 所有尺寸基于1920x1080标准TV分辨率设计
library;

import 'package:flutter/material.dart';

/// TV安全区域内边距，防止内容被电视边框裁切
const EdgeInsets kTvSafePadding = EdgeInsets.symmetric(
  horizontal: 48,
  vertical: 24,
);

/// 页面水平内边距
const double kPageHorizontalPadding = 48.0;

/// 页面垂直内边距
const double kPageVerticalPadding = 24.0;

/// 卡片之间的水平间距
const double kCardHorizontalSpacing = 24.0;

/// 卡片之间的垂直间距
const double kCardVerticalSpacing = 20.0;

/// 导航栏高度
const double kNavBarHeight = 72.0;

/// 导航栏项目宽度
const double kNavBarItemWidth = 160.0;

/// 导航栏项目高度
const double kNavBarItemHeight = 48.0;

/// 底部导航栏高度
const double kBottomBarHeight = 64.0;

/// 视频卡片宽度（标准）
const double kVideoCardWidth = 280.0;

/// 视频卡片高度（标准）
const double kVideoCardHeight = 200.0;

/// 视频卡片缩略图宽高比
const double kVideoCardAspectRatio = 16 / 9;

/// 大尺寸视频卡片宽度（精选/推荐区域）
const double kVideoCardLargeWidth = 400.0;

/// 大尺寸视频卡片高度（精选/推荐区域）
const double kVideoCardLargeHeight = 260.0;

/// 分类标签高度
const double kCategoryTabHeight = 56.0;

/// 分类标签水平内边距
const double kCategoryTabHorizontalPadding = 24.0;

/// 搜索栏高度
const double kSearchBarHeight = 56.0;

/// 搜索栏宽度（占屏幕比例）
const double kSearchBarWidthRatio = 0.4;

/// 图标尺寸 - 小（用于标签/辅助信息）
const double kIconSizeSmall = 20.0;

/// 图标尺寸 - 中（用于导航/按钮）
const double kIconSizeMedium = 28.0;

/// 图标尺寸 - 大（用于平台Logo/焦点状态）
const double kIconSizeLarge = 40.0;

/// 图标尺寸 - 超大（用于空状态/启动页）
const double kIconSizeExtraLarge = 64.0;

/// 焦点高亮边框宽度
const double kFocusHighlightBorderWidth = 3.0;

/// 焦点高亮边框圆角
const double kFocusHighlightBorderRadius = 12.0;

/// 焦点缩放比例
const double kFocusScaleRatio = 1.05;

/// 焦点阴影扩散半径
const double kFocusShadowSpreadRadius = 4.0;

/// 焦点阴影模糊半径
const double kFocusShadowBlurRadius = 12.0;

/// 加载指示器尺寸
const double kLoadingIndicatorSize = 48.0;

/// 进度条高度
const double kProgressBarHeight = 4.0;

/// Toast消息高度
const double kToastHeight = 56.0;

/// Toast消息显示时长（毫秒）
const int kToastDurationMs = 2000;

/// 弹窗圆角半径
const double kDialogBorderRadius = 16.0;

/// 弹窗最大宽度占屏幕比例
const double kDialogMaxWidthRatio = 0.5;

/// 弹窗最大高度占屏幕比例
const double kDialogMaxHeightRatio = 0.6;

/// 设置项高度
const double kSettingsItemHeight = 64.0;

/// 设置项水平内边距
const double kSettingsItemHorizontalPadding = 32.0;

/// 分割线粗细
const double kDividerThickness = 1.0;

/// 分割线水平边距
const double kDividerHorizontalMargin = 24.0;

/// 滚动条宽度
const double kScrollBarWidth = 6.0;

/// 滚动条圆角半径
const double kScrollBarRadius = 3.0;
