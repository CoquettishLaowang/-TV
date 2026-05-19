/// 首页模块
/// 应用主页面，展示所有支持的视频平台入口
/// 用户可通过遥控器选择平台进入

import 'package:flutter/material.dart';

import '../core/base/base_adapter.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/tv_dimensions.dart';
import '../adapters/adapter_registry.dart';
import '../models/platform_info.dart';
import '../widgets/tv_focusable.dart';
import '../widgets/tv_nav_bar.dart';
import '../widgets/tv_scaffold.dart';

/// 首页状态管理
class HomePage extends StatefulWidget {
  /// 平台选择回调
  final ValueChanged<String> onPlatformSelected;

  /// 构造函数
  const HomePage({super.key, required this.onPlatformSelected});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// 首页状态类
class _HomePageState extends State<HomePage> {
  /// 所有平台适配器列表
  late List<BasePlatformAdapter> _adapters;

  /// 当前选中的导航项ID
  String _selectedNavId = 'home';

  @override
  void initState() {
    super.initState();
    _adapters = AdapterRegistry.instance.getAllAdapters();
  }

  /// 导航项列表
  final List<NavItem> _navItems = const [
    NavItem(id: 'home', label: '首页', icon: Icons.home),
    NavItem(id: 'favorites', label: '收藏', icon: Icons.favorite),
    NavItem(id: 'history', label: '历史', icon: Icons.history),
    NavItem(id: 'settings', label: '设置', icon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TvScaffold(
      title: kAppName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TvNavBar(
            items: _navItems,
            selectedItemId: _selectedNavId,
            onItemSelected: _handleNavItemSelected,
          ),
          const SizedBox(height: kCardVerticalSpacing),
          Expanded(
            child: _buildPlatformGrid(colorScheme),
          ),
        ],
      ),
    );
  }

  /// 构建平台选择网格
  /// 参数：colorScheme - 颜色方案
  /// 返回：Widget - 平台网格布局
  /// 副作用：无
  Widget _buildPlatformGrid(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: kPageHorizontalPadding,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kHomeGridColumns,
        childAspectRatio: kVideoCardAspectRatio + 0.4,
        crossAxisSpacing: kCardHorizontalSpacing,
        mainAxisSpacing: kCardVerticalSpacing,
      ),
      itemCount: _adapters.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildPlatformCard(_adapters[index]);
      },
    );
  }

  /// 构建单个平台卡片
  /// 参数：adapter - 平台适配器
  /// 返回：Widget - 平台卡片组件
  /// 副作用：无
  Widget _buildPlatformCard(BasePlatformAdapter adapter) {
    final PlatformInfo info = adapter.platformInfo;
    final Color brandColor = Color(info.brandColor);

    return TvFocusable(
      autofocus: info.id == kDefaultPlatformId,
      onConfirm: () => widget.onPlatformSelected(info.id),
      child: Container(
        decoration: BoxDecoration(
          color: brandColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          border: Border.all(
            color: brandColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Icon(
                  Icons.play_circle_filled,
                  color: brandColor,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  info.name,
                  style: TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理导航项选择
  /// 参数：itemId - 选中的导航项ID
  /// 副作用：更新选中状态
  void _handleNavItemSelected(String itemId) {
    setState(() {
      _selectedNavId = itemId;
    });
  }
}
