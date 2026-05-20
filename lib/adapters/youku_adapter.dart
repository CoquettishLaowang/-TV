/// 优酷平台适配器
/// 实现优酷网页端的TV大屏适配逻辑
/// 被适配器注册中心管理
library;

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
import '../web/webview_controller.dart';

/// 优酷适配器
/// 提供优酷平台的TV适配规则、导航选择器和URL处理
class YoukuAdapter extends BasePlatformAdapter {
  @override
  PlatformInfo get platformInfo => const PlatformInfo(
        id: kPlatformYouku,
        name: '优酷',
        baseUrl: kYoukuBaseUrl,
        iconPath: 'assets/icons/youku.png',
        brandColor: kYoukuBrandColor,
      );

  @override
  AdaptationConfig get adaptationConfig => AdaptationConfig(
        platformId: kPlatformYouku,
        rules: _buildRules(),
      );

  /// 构建优酷适配规则列表
  List<AdaptationRule> _buildRules() {
    return [
      const AdaptationRule(
        ruleId: 'youku_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .yk-sidebar, .side-nav',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
      ),
      const AdaptationRule(
        ruleId: 'youku_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.header, .yk-header',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
      ),
      const AdaptationRule(
        ruleId: 'youku_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.video-card, .yk-video-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.15)',
        priority: 10,
      ),
      const AdaptationRule(
        ruleId: 'youku_hide_ad',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad-banner, .yk-ad',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
      ),
    ];
  }

  @override
  String getTvHomePageUrl() => kYoukuBaseUrl;

  @override
  String? handleNavigationRequest(String requestedUrl) {
    if (requestedUrl.contains('youku.com')) {
      return requestedUrl;
    }
    return null;
  }

  @override
  Map<String, String> getSelectorMap() {
    return {
      'navigation': kYoukuNavSelector,
      'videoCard': kYoukuVideoCardSelector,
    };
  }

  @override
  Future<bool> checkNeedsReadaptation(TvWebViewController controller) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelector("${kYoukuNavSelector.split(',').first.trim()}") !== null ? "yes" : "no"',
    );
    return result == null || result == 'no';
  }

  @override
  List<String> getFocusableSelectors() {
    return [
      '.header a',
      '.video-card a',
      '.yk-video-card a',
      'button',
      'a[href]',
    ];
  }
}
