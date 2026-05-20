/// 爱奇艺平台适配器
/// 实现爱奇艺网页端的TV大屏适配逻辑
/// 适配规则由RuleEngine统一管理，避免重复定义
/// 被适配器注册中心管理
library;

import '../core/base/base_adapter.dart';
import '../core/constants/platform_constants.dart';
import '../models/adaptation_config.dart';
import '../models/platform_info.dart';
import '../adaptive/rule_engine.dart';
import '../web/webview_controller.dart';

/// 爱奇艺适配器
/// 提供爱奇艺平台的TV适配规则、导航选择器和URL处理
class IqiyiAdapter extends BasePlatformAdapter {
  @override
  PlatformInfo get platformInfo => const PlatformInfo(
        id: kPlatformIqiyi,
        name: '爱奇艺',
        baseUrl: kIqiyiBaseUrl,
        iconPath: 'assets/icons/iqiyi.png',
        brandColor: kIqiyiBrandColor,
      );

  @override
  AdaptationConfig get adaptationConfig =>
      RuleEngine.instance.getConfig(kPlatformIqiyi) ??
      const AdaptationConfig(platformId: kPlatformIqiyi, rules: []);

  @override
  String getTvHomePageUrl() => kIqiyiBaseUrl;

  @override
  String? handleNavigationRequest(String requestedUrl) {
    if (requestedUrl.contains('iqiyi.com')) {
      return requestedUrl;
    }
    return null;
  }

  @override
  Map<String, String> getSelectorMap() {
    return {
      'navigation': kIqiyiNavSelector,
      'videoCard': kIqiyiVideoCardSelector,
    };
  }

  @override
  Future<bool> checkNeedsReadaptation(TvWebViewController controller) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelector("${kIqiyiNavSelector.split(',').first.trim()}") !== null ? "yes" : "no"',
    );
    return result == null || result == 'no';
  }

  @override
  List<String> getFocusableSelectors() {
    return [
      '.nav-wrap a',
      '.site-pic a',
      '.qy-mod-link',
      'button',
      'a[href]',
    ];
  }
}
