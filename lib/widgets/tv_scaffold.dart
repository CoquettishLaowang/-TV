/// TV脚手架组件模块
/// 提供TV端和手机端页面的基础布局结构，包含导航栏、内容区域和底部栏
/// TV端：大间距、大字号，适配遥控器导航
/// 手机端：紧凑布局、标准字号，适配触摸交互
/// 被所有页面组件使用作为顶层布局容器

import 'package:flutter/material.dart';

import '../../core/responsive/responsive_adapter.dart';

/// TV脚手架布局组件
/// 提供统一的页面布局结构，自动根据不同设备调整内边距和字号
class TvScaffold extends StatelessWidget {
  /// 页面标题
  final String? title;

  /// 主体内容区域
  final Widget body;

  /// 顶部导航栏组件，优先级高于title
  final PreferredSizeWidget? appBar;

  /// 底部导航栏组件
  final Widget? bottomBar;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否应用安全区域内边距
  final bool applySafeArea;

  /// 构造函数
  const TvScaffold({
    super.key,
    this.title,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.backgroundColor,
    this.applySafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color effectiveBgColor =
        backgroundColor ?? colorScheme.surface;

    return Scaffold(
      backgroundColor: effectiveBgColor,
      appBar: appBar ?? _buildDefaultAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: bottomBar,
    );
  }

  /// 构建默认AppBar
  /// 参数：context - 构建上下文
  /// 返回：PreferredSizeWidget - 默认应用栏
  /// 副作用：无
  PreferredSizeWidget? _buildDefaultAppBar(BuildContext context) {
    if (title == null) {
      return null;
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);

    return PreferredSize(
      preferredSize: Size(double.infinity, responsiveConfig.navBarHeight),
      child: Container(
        height: responsiveConfig.navBarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveConfig.pageHorizontalPadding,
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          title!,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: responsiveConfig.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建主体内容区域
  /// 参数：context - 构建上下文
  /// 返回：Widget - 包含安全区域的内容区域
  /// 副作用：无
  Widget _buildBody(BuildContext context) {
    if (!applySafeArea) {
      return body;
    }
    final EdgeInsets safePadding = ResponsiveAdapter.safePadding(context);
    return Padding(
      padding: safePadding,
      child: body,
    );
  }
}