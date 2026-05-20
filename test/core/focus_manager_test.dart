/// TvFocusManager单元测试
/// 验证TV焦点管理器的节点注册、焦点移动和焦点查询功能
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/core/navigation/focus_manager.dart';
import 'package:tv_video_hub/models/navigation_node.dart';

void main() {
  group('TvFocusManager', () {
    late TvFocusManager focusManager;

    setUp(() {
      focusManager = TvFocusManager();
    });

    tearDown(() {
      focusManager.dispose();
    });

    test('注册首个节点时应自动设为当前焦点', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'first_node',
        groupId: 'group_a',
      );

      focusManager.registerNode(node);

      expect(focusManager.currentFocusedNodeId, 'first_node');
    });

    test('注册多个节点后焦点应保持在首个节点', () {
      final List<NavigationNode> nodes = [
        NavigationNode(nodeId: 'node_1', groupId: 'group_a'),
        NavigationNode(nodeId: 'node_2', groupId: 'group_a'),
        NavigationNode(nodeId: 'node_3', groupId: 'group_a'),
      ];

      focusManager.registerNodes(nodes);

      expect(focusManager.currentFocusedNodeId, 'node_1');
    });

    test('moveFocus应按邻居关系移动焦点', () {
      final NavigationNode nodeA = NavigationNode(
        nodeId: 'node_a',
        groupId: 'group_a',
        rightNeighborId: 'node_b',
      );
      final NavigationNode nodeB = NavigationNode(
        nodeId: 'node_b',
        groupId: 'group_a',
        leftNeighborId: 'node_a',
      );

      focusManager.registerNodes([nodeA, nodeB]);
      expect(focusManager.currentFocusedNodeId, 'node_a');

      final bool moved = focusManager.moveFocus(NavigationDirection.right);
      expect(moved, true);
      expect(focusManager.currentFocusedNodeId, 'node_b');
    });

    test('moveFocus无邻居时应返回false且焦点不变', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'isolated',
        groupId: 'group_a',
      );

      focusManager.registerNode(node);

      final bool moved = focusManager.moveFocus(NavigationDirection.up);
      expect(moved, false);
      expect(focusManager.currentFocusedNodeId, 'isolated');
    });

    test('setFocusTo应直接设置焦点到指定节点', () {
      final List<NavigationNode> nodes = [
        NavigationNode(nodeId: 'node_1', groupId: 'group_a'),
        NavigationNode(nodeId: 'node_2', groupId: 'group_a'),
      ];

      focusManager.registerNodes(nodes);

      final bool set = focusManager.setFocusTo('node_2');
      expect(set, true);
      expect(focusManager.currentFocusedNodeId, 'node_2');
    });

    test('setFocusTo不存在的节点应返回false', () {
      focusManager.registerNode(
        NavigationNode(nodeId: 'existing', groupId: 'group_a'),
      );

      final bool set = focusManager.setFocusTo('nonexistent');
      expect(set, false);
    });

    test('unregisterNode移除当前焦点时应转移到同组节点', () {
      final NavigationNode nodeA = NavigationNode(
        nodeId: 'node_a',
        groupId: 'group_a',
      );
      final NavigationNode nodeB = NavigationNode(
        nodeId: 'node_b',
        groupId: 'group_a',
      );

      focusManager.registerNodes([nodeA, nodeB]);
      focusManager.setFocusTo('node_a');

      focusManager.unregisterNode('node_a');

      expect(focusManager.currentFocusedNodeId, 'node_b');
    });

    test('getNodeIdsByGroup应返回指定分组的所有节点ID', () {
      final List<NavigationNode> nodes = [
        NavigationNode(nodeId: 'a1', groupId: 'group_a'),
        NavigationNode(nodeId: 'a2', groupId: 'group_a'),
        NavigationNode(nodeId: 'b1', groupId: 'group_b'),
      ];

      focusManager.registerNodes(nodes);

      final List<String> groupAIds =
          focusManager.getNodeIdsByGroup('group_a');
      expect(groupAIds.length, 2);
      expect(groupAIds, containsAll(['a1', 'a2']));
    });

    test('isFocused应正确判断焦点状态', () {
      focusManager.registerNode(
        NavigationNode(nodeId: 'focused_node', groupId: 'group_a'),
      );

      expect(focusManager.isFocused('focused_node'), true);
      expect(focusManager.isFocused('other_node'), false);
    });

    test('clearAll应清除所有节点和焦点', () {
      focusManager.registerNodes([
        NavigationNode(nodeId: 'node_1', groupId: 'group_a'),
        NavigationNode(nodeId: 'node_2', groupId: 'group_a'),
      ]);

      focusManager.clearAll();

      expect(focusManager.currentFocusedNodeId, isNull);
      expect(focusManager.getNodeIdsByGroup('group_a'), isEmpty);
    });
  });
}
