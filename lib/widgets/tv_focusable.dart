/// 可聚焦组件模块
/// 提供TV遥控器可聚焦的组件包装器，处理焦点高亮和缩放动画
/// 被所有需要TV遥控器导航的UI组件使用

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/tv_dimensions.dart';

/// TV可聚焦组件
/// 包装子组件，使其响应TV遥控器焦点，显示焦点高亮和缩放效果
class TvFocusable extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChanged;

  /// 确认键回调
  final VoidCallback? onConfirm;

  /// 自动获取焦点
  final bool autofocus;

  /// 焦点边框颜色
  final Color? focusBorderColor;

  /// 焦点缩放比例
  final double focusScale;

  /// 外边距
  final EdgeInsetsGeometry margin;

  /// 内边距
  final EdgeInsetsGeometry padding;

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color effectiveBorderColor =
        widget.focusBorderColor ?? colorScheme.primary;

    return Focus(
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kFocusHighlightBorderRadius),
          border: _hasFocus
              ? Border.all(
                  color: effectiveBorderColor,
                  width: kFocusHighlightBorderWidth,
                )
              : null,
          boxShadow: _hasFocus
              ? [
                  BoxShadow(
                    color: effectiveBorderColor.withValues(alpha: 0.4),
                    blurRadius: kFocusShadowBlurRadius,
                    spreadRadius: kFocusShadowSpreadRadius,
                  ),
                ]
              : null,
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: FocusScope(
            onFocusChange: _handleFocusChange,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  /// 处理按键事件
  /// 参数：node - 焦点节点 / event - 按键事件
  /// 返回：KeyEventResult - 事件处理结果
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select)) {
      widget.onConfirm?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
