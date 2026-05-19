/// 可聚焦组件模块
/// 提供TV遥控器和手机触控双输入支持的可聚焦包装器
/// TV端：响应遥控器方向键导航、焦点高亮和缩放动画
/// 手机端：响应触摸点击、跳过焦点动画以提升性能
/// 被所有需要交互的UI组件使用

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/responsive/responsive_adapter.dart';
import '../../core/theme/tv_dimensions.dart';

/// TV可聚焦组件
/// 包装子组件，使其同时响应TV遥控器焦点和手机触摸点击
/// 根据设备类型自动选择交互模式
class TvFocusable extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChanged;

  /// 确认键/点击回调
  final VoidCallback? onConfirm;

  /// 自动获取焦点（仅TV模式有效）
  final bool autofocus;

  /// 焦点边框颜色
  final Color? focusBorderColor;

  /// 焦点缩放比例（手机模式忽略）
  final double focusScale;

  /// 外边距
  final EdgeInsetsGeometry margin;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 是否使用涟漪效果（手机模式默认开启）
  final bool useRippleEffect;

  /// 构造函数
  const TvFocusable({
    super.key,
    required this.child,
    this.onFocusChanged,
    this.onConfirm,
    this.autofocus = false,
    this.focusBorderColor,
    this.focusScale = kFocusScaleFactor,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.useRippleEffect = true,
  });

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

/// TvFocusable的状态类
class _TvFocusableState extends State<TvFocusable>
    with SingleTickerProviderStateMixin {
  /// 当前是否获得焦点
  bool _hasFocus = false;

  /// 焦点动画控制器
  late AnimationController _animationController;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

  /// 焦点节点
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: kFocusAnimationDurationMs),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.focusScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 焦点变化处理
  /// 参数：hasFocus - 是否获得焦点
  /// 副作用：更新焦点状态，播放动画，通知外部
  void _handleFocusChange(bool hasFocus) {
    if (_hasFocus == hasFocus) {
      return;
    }
    setState(() {
      _hasFocus = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onFocusChanged?.call(hasFocus);
  }

  /// 处理确认操作（遥控器确认键 或 手机触摸点击）
  /// 副作用：触发onConfirm回调
  void _handleConfirm() {
    // 手机触摸时给予即时反馈：先反向缩放再恢复
    if (_scaleAnimation.value == 1.0) {
      _animationController.value = 0.05;
      _animationController.reverse();
    }
    widget.onConfirm?.call();
  }

  /// 处理按键事件（仅TV遥控器模式）
  /// 参数：node - 焦点节点 / event - 按键事件
  /// 返回：KeyEventResult - 事件处理结果
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select)) {
      _handleConfirm();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color effectiveBorderColor =
        widget.focusBorderColor ?? colorScheme.primary;
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);

    // 构建焦点装饰：有焦点且设备支持焦点效果时显示边框和阴影
    // 手机端enableFocusEffects=false，跳过装饰渲染以提升性能
    final BoxDecoration? focusDecoration =
        _hasFocus && responsiveConfig.enableFocusEffects
        ? BoxDecoration(
            borderRadius:
                BorderRadius.circular(responsiveConfig.focusHighlightBorderRadius),
            border: Border.all(
              color: effectiveBorderColor,
              width: responsiveConfig.focusHighlightBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveBorderColor.withValues(alpha: 0.4),
                blurRadius: kFocusShadowBlurRadius,
                spreadRadius: kFocusShadowSpreadRadius,
              ),
            ],
          )
        : null;

    // 核心组件：带缩放动画的内容
    final Widget animatedContent = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: widget.margin,
        padding: widget.padding,
        decoration: focusDecoration,
        child: widget.child,
      ),
    );

    // 手机端：使用GestureDetector捕获点击
    // 同时在FocusScope中保留焦点能力以支持TV遥控器
    // 使用MergeSemantics确保无障碍访问
    return FocusScope(
      onFocusChange: _handleFocusChange,
      child: GestureDetector(
        onTap: _handleConfirm,
        behavior: HitTestBehavior.opaque,
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onKeyEvent: _handleKeyEvent,
          child: animatedContent,
        ),
      ),
    );
  }
}