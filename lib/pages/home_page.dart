/// 首页模块
/// 应用主页面，展示所有支持的视频平台入口
/// TV端：用户通过遥控器选择平台进入，大网格布局
/// 手机端：用户通过触摸点击选择平台，双列网格布局
library;

import 'package:flutter/material.dart';

import '../core/base/base_adapter.dart';
import '../core/constants/app_constants.dart';
import '../core/responsive/responsive_adapter.dart';
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
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);

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
          SizedBox(height: responsiveConfig.cardVerticalSpacing),
          Expanded(
            child: _buildPlatformGrid(colorScheme, responsiveConfig),
          ),
        ],
      ),
    );
  }

  /// 构建平台选择网格（响应式列数）
  /// 参数：colorScheme - 颜色方案 / responsiveConfig - 响应式配置
  /// 返回：Widget - 平台网格布局
  /// 副作用：无
  Widget _buildPlatformGrid(
      ColorScheme colorScheme, ResponsiveConfig responsiveConfig) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 根据可用宽度动态计算列数，而非使用固定列数
        final int columns =
            ResponsiveConfig.calculateGridColumns(constraints.maxWidth);
        // 根据可用宽度和列数动态计算卡片宽度
        final double availableWidth = constraints.maxWidth -
            responsiveConfig.pageHorizontalPadding * 2;
        final double cardWidth = (availableWidth -
                (columns - 1) * responsiveConfig.cardHorizontalSpacing) /
            columns;
        final double cardHeight =
            cardWidth / responsiveConfig.videoCardAspectRatio + 60;

        return GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveConfig.pageHorizontalPadding,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: responsiveConfig.cardHorizontalSpacing,
            mainAxisSpacing: responsiveConfig.cardVerticalSpacing,
          ),
          itemCount: _adapters.length,
          itemBuilder: (BuildContext context, int index) {
            return RepaintBoundary(
              child: _buildPlatformCard(_adapters[index]),
            );
          },
        );
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
          borderRadius:
              BorderRadius.circular(kCardBorderRadius),
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
                child: FittedBox(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: brandColor,
                  ),
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