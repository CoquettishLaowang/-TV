/// 哔哩哔哩平台适配器
/// 实现哔哩哔哩网页端的TV大屏适配逻辑
/// 适配规则由RuleEngine统一管理，避免重复定义
/// 被适配器注册中心管理
library;

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
import '../adaptive/rule_engine.dart';
import '../web/webview_controller.dart';

/// 哔哩哔哩适配器
/// 提供哔哩哔哩平台的TV适配规则、导航选择器和URL处理
class BilibiliAdapter extends BasePlatformAdapter {
  @override
  PlatformInfo get platformInfo => const PlatformInfo(
        id: kPlatformBilibili,
        name: '哔哩哔哩',
        baseUrl: kBilibiliBaseUrl,
        iconPath: 'assets/icons/bilibili.png',
        brandColor: kBilibiliBrandColor,
      );

  @override
  AdaptationConfig get adaptationConfig =>
      RuleEngine.instance.getConfig(kPlatformBilibili) ??
      const AdaptationConfig(platformId: kPlatformBilibili, rules: []);

  @override
  String getTvHomePageUrl() => kBilibiliBaseUrl;

  @override
  String? handleNavigationRequest(String requestedUrl) {
    if (requestedUrl.contains('bilibili.com')) {
      return requestedUrl;
    }
    return null;
  }

  @override
  Map<String, String> getSelectorMap() {
    return {
      'navigation': kBilibiliNavSelector,
      'videoCard': kBilibiliVideoCardSelector,
    };
  }

  @override
  Future<bool> checkNeedsReadaptation(TvWebViewController controller) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelector("${kBilibiliNavSelector.split(',').first.trim()}") !== null ? "yes" : "no"',
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
