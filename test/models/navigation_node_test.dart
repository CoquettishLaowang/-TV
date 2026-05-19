/// NavigationNode模型单元测试
/// 验证导航节点的邻居关系和方向操作

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/models/navigation_node.dart';

void main() {
  group('NavigationNode', () {
    test('应正确创建NavigationNode实例', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'node_001',
        groupId: 'group_main',
        upNeighborId: 'node_000',
        downNeighborId: 'node_002',
      );

      expect(node.nodeId, 'node_001');
      expect(node.groupId, 'group_main');
      expect(node.upNeighborId, 'node_000');
      expect(node.downNeighborId, 'node_002');
      expect(node.leftNeighborId, isNull);
      expect(node.rightNeighborId, isNull);
    });

    test('getNeighborId应返回指定方向的邻居', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'center',
        groupId: 'grid',
        upNeighborId: 'top',
        downNeighborId: 'bottom',
        leftNeighborId: 'left',
        rightNeighborId: 'right',
      );

      expect(
        node.getNeighborId(NavigationDirection.up),
        'top',
      );
      expect(
        node.getNeighborId(NavigationDirection.down),
        'bottom',
      );
      expect(
        node.getNeighborId(NavigationDirection.left),
        'left',
      );
      expect(
        node.getNeighborId(NavigationDirection.right),
        'right',
      );
    });

    test('getNeighborId无邻居时应返回null', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'isolated',
        groupId: 'solo',
      );

      expect(
        node.getNeighborId(NavigationDirection.up),
        isNull,
      );
    });

    test('setNeighborId应正确设置邻居关系', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'node_a',
        groupId: 'group_1',
      );

      node.setNeighborId(NavigationDirection.up, 'node_above');

      expect(node.upNeighborId, 'node_above');
    });

    test('hasNeighbor应正确判断邻居是否存在', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'node_a',
        groupId: 'group_1',
        upNeighborId: 'node_above',
      );

      expect(node.hasNeighbor(NavigationDirection.up), true);
      expect(node.hasNeighbor(NavigationDirection.down), false);
    });

    test('toString应包含节点ID和分组', () {
      final NavigationNode node = NavigationNode(
        nodeId: 'test_node',
        groupId: 'test_group',
      );

      expect(node.toString(), contains('test_node'));
      expect(node.toString(), contains('test_group'));
    });
  });
}
