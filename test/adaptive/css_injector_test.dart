/// CssInjector单元测试
/// 验证CSS注入器的CSS生成和注入功能
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/adaptive/css_injector.dart';
import 'package:tv_video_hub/models/adaptation_config.dart';

void main() {
  group('CssInjector', () {
    late CssInjector cssInjector;

    setUp(() {
      cssInjector = CssInjector();
    });

    test('generateFullCss应包含TV基础CSS', () {
      const AdaptationConfig config = AdaptationConfig(
        platformId: 'test_platform',
        rules: [],
      );

      final String css = cssInjector.generateFullCss(config);

      expect(css, contains('TV Video Hub'));
      expect(css, contains('test_platform'));
      expect(css, contains('-webkit-tap-highlight-color'));
    });

    test('generateFullCss应包含平台特定规则', () {
      const AdaptationConfig config = AdaptationConfig(
        platformId: 'iqiyi',
        rules: [
          AdaptationRule(
            ruleId: 'test_hide',
            ruleType: AdaptationRuleType.hideElement,
            cssSelector: '.sidebar',
            cssProperty: 'display',
            cssValue: 'none',
          ),
        ],
      );

      final String css = cssInjector.generateFullCss(config);

      expect(css, contains('.sidebar'));
      expect(css, contains('display'));
      expect(css, contains('none'));
    });

    test('generateFullCss应包含配置版本注释', () {
      const AdaptationConfig config = AdaptationConfig(
        platformId: 'bilibili',
        rules: [],
        configVersion: 3,
      );

      final String css = cssInjector.generateFullCss(config);

      expect(css, contains('版本: 3'));
    });

    test('generateFullCss空规则列表应仅包含基础CSS', () {
      const AdaptationConfig config = AdaptationConfig(
        platformId: 'empty',
        rules: [],
      );

      final String css = cssInjector.generateFullCss(config);

      expect(css, contains('overflow-x'));
      expect(css, contains('scrollbar'));
    });

    test('generateFullCss多条规则应全部包含', () {
      const AdaptationConfig config = AdaptationConfig(
        platformId: 'multi',
        rules: [
          AdaptationRule(
            ruleId: 'rule_a',
            ruleType: AdaptationRuleType.hideElement,
            cssSelector: '.ad',
            cssProperty: 'display',
            cssValue: 'none',
          ),
          AdaptationRule(
            ruleId: 'rule_b',
            ruleType: AdaptationRuleType.modifyFontSize,
            cssSelector: 'body',
            cssProperty: 'font-size',
            cssValue: '24px',
          ),
          AdaptationRule(
            ruleId: 'rule_c',
            ruleType: AdaptationRuleType.resizeElement,
            cssSelector: '.card',
            cssProperty: 'transform',
            cssValue: 'scale(1.2)',
          ),
        ],
      );

      final String css = cssInjector.generateFullCss(config);

      expect(css, contains('.ad'));
      expect(css, contains('body'));
      expect(css, contains('.card'));
    });
  });
}
