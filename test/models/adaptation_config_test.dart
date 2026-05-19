/// AdaptationConfig模型单元测试
/// 验证适配配置和适配规则的数据操作

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/models/adaptation_config.dart';

void main() {
  group('AdaptationRule', () {
    test('应正确创建AdaptationRule实例', () {
      const AdaptationRule rule = AdaptationRule(
        ruleId: 'test_rule_001',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.sidebar',
        cssProperty: 'display',
        cssValue: 'none',
        priority: 15,
        applicablePlatformIds: ['iqiyi'],
      );

      expect(rule.ruleId, 'test_rule_001');
      expect(rule.ruleType, AdaptationRuleType.hideElement);
      expect(rule.cssSelector, '.sidebar');
      expect(rule.priority, 15);
    });

    test('toCssDeclaration应生成正确的CSS声明', () {
      const AdaptationRule rule = AdaptationRule(
        ruleId: 'css_test',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: 'body',
        cssProperty: 'font-size',
        cssValue: '20px',
      );

      final String css = rule.toCssDeclaration();

      expect(css, 'body { font-size: 20px; }');
    });

    test('isApplicableForPlatform空列表应适用于所有平台', () {
      const AdaptationRule rule = AdaptationRule(
        ruleId: 'common_rule',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '*',
        cssProperty: 'color',
        cssValue: 'white',
        applicablePlatformIds: [],
      );

      expect(rule.isApplicableForPlatform('iqiyi'), true);
      expect(rule.isApplicableForPlatform('bilibili'), true);
    });

    test('isApplicableForPlatform指定平台应仅适用于该平台', () {
      const AdaptationRule rule = AdaptationRule(
        ruleId: 'platform_specific',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad',
        cssProperty: 'display',
        cssValue: 'none',
        applicablePlatformIds: ['iqiyi', 'tencent'],
      );

      expect(rule.isApplicableForPlatform('iqiyi'), true);
      expect(rule.isApplicableForPlatform('tencent'), true);
      expect(rule.isApplicableForPlatform('bilibili'), false);
    });

    test('fromJson和toJson应正确序列化和反序列化', () {
      final Map<String, dynamic> jsonMap = {
        'ruleId': 'json_test',
        'ruleType': 'resizeElement',
        'cssSelector': '.card',
        'cssProperty': 'transform',
        'cssValue': 'scale(1.2)',
        'priority': 10,
        'applicablePlatformIds': ['bilibili'],
        'version': 2,
      };

      final AdaptationRule rule = AdaptationRule.fromJson(jsonMap);
      expect(rule.ruleId, 'json_test');
      expect(rule.ruleType, AdaptationRuleType.resizeElement);
      expect(rule.version, 2);

      final Map<String, dynamic> serialized = rule.toJson();
      expect(serialized['ruleId'], 'json_test');
      expect(serialized['ruleType'], 'resizeElement');
    });
  });

  group('AdaptationConfig', () {
    test('getSortedRules应按优先级从高到低排序', () {
      final AdaptationConfig config = AdaptationConfig(
        platformId: 'test',
        rules: [
          const AdaptationRule(
            ruleId: 'low_priority',
            ruleType: AdaptationRuleType.modifyFontSize,
            cssSelector: 'body',
            cssProperty: 'font-size',
            cssValue: '20px',
            priority: 5,
          ),
          const AdaptationRule(
            ruleId: 'high_priority',
            ruleType: AdaptationRuleType.hideElement,
            cssSelector: '.ad',
            cssProperty: 'display',
            cssValue: 'none',
            priority: 20,
          ),
          const AdaptationRule(
            ruleId: 'mid_priority',
            ruleType: AdaptationRuleType.resizeElement,
            cssSelector: '.card',
            cssProperty: 'transform',
            cssValue: 'scale(1.1)',
            priority: 10,
          ),
        ],
      );

      final List<AdaptationRule> sorted = config.getSortedRules();

      expect(sorted[0].ruleId, 'high_priority');
      expect(sorted[1].ruleId, 'mid_priority');
      expect(sorted[2].ruleId, 'low_priority');
    });

    test('generateCss应生成包含所有规则的CSS代码', () {
      final AdaptationConfig config = AdaptationConfig(
        platformId: 'test',
        rules: [
          const AdaptationRule(
            ruleId: 'rule_a',
            ruleType: AdaptationRuleType.hideElement,
            cssSelector: '.sidebar',
            cssProperty: 'display',
            cssValue: 'none',
          ),
          const AdaptationRule(
            ruleId: 'rule_b',
            ruleType: AdaptationRuleType.modifyFontSize,
            cssSelector: 'body',
            cssProperty: 'font-size',
            cssValue: '20px',
          ),
        ],
      );

      final String css = config.generateCss();

      expect(css, contains('.sidebar { display: none; }'));
      expect(css, contains('body { font-size: 20px; }'));
    });

    test('copyWith应正确创建副本', () {
      final AdaptationConfig original = AdaptationConfig(
        platformId: 'iqiyi',
        rules: [
          const AdaptationRule(
            ruleId: 'rule_1',
            ruleType: AdaptationRuleType.hideElement,
            cssSelector: '.ad',
            cssProperty: 'display',
            cssValue: 'none',
          ),
        ],
        configVersion: 1,
      );

      final AdaptationConfig copied = original.copyWith(configVersion: 2);

      expect(copied.platformId, 'iqiyi');
      expect(copied.configVersion, 2);
      expect(copied.rules.length, 1);
    });
  });
}
