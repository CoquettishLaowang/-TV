/// 腾讯视频平台适配器
/// 实现腾讯视频网页端的TV大屏适配逻辑
/// 被适配器注册中心管理

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
import '../web/webview_controller.dart';

/// 腾讯视频适配器
/// 提供腾讯视频平台的TV适配规则、导航选择器和URL处理
class TencentAdapter extends BasePlatformAdapter {
  @override
  PlatformInfo get platformInfo => const PlatformInfo(
        id: kPlatformTencent,
        name: '腾讯视频',
        baseUrl: kTencentBaseUrl,
        iconPath: 'assets/icons/tencent.png',
        brandColor: kTencentBrandColor,
      );

  @override
  AdaptationConfig get adaptationConfig => AdaptationConfig(
        platformId: kPlatformTencent,
        rules: _buildRules(),
        configVersion: 1,
      );

  /// 构建腾讯视频适配规则列表
  List<AdaptationRule> _buildRules() {
    return [
      AdaptationRule(
        ruleId: 'tencent_hide_sidebar',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar, .side-bar, .mod-side',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 15,
      ),
      AdaptationRule(
        ruleId: 'tencent_resize_cards',
        ruleType: AdaptationRuleType.resizeElement,
        cssSelector: '.list_item, .figure',
        cssProperty: 'transform',
        cssValue: 'scale(1.2)',
        priority: 10,
      ),
      AdaptationRule(
        ruleId: 'tencent_hide_ad',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad-banner, .mod-ad',
        cssProperty: 'display',
        cssValue: 'none !important',
        priority: 20,
      ),
      AdaptationRule(
        ruleId: 'tencent_resize_nav',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.site-header, .nav_inner',
        cssProperty: 'font-size',
        cssValue: '22px',
        priority: 12,
      ),
    ];
  }

  @override
  String getTvHomePageUrl() => '$kTencentBaseUrl';

  @override
  String? handleNavigationRequest(String requestedUrl) {
    if (requestedUrl.contains('qq.com')) {
      return requestedUrl;
    }
    return null;
  }

  @override
  Map<String, String> getSelectorMap() {
    return {
      'navigation': kTencentNavSelector,
      'videoCard': kTencentVideoCardSelector,
    };
  }

  @override
  Future<bool> checkNeedsReadaptation(TvWebViewController controller) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelector("${kTencentNavSelector.split(',').first.trim()}") !== null ? "yes" : "no"',
    );
    return result == null || result == 'no';
  }

  @override
  List<String> getFocusableSelectors() {
    return [
      '.site-header a',
      '.list_item a',
      '.figure a',
      'button',
      'a[href]',
    ];
  }
}
