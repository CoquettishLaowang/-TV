/// 平台页面模块
/// 展示选定视频平台的WebView内容，应用TV适配规则
/// 当检测到网页格式变化时自动触发重新适配
/// 被首页导航调用
library;

import 'package:flutter/material.dart';

import '../adapters/adapter_registry.dart';
import '../core/base/base_adapter.dart';
import '../models/adaptation_config.dart';
import '../adaptive/css_injector.dart';
import '../adaptive/dom_analyzer.dart';
import '../adaptive/rule_engine.dart';
import '../web/js_bridge.dart';
import '../web/tv_webview.dart';
import '../web/webview_controller.dart';
import '../widgets/tv_scaffold.dart';

/// 平台页面
/// 加载选定视频平台的WebView并应用TV适配CSS
///
/// 架构说明 — WebView内遥控器导航：
///   - 当前WebView内的DOM元素焦点导航由注入的CSS焦点样式(.tv-focus-highlight)提供视觉反馈
///   - Flutter层的TvNavigationController仅管理Flutter Widget的导航节点，无法直接控制WebView内DOM
///   - WebView内焦点移动需通过JS桥接实现：Flutter发送方向命令 → JS在DOM元素间切换焦点样式
///   - 已预留 TvBridge 通信通道和 tv-focus-highlight CSS类，后续版本可在此添加WebView内导航逻辑
///
/// 架构说明 — 重新适配机制：
///   - 当DomAnalyzer检测到页面格式变化(差异度≥0.5)时，_performReadaptation()会检查适配器状态并重新注入CSS
///   - 当前重新适配策略为"重注入现有规则 + 规则版本号递增"，不生成新规则
///   - 因为每个CSS规则使用多候选选择器(如.nav-wrap, .header-nav)，覆盖了同一元素的不同类名变体
///   - 大部分平台改版仅修改类名而不改变DOM语义结构，多候选选择器可吸收此类小改动
///   - 对于大规模改版需要新增规则，可通过 RuleEngine.addRule() 在后续版本中动态添加
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

  /// DOM分析器，用于检测网页格式变化
  final DomAnalyzer _domAnalyzer = DomAnalyzer();

  /// 规则引擎单例引用，统一管理适配规则
  RuleEngine get _ruleEngine => RuleEngine.instance;

  @override
  void initState() {
    super.initState();
    _adapter = AdapterRegistry.instance.getAdapter(widget.platformId);
    _webViewController = TvWebViewController(
      onBridgeMessage: _handleBridgeMessage,
      onPageFinished: _applyAdaptation,
    );
  }

  /// 处理JS桥接消息
  /// 当检测到DOM结构变化时，触发重新适配检测与CSS注入
  /// 参数：message - JsBridgeMessage桥接消息
  /// 副作用：可能捕获DOM快照并重新注入CSS
  void _handleBridgeMessage(JsBridgeMessage message) {
    if (message.messageType == JsBridgeMessageType.domChanged) {
      _handleDomChange();
    } else if (message.messageType == JsBridgeMessageType.pageLoaded) {
      _captureInitialSnapshot();
    }
    debugPrint('TV Bridge: ${message.messageType.name}');
  }

  /// 处理DOM结构变化
  /// 捕获当前DOM快照，对比之前快照检测是否发生显著变化
  /// 若检测到变化则触发重新适配流程
  /// 副作用：捕获DOM快照，可能重新注入CSS
  Future<void> _handleDomChange() async {
    if (_adapter == null || _webViewController.state != WebViewState.loaded) {
      return;
    }

    final DomSnapshot currentSnapshot = await _domAnalyzer.captureSnapshot(
      _webViewController,
      widget.platformId,
    );

    final bool hasChanged = _domAnalyzer.hasSignificantChange(
      widget.platformId,
      currentSnapshot,
    );

    if (!hasChanged) {
      return;
    }

    debugPrint('检测到${widget.platformId}页面格式变化，开始重新适配...');
    await _performReadaptation();
    debugPrint('${widget.platformId}重新适配完成');
  }

  /// 页面加载完成后捕获初始DOM快照
  /// 作为后续变化检测的基准快照
  /// 副作用：捕获DOM基准快照
  Future<void> _captureInitialSnapshot() async {
    await _domAnalyzer.captureSnapshot(
      _webViewController,
      widget.platformId,
    );
    debugPrint('${widget.platformId}初始DOM快照已捕获');
  }

  /// 执行重新适配流程
  /// 1. 检测适配器是否需要更新规则
  /// 2. 重新注入CSS适配样式
  /// 3. 重新注入焦点样式
  /// 副作用：向WebView重新注入CSS
  Future<void> _performReadaptation() async {
    if (_adapter == null) {
      return;
    }

    final bool needsUpdate = await _adapter!.checkNeedsReadaptation(
      _webViewController,
    );

    if (needsUpdate) {
      final AdaptationConfig currentConfig = _adapter!.adaptationConfig;
      final AdaptationConfig updatedConfig = currentConfig.copyWith(
        configVersion: currentConfig.configVersion + 1,
        lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _ruleEngine.updateConfig(widget.platformId, updatedConfig);
    }

    _applyAdaptation();
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

  /// WebView页面加载完成后注入适配CSS并捕获DOM基准快照
  /// 使用generateAllPlatformCss一次性生成全部CSS，避免多次runJavaScript导致的不可靠问题
  /// 副作用：向WebView注入CSS代码，捕获初始DOM快照
  void _applyAdaptation() {
    if (_adapter == null) {
      return;
    }

    final List<String> focusableSelectors = _adapter!.getFocusableSelectors();
    final String allCss = _cssInjector.generateAllPlatformCss(
      _adapter!.adaptationConfig,
      focusableSelectors,
    );
    _webViewController.injectCss(allCss);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureInitialSnapshot();
    });
  }

  @override
  void dispose() {
    _webViewController.dispose();
    super.dispose();
  }
}
