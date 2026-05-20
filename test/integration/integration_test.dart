/// 集成测试
/// 验证各模块之间的协作和数据流转
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/adaptive/css_injector.dart';
import 'package:tv_video_hub/adaptive/rule_engine.dart';
import 'package:tv_video_hub/core/navigation/focus_manager.dart';
import 'package:tv_video_hub/core/performance/memory_manager.dart';
import 'package:tv_video_hub/core/performance/startup_optimizer.dart';
import 'package:tv_video_hub/models/adaptation_config.dart';
import 'package:tv_video_hub/models/navigation_node.dart';

void main() {
  group('规则引擎与CSS注入器集成', () {
    late RuleEngine ruleEngine;
    late CssInjector cssInjector;

    setUp(() {
      ruleEngine = RuleEngine.instance;
      cssInjector = CssInjector();
    });

    tearDown(() {
      ruleEngine.clearCache();
    });

    test('规则引擎生成的配置应能被CSS注入器正确处理', () async {
      await ruleEngine.initialize();

      final AdaptationConfig? config = ruleEngine.getConfig('bilibili');
      expect(config, isNotNull);

      final String css = cssInjector.generateFullCss(config!);

      expect(css, isNotEmpty);
      expect(css, contains('TV Video Hub'));
      expect(css, contains('bilibili'));
    });

    test('动态添加规则后CSS应包含新规则', () async {
      await ruleEngine.initialize();

      const AdaptationRule customRule = AdaptationRule(
        ruleId: 'integration_custom',
        ruleType: AdaptationRuleType.customCss,
        cssSelector: '.integration-test',
        cssProperty: 'background',
        cssValue: 'blue',
      );
      ruleEngine.addRule('iqiyi', customRule);

      final AdaptationConfig? config = ruleEngine.getConfig('iqiyi');
      final String css = cssInjector.generateFullCss(config!);

      expect(css, contains('.integration-test'));
      expect(css, contains('background'));
    });

    test('所有平台的配置都应能生成有效CSS', () async {
      await ruleEngine.initialize();

      final List<String> platformIds = [
        'iqiyi',
        'tencent',
        'bilibili',
        'youku',
        'douyin',
      ];

      for (final String platformId in platformIds) {
        final AdaptationConfig? config = ruleEngine.getConfig(platformId);
        expect(config, isNotNull, reason: '$platformId 配置不应为null');

        final String css = cssInjector.generateFullCss(config!);
        expect(css, isNotEmpty, reason: '$platformId CSS不应为空');
        expect(css, contains(platformId), reason: '$platformId CSS应包含平台标识');
      }
    });
  });

  group('焦点管理器与按键处理集成', () {
    late TvFocusManager focusManager;

    setUp(() {
      focusManager = TvFocusManager();
    });

    tearDown(() {
      focusManager.dispose();
    });

    test('方向键映射应能驱动焦点导航', () {
      final NavigationNode nodeA = NavigationNode(
        nodeId: 'node_a',
        groupId: 'nav_group',
        rightNeighborId: 'node_b',
        downNeighborId: 'node_c',
      );
      final NavigationNode nodeB = NavigationNode(
        nodeId: 'node_b',
        groupId: 'nav_group',
        leftNeighborId: 'node_a',
      );
      final NavigationNode nodeC = NavigationNode(
        nodeId: 'node_c',
        groupId: 'nav_group',
        upNeighborId: 'node_a',
      );

      focusManager.registerNodes([nodeA, nodeB, nodeC]);
      expect(focusManager.currentFocusedNodeId, 'node_a');

      final bool movedRight = focusManager.moveFocus(NavigationDirection.right);
      expect(movedRight, true);
      expect(focusManager.currentFocusedNodeId, 'node_b');

      focusManager.setFocusTo('node_a');
      final bool movedDown = focusManager.moveFocus(NavigationDirection.down);
      expect(movedDown, true);
      expect(focusManager.currentFocusedNodeId, 'node_c');
    });

    test('构建二维导航网格后焦点应能四向导航', () {
      final List<NavigationNode> gridNodes = [];
      const int gridRows = 3;
      const int gridCols = 3;

      for (int row = 0; row < gridRows; row++) {
        for (int col = 0; col < gridCols; col++) {
          final String nodeId = 'cell_${row}_$col';
          gridNodes.add(NavigationNode(
            nodeId: nodeId,
            groupId: 'grid',
            rowIndex: row,
            columnIndex: col,
            upNeighborId: row > 0 ? 'cell_${row - 1}_$col' : null,
            downNeighborId: row < gridRows - 1 ? 'cell_${row + 1}_$col' : null,
            leftNeighborId: col > 0 ? 'cell_${row}_${col - 1}' : null,
            rightNeighborId: col < gridCols - 1 ? 'cell_${row}_${col + 1}' : null,
          ));
        }
      }

      focusManager.registerNodes(gridNodes);
      expect(focusManager.currentFocusedNodeId, 'cell_0_0');

      focusManager.moveFocus(NavigationDirection.right);
      expect(focusManager.currentFocusedNodeId, 'cell_0_1');

      focusManager.moveFocus(NavigationDirection.down);
      expect(focusManager.currentFocusedNodeId, 'cell_1_1');

      focusManager.moveFocus(NavigationDirection.left);
      expect(focusManager.currentFocusedNodeId, 'cell_1_0');

      focusManager.moveFocus(NavigationDirection.up);
      expect(focusManager.currentFocusedNodeId, 'cell_0_0');
    });
  });

  group('启动优化与内存管理集成', () {
    test('启动流程应正确记录各阶段', () {
      final StartupOptimizer optimizer = StartupOptimizer();
      final MemoryManager memoryManager = MemoryManager();

      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.preInit);

      memoryManager.startMonitoring();

      optimizer.markPhaseCompleted(StartupPhase.coreInit);
      optimizer.markPhaseCompleted(StartupPhase.uiRender);
      optimizer.markPhaseCompleted(StartupPhase.completed);

      expect(optimizer.history.length, 1);
      expect(optimizer.history.first.totalDurationMs, isNotNull);
      expect(memoryManager.snapshots.length, 1);

      memoryManager.dispose();
    });

    test('延迟初始化任务应能注册和执行', () {
      final StartupOptimizer optimizer = StartupOptimizer();
      int memoryInitCount = 0;

      optimizer.registerLazyInitTask(() {
        memoryInitCount++;
      });

      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.completed);

      expect(memoryInitCount, 1);
    });
  });

  group('完整数据流集成测试', () {
    test('从规则引擎到CSS生成的完整流程', () async {
      final RuleEngine engine = RuleEngine.instance;
      final CssInjector injector = CssInjector();

      await engine.initialize();

      const AdaptationRule dynamicRule = AdaptationRule(
        ruleId: 'dynamic_test_rule',
        ruleType: AdaptationRuleType.modifyFontSize,
        cssSelector: '.video-title',
        cssProperty: 'font-size',
        cssValue: '32px',
        priority: 25,
        applicablePlatformIds: ['bilibili'],
      );
      engine.addRule('bilibili', dynamicRule);

      final AdaptationConfig? config = engine.getConfig('bilibili');
      expect(config, isNotNull);

      final List<AdaptationRule> sortedRules = config!.getSortedRules();
      expect(sortedRules.first.priority, greaterThanOrEqualTo(25));

      final String css = injector.generateFullCss(config);
      expect(css, contains('.video-title'));
      expect(css, contains('32px'));

      engine.clearCache();
    });
  });
}
