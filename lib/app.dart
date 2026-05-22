/// 应用根组件模块
/// 定义应用的根Widget，管理路由、主题和全局状态
/// 被main.dart调用
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/key_event_handler.dart';
import 'core/navigation/tv_navigation_controller.dart';
import 'core/performance/frame_monitor.dart';
import 'core/performance/memory_manager.dart';
import 'core/performance/startup_optimizer.dart';
import 'core/theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/platform_page.dart';
import 'pages/player_page.dart';
import 'pages/settings_page.dart';

/// 应用路由路径常量
const String kRouteHome = '/';
const String kRoutePlatform = '/platform';
const String kRoutePlayer = '/player';
const String kRouteSettings = '/settings';

/// 应用根组件
/// 管理全局Provider、主题和路由导航
class TvVideoHubApp extends StatelessWidget {
  /// 启动优化器
  final StartupOptimizer startupOptimizer;

  /// 构造函数
  const TvVideoHubApp({super.key, required this.startupOptimizer});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TvNavigationController>(
          create: (_) => TvNavigationController(
            onNavigationAction: _handleGlobalNavigation,
          ),
        ),
        ChangeNotifierProvider<MemoryManager>(
          create: (_) => MemoryManager()..startMonitoring(),
        ),
        ChangeNotifierProvider<FrameMonitor>(
          create: (_) => FrameMonitor()..startMonitoring(),
        ),
      ],
      child: MaterialApp(
          title: kAppName,
          navigatorKey: navigatorKey,
          theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.dark,
        initialRoute: kRouteHome,
        routes: {
          kRouteHome: (_) => const _HomePageWrapper(),
          kRouteSettings: (_) => const SettingsPage(),
        },
        onGenerateRoute: _handleRouteGeneration,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// 处理全局导航动作
  /// 与各页面的PopScope形成双通道导航架构：
  ///   - 遥控器按键通道（本方法）：KeyEventHandler捕获遥控器按键 →
  ///     TvNavigationController → 本方法 → navigatorKey执行页面跳转
  ///   - 系统返回通道（PopScope）：Android系统返回键/手势 →
  ///     PopScope.onPopInvokedWithResult → 页面自定义onGoBack回调
  /// 两个通道互不干扰，确保在不同TV硬件平台上的兼容性
  ///
  /// 导航动作映射：
  ///   - goBack：后退一页（Navigator.pop），与各页面的PopScope.onGoBack行为一致
  ///   - menu：回到首页（popUntil first），符合TV遥控器菜单键的通用交互惯例
  ///   - home：回到首页，与menu行为一致
  ///
  /// 参数：action - 遥控器导航动作
  /// 副作用：执行实际的Navigator页面跳转
  void _handleGlobalNavigation(RemoteKeyAction action) {
    switch (action) {
      case RemoteKeyAction.goBack:
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
          debugPrint('全局导航: 返回上一页');
        }
      case RemoteKeyAction.menu:
      case RemoteKeyAction.home:
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        debugPrint('全局导航: 回到首页');
      case _:
        debugPrint('全局导航动作: $action');
    }
  }

  /// 处理动态路由生成
  /// 参数：settings - 路由设置
  /// 返回：Route? - 生成的路由
  /// 副作用：无
  Route<dynamic>? _handleRouteGeneration(RouteSettings settings) {
    switch (settings.name) {
      case kRoutePlatform:
        final String platformId =
            settings.arguments as String? ?? kDefaultPlatformId;
        return MaterialPageRoute<void>(
          builder: (_) => PlatformPage(
            platformId: platformId,
            onGoBack: () => Navigator.of(
              _getRootContext(),
            ).pop(),
          ),
        );
      case kRoutePlayer:
        final String videoUrl = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(
          builder: (_) => PlayerPage(
            videoUrl: videoUrl,
            onGoBack: () => Navigator.of(
              _getRootContext(),
            ).pop(),
          ),
        );
      default:
        return null;
    }
  }

  /// 获取根Navigator上下文
  /// 返回：BuildContext - 根上下文（使用navigatorKey）
  /// 副作用：无
  BuildContext _getRootContext() {
    return navigatorKey.currentContext!;
  }
}

/// 全局Navigator键，用于在非Widget代码中访问Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 首页包装器
/// 处理首页到平台页面的导航
class _HomePageWrapper extends StatelessWidget {
  const _HomePageWrapper();

  @override
  Widget build(BuildContext context) {
    return HomePage(
      onPlatformSelected: (String platformId) {
        Navigator.of(context).pushNamed(
          kRoutePlatform,
          arguments: platformId,
        );
      },
    );
  }
}
