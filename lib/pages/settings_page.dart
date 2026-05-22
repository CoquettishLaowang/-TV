/// 设置页面模块
/// 应用设置页面，提供主题切换、缓存清理、关于信息等
/// 被导航栏的设置入口调用
/// TV端：大间距、大字号适配遥控器导航
/// 手机端：紧凑布局、标准字号适配触摸交互
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/performance/memory_manager.dart';
import '../core/responsive/responsive_adapter.dart';
import '../widgets/tv_focusable.dart';
import '../widgets/tv_scaffold.dart';

/// 设置项数据模型
class SettingItem {
  /// 设置项标题
  final String title;

  /// 设置项副标题
  final String? subtitle;

  /// 设置项图标
  final IconData icon;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构造函数
  const SettingItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });
}

/// 设置页面
/// 展示应用设置选项，支持TV遥控器导航和手机触摸点击
class SettingsPage extends StatefulWidget {
  /// 构造函数
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// 设置页面状态类
class _SettingsPageState extends State<SettingsPage> {
  /// 当前主题模式
  ThemeMode _currentThemeMode = ThemeMode.dark;

  /// 内存管理器
  /// 设计说明：当前创建独立的MemoryManager实例用于展示内存信息
  ///   - 与Provider注入的全局MemoryManager（app.dart中）是不同的实例
  ///   - 优点：不依赖Provider上下文，设置页可独立获取内存快照
  ///   - 权衡：捕捉的是本实例的瞬时快照，与全局监控器的历史数据不同步
  ///   - 如需统一数据源，可改为通过 context.read<MemoryManager>() 获取Provider单例
  final MemoryManager _memoryManager = MemoryManager();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 从SharedPreferences加载设置
  /// 副作用：更新_currentThemeMode
  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String themeString =
        prefs.getString(kPrefKeyThemeMode) ?? 'dark';
    if (mounted) {
      setState(() {
        _currentThemeMode = themeString == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);
    final List<SettingItem> settings = _buildSettingsList();

    return TvScaffold(
      title: '设置',
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveConfig.pageHorizontalPadding,
        ),
        itemCount: settings.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildSettingItem(settings[index], colorScheme, responsiveConfig);
        },
      ),
    );
  }

  /// 构建设置项列表
  /// 返回：List<SettingItem> - 设置项列表
  /// 副作用：无
  List<SettingItem> _buildSettingsList() {
    return [
      SettingItem(
        title: '主题模式',
        subtitle: _currentThemeMode == ThemeMode.dark ? '深色模式' : '浅色模式',
        icon: Icons.dark_mode,
        onTap: _handleThemeToggle,
      ),
      SettingItem(
        title: '清除缓存',
        subtitle: '清除应用缓存数据',
        icon: Icons.cleaning_services,
        onTap: _handleClearCache,
      ),
      SettingItem(
        title: '内存信息',
        subtitle: '当前内存使用: ${_memoryManager.currentMemoryMb.toStringAsFixed(1)}MB',
        icon: Icons.memory,
      ),
      SettingItem(
        title: '恢复默认设置',
        subtitle: '重置所有设置为默认值',
        icon: Icons.restore,
        onTap: _handleResetSettings,
      ),
      const SettingItem(
        title: '关于',
        subtitle: '$kAppName v$kAppVersion',
        icon: Icons.info_outline,
      ),
    ];
  }

  /// 构建单个设置项
  /// 参数：item - 设置项数据 / colorScheme - 颜色方案 / responsiveConfig - 响应式配置
  /// 返回：Widget - 设置项组件
  /// 副作用：无
  Widget _buildSettingItem(
      SettingItem item, ColorScheme colorScheme, ResponsiveConfig responsiveConfig) {
    final double settingsItemHeight = responsiveConfig.navBarItemHeight + 16;

    return TvFocusable(
      onConfirm: item.onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: settingsItemHeight,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveConfig.pageHorizontalPadding * 0.75,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: responsiveConfig.iconSizeMedium,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: responsiveConfig.bodyFontSize + 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: responsiveConfig.bodyFontSize - 2,
                      ),
                    ),
                ],
              ),
            ),
            if (item.onTap != null)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  /// 处理主题切换
  /// 副作用：修改主题模式，保存到SharedPreferences
  Future<void> _handleThemeToggle() async {
    final ThemeMode newMode =
        _currentThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _currentThemeMode = newMode;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kPrefKeyThemeMode,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// 处理清除缓存
  /// 副作用：清除图片缓存和SharedPreferences缓存
  Future<void> _handleClearCache() async {
    PaintingBinding.instance.imageCache.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kPrefKeyAdaptationTimestamp);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清除')),
      );
    }
  }

  /// 处理恢复默认设置
  /// 副作用：重置所有SharedPreferences设置
  Future<void> _handleResetSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool(kPrefKeyFirstLaunch, false);
    if (mounted) {
      setState(() {
        _currentThemeMode = ThemeMode.dark;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已恢复默认')),
      );
    }
  }

  @override
  void dispose() {
    // 设置页创建的MemoryManager实例仅用于获取瞬时内存快照(currentMemoryMb)
    // 未调用startMonitoring()故无周期性Timer，但dispose()会清理NotifyListeners和内部资源
    // 这与MemoryManager的设计契约一致：无论是否启动监控，dispose()都是安全且必要的
    _memoryManager.dispose();
    super.dispose();
  }
}