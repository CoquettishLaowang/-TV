/// TV WebView组件模块
/// 提供TV端WebView展示组件，集成WebView控制器和加载状态管理
/// 被平台页面使用以展示适配后的视频平台网页
library;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/tv_dimensions.dart';
import '../widgets/tv_loading.dart';
import 'webview_controller.dart';

/// TV WebView组件
/// 封装WebView并在TV端展示，自动处理加载状态和错误
class TvWebView extends StatefulWidget {
  /// WebView控制器
  final TvWebViewController controller;

  /// 初始加载URL
  final String initialUrl;

  /// 构造函数
  const TvWebView({
    super.key,
    required this.controller,
    required this.initialUrl,
  });

  @override
  State<TvWebView> createState() => _TvWebViewState();
}

/// TvWebView的状态类
class _TvWebViewState extends State<TvWebView> {
  /// 内部WebView控制器
  late WebViewController _innerController;

  @override
  void initState() {
    super.initState();
    _innerController = WebViewController();
    widget.controller.initialize(_innerController);
    widget.controller.loadUrl(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            WebViewWidget(controller: _innerController),
            if (widget.controller.state == WebViewState.loading)
              _buildLoadingOverlay(),
            if (widget.controller.state == WebViewState.error)
              _buildErrorOverlay(),
          ],
        );
      },
    );
  }

  /// 构建加载中覆盖层
  /// 返回：Widget - 半透明加载覆盖层
  /// 副作用：无
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: kProgressBarHeight,
        ),
      ),
    );
  }

  /// 构建错误覆盖层
  /// 返回：Widget - 错误提示覆盖层
  /// 副作用：无
  Widget _buildErrorOverlay() {
    return TvLoading(
      state: LoadingState.error,
      errorMessage: '页面加载失败',
      onRetry: () => widget.controller.reload(),
    );
  }
}
