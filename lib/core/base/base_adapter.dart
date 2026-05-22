/// 适配器基类模块
/// 定义视频平台适配器的抽象接口，所有平台适配器必须继承此基类
/// 被各平台适配器继承，被适配器注册中心管理
library;

import '../../models/adaptation_config.dart';
import '../../models/platform_info.dart';
import '../../adaptive/css_injector.dart';
import '../../web/webview_controller.dart';

/// 视频平台适配器基类
/// 定义平台适配的统一接口，包括获取平台信息、生成适配CSS、处理导航等
/// 每个视频平台需要实现此基类以提供平台特定的适配逻辑
abstract class BasePlatformAdapter {
  /// 获取平台信息
  /// 返回：PlatformInfo - 当前平台的元数据
  /// 副作用：无
  PlatformInfo get platformInfo;

  /// 获取平台适配配置
  /// 返回：AdaptationConfig - 当前平台的CSS适配规则配置
  /// 副作用：无
  AdaptationConfig get adaptationConfig;

  /// 获取平台的TV适配首页URL
  /// 不同平台可能有不同的TV友好入口页面
  /// 返回：String - TV端首页URL
  /// 副作用：无
  String getTvHomePageUrl();

  /// 应用适配规则到WebView
  /// 将平台特定的CSS适配规则注入到WebView中
  /// 参数：controller - WebView控制器
  /// 副作用：向WebView注入CSS代码
  void applyAdaptation(TvWebViewController controller) {
    final CssInjector injector = CssInjector();
    final String css = injector.generateFullCss(adaptationConfig);
    controller.injectCss(css);
  }

  /// 处理WebView内的导航请求
  /// 判断URL是否允许加载，并可能修改URL以适配TV端
  /// 参数：requestedUrl - 请求加载的URL
  /// 返回：String? - 允许加载时返回处理后的URL，阻止加载时返回null
  /// 副作用：无
  String? handleNavigationRequest(String requestedUrl);

  /// 获取平台特定的CSS选择器映射
  /// 返回：Map<String, String> - 键为元素类型，值为CSS选择器
  /// 副作用：无
  Map<String, String> getSelectorMap();

  /// 检查当前页面是否需要重新适配
  /// 当网页格式变化时，此方法用于检测是否需要更新适配规则
  ///
  /// 设计说明 — 检测策略：
  ///   - 当前实现仅检查导航选择器（如 '.nav-wrap'）是否存在于DOM中
  ///   - 若导航元素不匹配 → 返回true（需要重新适配），否则返回false
  ///   - 这是轻量级的一级检测，配合 DomAnalyzer 的4指标二级检测形成两级验证链：
  ///     DomAnalyzer(粗筛) → checkNeedsReadaptation(二次确认)
  ///   - 局限：仅检测导航选择器，无法判定其他元素（视频卡片、按钮、搜索栏等）的选择器是否失效
  ///   - 后续改进：可扩展为检查多个关键选择器，返回位掩码或选择器列表指示哪些规则可能失效，
  ///     从而实现更精准的增量式规则重注入
  /// 参数：controller - WebView控制器
  /// 返回：Future<bool> - 是否需要重新适配
  /// 副作用：可能执行JavaScript查询DOM结构
  Future<bool> checkNeedsReadaptation(TvWebViewController controller);

  /// 获取平台特定的焦点导航CSS选择器列表
  /// 用于TV遥控器在WebView内导航
  /// 返回：List<String> - 可聚焦元素的CSS选择器列表
  /// 副作用：无
  List<String> getFocusableSelectors();

  /// 处理视频播放请求
  /// 参数：videoUrl - 视频URL / controller - WebView控制器
  /// 副作用：可能修改WebView状态或触发全屏播放
  void handleVideoPlay(String videoUrl, TvWebViewController controller) {
    controller.loadUrl(videoUrl);
  }
}
