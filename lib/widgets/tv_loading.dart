/// TV加载组件模块
/// 提供TV端加载状态展示组件，包括加载指示器、空状态和错误状态
/// 被所有需要异步加载的页面使用

import 'package:flutter/material.dart';

import '../../core/theme/tv_dimensions.dart';

/// 加载状态枚举
enum LoadingState {
  /// 正在加载
  loading,

  /// 加载完成
  loaded,

  /// 加载失败
  error,

  /// 数据为空
  empty,
}

/// TV加载组件
/// 根据加载状态显示不同的UI：加载动画、错误提示或空状态
class TvLoading extends StatelessWidget {
  /// 当前加载状态
  final LoadingState state;

  /// 错误信息，仅在state为error时显示
  final String? errorMessage;

  /// 重试回调，仅在state为error时可用
  final VoidCallback? onRetry;

  /// 空状态提示文本
  final String emptyMessage;

  /// 构造函数
  const TvLoading({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage = '暂无内容',
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadingState.loading:
        return _buildLoadingIndicator(context);
      case LoadingState.error:
        return _buildErrorState(context);
      case LoadingState.empty:
        return _buildEmptyState(context);
      case LoadingState.loaded:
        return const SizedBox.shrink();
    }
  }

  /// 构建加载指示器
  /// 参数：context - 构建上下文
  /// 返回：Widget - 加载动画组件
  /// 副作用：无
  Widget _buildLoadingIndicator(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: kLoadingIndicatorSize,
            height: kLoadingIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: kProgressBarHeight,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  /// 参数：context - 构建上下文
  /// 返回：Widget - 错误提示组件
  /// 副作用：无
  Widget _buildErrorState(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: kIconSizeExtraLarge,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? '加载失败，请重试',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 18,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建空状态
  /// 参数：context - 构建上下文
  /// 返回：Widget - 空状态提示组件
  /// 副作用：无
  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: kIconSizeExtraLarge,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
