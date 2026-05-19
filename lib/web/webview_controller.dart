/// WebView控制器模块
/// 封装WebView的核心控制逻辑，包括页面加载、CSS注入、JS桥接通信
/// 被TV WebView组件和平台适配器使用

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'js_bridge.dart';

/// WebView状态枚举
enum WebViewState {
  /// 初始状态，未加载任何页面
  initial,

  /// 正在加载页面
  loading,

  /// 页面加载完成
  loaded,

  /// 加载失败
  error,
}

/// TV WebView控制器
/// 管理WebView的生命周期、页面加载和适配规则注入
class TvWebViewController extends ChangeNotifier {
  /// WebView控制器实例
  WebViewController? _webViewController;

  /// 当前WebView状态
  WebViewState _state = WebViewState.initial;

  /// 当前加载的URL
  String _currentUrl = '';

  /// JS桥接消息回调
  final void Function(JsBridgeMessage message)? onBridgeMessage;

  /// 获取当前WebView状态
  WebViewState get state => _state;

  /// 获取当前URL
  String get currentUrl => _currentUrl;

  /// 构造函数
  /// 参数：onBridgeMessage - JS桥接消息回调（可选）
  /// 副作用：无
  TvWebViewController({this.onBridgeMessage});

  /// 初始化WebView控制器
  /// 参数：controller - WebViewController实例
  /// 副作用：配置WebView设置和JavaScript通道
  void initialize(WebViewController controller) {
    _webViewController = controller;
    _configureWebView();
  }

  /// 配置WebView基础设置
  /// 副作用：设置JavaScript启用、User-Agent等
  void _configureWebView() {
    if (_webViewController == null) {
      return;
    }
    _webViewController!.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController!.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: _handlePageStarted,
        onPageFinished: _handlePageFinished,
        onWebResourceError: _handleResourceError,
      ),
    );
    _setupJavaScriptChannel();
  }

  /// 设置JavaScript通信通道
  /// 副作用：注册TvBridge通道
  void _setupJavaScriptChannel() {
    if (_webViewController == null) {
      return;
    }
    _webViewController!.addJavaScriptChannel(
      'TvBridge',
      onMessageReceived: _handleJavaScriptMessage,
    );
  }

  /// 处理JavaScript消息
  /// 参数：message - JavaScript通道消息
  /// 副作用：解析消息并通知外部
  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final JsBridgeMessage bridgeMessage =
          JsBridgeMessage.fromJsonString(message.message);
      onBridgeMessage?.call(bridgeMessage);
    } on FormatException {
      debugPrint('JS桥接消息解析失败: ${message.message}');
    }
  }

  /// 页面开始加载回调
  /// 参数：url - 开始加载的URL
  /// 副作用：更新状态为loading
  void _handlePageStarted(String url) {
    _currentUrl = url;
    _updateState(WebViewState.loading);
  }

  /// 页面加载完成回调
  /// 参数：url - 加载完成的URL
  /// 副作用：更新状态为loaded，注入JS桥接脚本
  void _handlePageFinished(String url) {
    _currentUrl = url;
    _updateState(WebViewState.loaded);
    _injectBridgeScripts();
  }

  /// 资源加载错误回调
  /// 参数：error - Web资源错误信息
  /// 副作用：更新状态为error
  void _handleResourceError(WebResourceError error) {
    debugPrint('WebView资源加载错误: ${error.description}');
    _updateState(WebViewState.error);
  }

  /// 注入JS桥接脚本
  /// 在页面加载完成后注入DOM观察器和视频状态监听
  /// 副作用：向WebView注入JavaScript代码
  void _injectBridgeScripts() {
    if (_webViewController == null) {
      return;
    }
    _webViewController!.runJavaScript(
      JsBridgeScriptGenerator.generateDomObserverScript(),
    );
    _webViewController!.runJavaScript(
      JsBridgeScriptGenerator.generateVideoStatusScript(),
    );
  }

  /// 加载指定URL
  /// 参数：url - 要加载的网页URL
  /// 副作用：触发WebView页面加载
  void loadUrl(String url) {
    if (_webViewController == null) {
      return;
    }
    _currentUrl = url;
    _webViewController!.loadRequest(Uri.parse(url));
  }

  /// 注入CSS适配规则
  /// 参数：cssContent - 要注入的CSS代码
  /// 副作用：向WebView注入CSS样式
  void injectCss(String cssContent) {
    if (_webViewController == null || cssContent.isEmpty) {
      return;
    }
    final String script =
        JsBridgeScriptGenerator.generateCssInjectionScript(cssContent);
    _webViewController!.runJavaScript(script);
  }

  /// 执行JavaScript代码
  /// 参数：script - JavaScript代码
  /// 返回：Future<String?> - 执行结果
  /// 副作用：在WebView中执行JavaScript
  Future<String?> executeJavaScript(String script) async {
    if (_webViewController == null) {
      return null;
    }
    final Object result =
        await _webViewController!.runJavaScriptReturningResult(script);
    return result.toString();
  }

  /// 高亮指定元素
  /// 参数：selector - CSS选择器
  /// 副作用：在WebView中高亮指定元素
  void highlightElement(String selector) {
    if (_webViewController == null) {
      return;
    }
    final String script =
        JsBridgeScriptGenerator.generateFocusHighlightScript(selector);
    _webViewController!.runJavaScript(script);
  }

  /// 刷新当前页面
  /// 副作用：重新加载WebView页面
  void reload() {
    _webViewController?.reload();
  }

  /// 更新WebView状态并通知监听器
  /// 参数：newState - 新的WebView状态
  /// 副作用：修改状态，通知监听器
  void _updateState(WebViewState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
