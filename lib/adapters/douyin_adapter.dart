/// 抖音平台适配器
/// 实现抖音网页端的TV大屏适配逻辑
/// 适配规则由RuleEngine统一管理，避免重复定义
/// 被适配器注册中心管理
library;

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
import '../adaptive/rule_engine.dart';
import '../web/webview_controller.dart';

/// 抖音适配器
/// 提供抖音平台的TV适配规则、导航选择器和URL处理
class DouyinAdapter extends BasePlatformAdapter {
  @override
  PlatformInfo get platformInfo => const PlatformInfo(
        id: kPlatformDouyin,
        name: '抖音',
        baseUrl: kDouyinBaseUrl,
        iconPath: 'assets/icons/douyin.png',
        brandColor: kDouyinBrandColor,
      );

  @override
  AdaptationConfig get adaptationConfig =>
      RuleEngine.instance.getConfig(kPlatformDouyin) ??
      const AdaptationConfig(platformId: kPlatformDouyin, rules: []);

  @override
  String getTvHomePageUrl() => kDouyinBaseUrl;

  @override
  String? handleNavigationRequest(String requestedUrl) {
    if (requestedUrl.contains('douyin.com')) {
      return requestedUrl;
    }
    return null;
  }

  @override
  Map<String, String> getSelectorMap() {
    return {
      'navigation': kDouyinNavSelector,
      'videoCard': kDouyinVideoCardSelector,
    };
  }

  @override
  Future<bool> checkNeedsReadaptation(TvWebViewController controller) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelector("${kDouyinNavSelector.split(',').first.trim()}") !== null ? "yes" : "no"',
    );
    return result == null || result == 'no';
  }

  @override
  List<String> getFocusableSelectors() {
    return [
      '.header a',
      '.feed-card a',
      '.video-card a',
      'button',
      'a[href]',
    ];
  }
}
