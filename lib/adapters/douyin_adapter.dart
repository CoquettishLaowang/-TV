/// 抖音平台适配器
/// 实现抖音网页端的TV大屏适配逻辑
/// 被适配器注册中心管理
library;

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
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
  AdaptationConfig get adaptationConfig => AdaptationConfig(
        platformId: kPlatformDouyin,
        rules: _buildRules(),
      );

  /// 构建抖音适配规则列表
  List<AdaptationRule> _buildRules() {
    return [
      const AdaptationRule(
        ruleId: 'douyin_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-nav, .left-nav',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
      ),
      const AdaptationRule(
        ruleId: 'douyin_resize_feed',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.feed-card, .video-card',
        cssProperty: 'transform',
        cssValue: 'scale(1.2)',
        priority: 10,
      ),
      const AdaptationRule(
        ruleId: 'douyin_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.header, .nav-container',
        cssProperty: 'font-size',
        cssValue: '24px',
        priority: 12,
      ),
      const AdaptationRule(
        ruleId: 'douyin_hide_recommend',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.recommend-sidebar, .related-panel',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
      ),
    ];
  }

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
