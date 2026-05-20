/// RuleEngine单元测试
/// 验证自适应规则引擎的初始化、规则管理和CSS生成功能
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/adaptive/rule_engine.dart';
import 'package:tv_video_hub/models/adaptation_config.dart';

void main() {
  group('RuleEngine', () {
    late RuleEngine ruleEngine;

    setUp(() {
      ruleEngine = RuleEngine();
    });

    tearDown(() {
      ruleEngine.clearCache();
    });

    test('初始状态应未初始化', () {
      expect(ruleEngine.isInitialized, false);
    });

    test('initialize后应标记为已初始化', () async {
      await ruleEngine.initialize();

      expect(ruleEngine.isInitialized, true);
    });

    test('重复初始化不应报错', () async {
      await ruleEngine.initialize();
      await ruleEngine.initialize();

      expect(ruleEngine.isInitialized, true);
    });

    test('初始化后应加载所有平台的适配配置', () async {
      await ruleEngine.initialize();

      expect(ruleEngine.getConfig('iqiyi'), isNotNull);
      expect(ruleEngine.getConfig('tencent'), isNotNull);
      expect(ruleEngine.getConfig('bilibili'), isNotNull);
      expect(ruleEngine.getConfig('youku'), isNotNull);
      expect(ruleEngine.getConfig('douyin'), isNotNull);
    });

    test('未初始化时getConfig应返回null', () {
      expect(ruleEngine.getConfig('iqiyi'), isNull);
    });

    test('getConfig不存在的平台应返回null', () async {
      await ruleEngine.initialize();

      expect(ruleEngine.getConfig('nonexistent'), isNull);
    });

    test('addRule应向指定平台添加规则', () async {
      await ruleEngine.initialize();

      const AdaptationRule newRule = AdaptationRule(
        ruleId: 'custom_rule_001',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.custom-element',
        cssProperty: 'color',
        cssValue: 'red',
      );

      ruleEngine.addRule('iqiyi', newRule);

      final AdaptationConfig? config = ruleEngine.getConfig('iqiyi');
      expect(config, isNotNull);
      expect(
        config!.rules.any(
          (AdaptationRule rule) => rule.ruleId == 'custom_rule_001',
        ),
        true,
      );
    });

    test('addRule向不存在的平台添加规则应创建新配置', () async {
      await ruleEngine.initialize();

      const AdaptationRule newRule = AdaptationRule(
        ruleId: 'new_platform_rule',
        ruleType: AdaptationRuleType.hideElement,
        cssSelector: '.ad',
        cssProperty: 'display',
        cssValue: 'none',
      );

      ruleEngine.addRule('new_platform', newRule);

      final AdaptationConfig? config = ruleEngine.getConfig('new_platform');
      expect(config, isNotNull);
      expect(config!.rules.length, 1);
    });

    test('removeRule应移除指定规则', () async {
      await ruleEngine.initialize();

      final AdaptationConfig? config = ruleEngine.getConfig('iqiyi');
      final int originalCount = config!.rules.length;

      ruleEngine.removeRule('iqiyi', 'iqiyi_hide_sidebar');

      final AdaptationConfig? updatedConfig = ruleEngine.getConfig('iqiyi');
      expect(updatedConfig!.rules.length, originalCount - 1);
    });

    test('removeRule不存在的规则不应报错', () async {
      await ruleEngine.initialize();

      ruleEngine.removeRule('iqiyi', 'nonexistent_rule');

      final AdaptationConfig? config = ruleEngine.getConfig('iqiyi');
      expect(config, isNotNull);
    });

    test('updateConfig应替换整个平台配置', () async {
      await ruleEngine.initialize();

      const AdaptationConfig newConfig = AdaptationConfig(
        platformId: 'iqiyi',
        rules: [
          AdaptationRule(
            ruleId: 'replaced_rule',
            ruleType: AdaptationRuleType.customCss,
            cssSelector: '*',
            cssProperty: 'color',
            cssValue: 'white',
          ),
        ],
        configVersion: 2,
      );

      ruleEngine.updateConfig('iqiyi', newConfig);

      final AdaptationConfig? config = ruleEngine.getConfig('iqiyi');
      expect(config!.configVersion, 2);
      expect(config.rules.length, 1);
    });

    test('generateCssForPlatform应生成CSS代码', () async {
      await ruleEngine.initialize();

      final String css = ruleEngine.generateCssForPlatform('bilibili');

      expect(css, isNotEmpty);
      expect(css, contains('{'));
      expect(css, contains('}'));
    });

    test('generateCssForPlatform不存在的平台应返回空字符串', () async {
      await ruleEngine.initialize();

      final String css = ruleEngine.generateCssForPlatform('nonexistent');

      expect(css, '');
    });

    test('clearCache应清空所有缓存并重置初始化状态', () async {
      await ruleEngine.initialize();
      ruleEngine.clearCache();

      expect(ruleEngine.isInitialized, false);
      expect(ruleEngine.getConfig('iqiyi'), isNull);
    });
  });
}
