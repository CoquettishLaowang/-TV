/// TV导航栏组件模块
/// 提供TV端顶部/侧边导航栏组件，支持遥控器焦点导航
/// 被TvScaffold和各页面使用

import 'package:flutter/material.dart';

import '../../core/theme/tv_dimensions.dart';
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
/// 水平排列的导航项列表，支持遥控器焦点导航
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

    return Container(
      height: kNavBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: kPageHorizontalPadding),
      child: Row(
        children: _buildNavItems(colorScheme),
      ),
    );
  }

  /// 构建导航项列表
  /// 参数：colorScheme - 颜色方案
  /// 返回：List<Widget> - 导航项组件列表
  /// 副作用：无
  List<Widget> _buildNavItems(ColorScheme colorScheme) {
    return items.map((NavItem item) {
      final bool isSelected = item.id == selectedItemId;
      return _buildSingleNavItem(item, isSelected, colorScheme);
    }).toList();
  }

  /// 构建单个导航项
  /// 参数：item - 导航项数据 / isSelected - 是否选中 / colorScheme - 颜色方案
  /// 返回：Widget - 导航项组件
  /// 副作用：无
  Widget _buildSingleNavItem(
    NavItem item,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return TvFocusable(
      onConfirm: () => onItemSelected?.call(item.id),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: kNavBarItemWidth,
        height: kNavBarItemHeight,
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
              size: kIconSizeMedium,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
