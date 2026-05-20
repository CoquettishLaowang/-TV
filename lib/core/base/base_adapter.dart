/// 适配器基类模块
/// 定义视频平台适配器的抽象接口，所有平台适配器必须继承此基类
/// 被各平台适配器继承，被适配器注册中心管理
library;

import '../../models/adaptation_config.dart';
import '../../models/platform_info.dart';
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
    final String css = adaptationConfig.generateCss();
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
