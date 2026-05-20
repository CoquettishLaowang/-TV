/// 平台页面模块
/// 展示选定视频平台的WebView内容，应用TV适配规则
/// 被首页导航调用
library;

import 'package:flutter/material.dart';

import '../adapters/adapter_registry.dart';
import '../core/base/base_adapter.dart';
import '../adaptive/css_injector.dart';
import '../adaptive/rule_engine.dart';
import '../web/tv_webview.dart';
import '../web/webview_controller.dart';
import '../widgets/tv_scaffold.dart';

/// 平台页面
/// 加载选定视频平台的WebView并应用TV适配CSS
class PlatformPage extends StatefulWidget {
  /// 当前选中的平台ID
  final String platformId;

  /// 返回首页回调
  final VoidCallback onGoBack;

  /// 构造函数
  const PlatformPage({
    super.key,
    required this.platformId,
    required this.onGoBack,
  });

  @override
  State<PlatformPage> createState() => _PlatformPageState();
}

/// 平台页面状态类
class _PlatformPageState extends State<PlatformPage> {
  /// WebView控制器
  late TvWebViewController _webViewController;

  /// 平台适配器
  BasePlatformAdapter? _adapter;

  /// CSS注入器
  final CssInjector _cssInjector = CssInjector();

  /// 规则引擎
  final RuleEngine _ruleEngine = RuleEngine();

  @override
  void initState() {
    super.initState();
    _webViewController = TvWebViewController(
      onBridgeMessage: _handleBridgeMessage,
    );
    _adapter = AdapterRegistry.instance.getAdapter(widget.platformId);
    _initializeAsync();
  }

  /// 异步初始化
  /// 加载规则引擎并注入适配CSS
  /// 副作用：初始化规则引擎
  Future<void> _initializeAsync() async {
    await _ruleEngine.initialize();
    _applyAdaptation();
  }

  /// 处理JS桥接消息
  /// 参数：message - 桥接消息
  /// 副作用：根据消息类型执行相应操作
  void _handleBridgeMessage(dynamic message) {
    debugPrint('收到WebView桥接消息: $message');
  }

  @override
  Widget build(BuildContext context) {
    final String platformName = _adapter?.platformInfo.name ?? '未知平台';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          widget.onGoBack();
        }
      },
      child: TvScaffold(
        title: platformName,
        applySafeArea: false,
        body: _buildBody(),
      ),
    );
  }

  /// 构建页面主体
  /// 返回：Widget - WebView或加载状态
  /// 副作用：无
  Widget _buildBody() {
    if (_adapter == null) {
      return const Center(
        child: Text('平台适配器未找到'),
      );
    }

    final String homeUrl = _adapter!.getTvHomePageUrl();

    return TvWebView(
      controller: _webViewController,
      initialUrl: homeUrl,
    );
  }

  /// WebView页面加载完成后注入适配CSS
  /// 副作用：向WebView注入CSS代码
  void _applyAdaptation() {
    if (_adapter == null) {
      return;
    }
    _adapter!.applyAdaptation(_webViewController);

    final List<String> focusableSelectors = _adapter!.getFocusableSelectors();
    _cssInjector.injectFocusStyles(_webViewController, focusableSelectors);
  }

  @override
  void dispose() {
    _webViewController.dispose();
    super.dispose();
  }
}
