/// TV卡片组件模块
/// 提供TV端视频卡片展示组件，支持焦点高亮和缩放效果
/// 被首页和平台页面用于展示视频内容
library;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/tv_dimensions.dart';
import 'tv_focusable.dart';

/// TV视频卡片组件
/// 展示视频缩略图、标题等信息，支持TV遥控器焦点导航
class TvCard extends StatelessWidget {
  /// 卡片标题
  final String title;

  /// 副标题或描述信息
  final String? subtitle;

  /// 缩略图URL
  final String? thumbnailUrl;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChanged;

  /// 确认键回调
  final VoidCallback? onConfirm;

  /// 是否自动获取焦点
  final bool autofocus;

  /// 卡片宽度
  final double width;

  /// 卡片高度
  final double height;

  /// 附加信息标签（如"VIP"、"热播"等）
  final String? badge;

  /// 构造函数
  const TvCard({
    super.key,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.onFocusChanged,
    this.onConfirm,
    this.autofocus = false,
    this.width = kVideoCardWidth,
    this.height = kVideoCardHeight,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TvFocusable(
      autofocus: autofocus,
      onFocusChanged: onFocusChanged,
      onConfirm: onConfirm,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(context, colorScheme),
            _buildTitleSection(colorScheme),
          ],
        ),
      ),
    );
  }

  /// 构建缩略图区域
  /// 参数：context - 构建上下文 / colorScheme - 颜色方案
  /// 返回：Widget - 缩略图组件
  /// 副作用：无
  Widget _buildThumbnail(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: width,
      height: height * kVideoCardAspectRatio / (kVideoCardAspectRatio + 0.4),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(kCardBorderRadius),
            ),
            child: _buildThumbnailImage(colorScheme),
          ),
          if (badge != null) _buildBadge(colorScheme),
        ],
      ),
    );
  }

  /// 构建缩略图图片或占位符
  /// 参数：colorScheme - 颜色方案
  /// 返回：Widget - 图片或占位符
  /// 副作用：无
  Widget _buildThumbnailImage(ColorScheme colorScheme) {
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            size: kIconSizeLarge,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return Image.network(
      thumbnailUrl!,
      fit: BoxFit.cover,
      errorBuilder: _buildImageErrorWidget,
    );
  }

  /// 构建图片加载失败的占位组件
  /// 参数：context / error / stackTrace
  /// 返回：Widget - 错误占位组件
  /// 副作用：无
  Widget _buildImageErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: kIconSizeLarge,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// 构建角标
  /// 参数：colorScheme - 颜色方案
  /// 返回：Widget - 角标组件
  /// 副作用：无
  Widget _buildBadge(ColorScheme colorScheme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          badge!,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建标题区域
  /// 参数：colorScheme - 颜色方案
  /// 返回：Widget - 标题区域组件
  /// 副作用：无
  Widget _buildTitleSection(ColorScheme colorScheme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
