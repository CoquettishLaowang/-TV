/// TV导航栏组件模块
/// 提供水平排列的导航项列表，支持TV遥控器焦点导航和手机触摸点击
/// 根据设备类型自动调整导航项大小和间距
/// 被TvScaffold和各页面使用
library;

import 'package:flutter/material.dart';

import '../../core/responsive/responsive_adapter.dart';
import 'tv_focusable.dart';

/// 导航项数据模型
/// 描述导航栏中的单个项目
class NavItem {
  /// 项目标识
  final String id;

  /// 显示标签
  final String label;

  /// 图标
  final IconData icon;

  /// 构造函数
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// TV导航栏组件
/// 水平排列的导航项列表，支持遥控器焦点导航和触摸点击
/// 手机端自动缩小导航项以适应屏幕宽度
class TvNavBar extends StatelessWidget {
  /// 导航项列表
  final List<NavItem> items;

  /// 当前选中项ID
  final String selectedItemId;

  /// 选中项变化回调
  final ValueChanged<String>? onItemSelected;

  /// 构造函数
  const TvNavBar({
    super.key,
    required this.items,
    required this.selectedItemId,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);

    return RepaintBoundary(
      child: Container(
        height: responsiveConfig.navBarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveConfig.pageHorizontalPadding,
        ),
        child: Row(
          children: _buildNavItems(colorScheme, responsiveConfig),
        ),
      ),
    );
  }

  /// 构建导航项列表
  /// 参数：colorScheme - 颜色方案 / responsiveConfig - 响应式配置
  /// 返回：List - 导航项组件列表
  /// 副作用：无
  List<Widget> _buildNavItems(
      ColorScheme colorScheme, ResponsiveConfig responsiveConfig) {
    return items.map((NavItem item) {
      final bool isSelected = item.id == selectedItemId;
      return _buildSingleNavItem(item, isSelected, colorScheme, responsiveConfig);
    }).toList();
  }

  /// 构建单个导航项
  /// 参数：item - 导航项数据 / isSelected - 是否选中
  ///       colorScheme - 颜色方案 / responsiveConfig - 响应式配置
  /// 返回：Widget - 导航项组件
  /// 副作用：无
  Widget _buildSingleNavItem(
    NavItem item,
    bool isSelected,
    ColorScheme colorScheme,
    ResponsiveConfig responsiveConfig,
  ) {
    final bool isPhoneDevice = responsiveConfig.navBarItemWidth <= 72;

    return TvFocusable(
      onConfirm: () => onItemSelected?.call(item.id),
      padding: EdgeInsets.symmetric(
        horizontal: isPhoneDevice ? 4 : 8,
      ),
      child: Container(
        width: responsiveConfig.navBarItemWidth,
        height: responsiveConfig.navBarItemHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: responsiveConfig.iconSizeMedium,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            // 手机端导航间距紧凑，只显示图标
            if (!isPhoneDevice) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: responsiveConfig.bodyFontSize,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}