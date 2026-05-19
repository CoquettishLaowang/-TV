/// TV脚手架组件模块
/// 提供TV端页面的基础布局结构，包含导航栏、内容区域和底部栏
/// 被所有页面组件使用作为顶层布局容器

import 'package:flutter/material.dart';

import '../../core/theme/tv_dimensions.dart';

/// TV脚手架布局组件
/// 提供统一的TV页面布局结构，自动处理安全区域和TV布局规范
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

  /// 是否应用TV安全区域内边距
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
    return PreferredSize(
      preferredSize: Size(double.infinity, kNavBarHeight),
      child: Container(
        height: kNavBarHeight,
        padding: kTvSafePadding,
        alignment: Alignment.centerLeft,
        child: Text(
          title!,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 28,
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
    return Padding(
      padding: kTvSafePadding,
      child: body,
    );
  }
}
