/// 焦点管理器模块
/// 管理TV遥控器导航的焦点节点，维护焦点图和焦点切换逻辑
/// 被TV导航控制器和TVFocusable组件使用
library;

import 'package:flutter/widgets.dart';

import '../../models/navigation_node.dart';

/// 焦点管理器
/// 维护所有可聚焦节点的注册表，提供焦点查询和导航功能
class TvFocusManager extends ChangeNotifier {
  /// 所有已注册的导航节点，键为节点ID
  final Map<String, NavigationNode> _nodeRegistry = {};

  /// 当前获得焦点的节点ID
  String? _currentFocusedNodeId;

  /// 获取当前焦点节点ID
  /// 返回：String? - 当前焦点节点ID，无焦点时为null
  /// 副作用：无
  String? get currentFocusedNodeId => _currentFocusedNodeId;

  /// 注册一个导航节点到焦点图
  /// 参数：node - 要注册的导航节点
  /// 副作用：修改节点注册表，通知监听器
  void registerNode(NavigationNode node) {
    _nodeRegistry[node.nodeId] = node;
    if (_currentFocusedNodeId == null) {
      _currentFocusedNodeId = node.nodeId;
      notifyListeners();
    }
  }

  /// 批量注册导航节点
  /// 参数：nodes - 要注册的导航节点列表
  /// 副作用：修改节点注册表
  void registerNodes(List<NavigationNode> nodes) {
    for (final NavigationNode node in nodes) {
      _nodeRegistry[node.nodeId] = node;
    }
    if (_currentFocusedNodeId == null && nodes.isNotEmpty) {
      _currentFocusedNodeId = nodes.first.nodeId;
      notifyListeners();
    }
  }

  /// 注销一个导航节点
  /// 参数：nodeId - 要注销的节点ID
  /// 副作用：修改节点注册表，若当前焦点被注销则转移焦点
  void unregisterNode(String nodeId) {
    _nodeRegistry.remove(nodeId);
    if (_currentFocusedNodeId == nodeId) {
      _transferFocusAfterRemoval(nodeId);
    }
  }

  /// 节点被移除后转移焦点到同组其他节点
  /// 参数：removedNodeId - 被移除的节点ID
  /// 副作用：修改当前焦点，通知监听器
  void _transferFocusAfterRemoval(String removedNodeId) {
    final NavigationNode? removedNode = _nodeRegistry[removedNodeId];
    if (removedNode == null) {
      _currentFocusedNodeId = _nodeRegistry.keys.firstOrNull;
      notifyListeners();
      return;
    }
    final String groupId = removedNode.groupId;
    for (final NavigationNode node in _nodeRegistry.values) {
      if (node.groupId == groupId) {
        _currentFocusedNodeId = node.nodeId;
        notifyListeners();
        return;
      }
    }
    _currentFocusedNodeId = _nodeRegistry.keys.firstOrNull;
    notifyListeners();
  }

  /// 按指定方向移动焦点
  /// 参数：direction - 导航方向
  /// 返回：bool - 焦点是否成功移动
  /// 副作用：可能修改当前焦点，通知监听器
  bool moveFocus(NavigationDirection direction) {
    if (_currentFocusedNodeId == null) {
      return false;
    }

    final NavigationNode? currentNode = _nodeRegistry[_currentFocusedNodeId];
    if (currentNode == null) {
      return false;
    }

    final String? nextNodeId = currentNode.getNeighborId(direction);
    if (nextNodeId == null || !_nodeRegistry.containsKey(nextNodeId)) {
      return false;
    }

    _currentFocusedNodeId = nextNodeId;
    notifyListeners();
    return true;
  }

  /// 直接设置焦点到指定节点
  /// 参数：nodeId - 目标节点ID
  /// 返回：bool - 是否成功设置焦点
  /// 副作用：修改当前焦点，通知监听器
  bool setFocusTo(String nodeId) {
    if (!_nodeRegistry.containsKey(nodeId)) {
      return false;
    }
    _currentFocusedNodeId = nodeId;
    notifyListeners();
    return true;
  }

  /// 获取指定节点
  /// 参数：nodeId - 节点ID
  /// 返回：NavigationNode? - 节点实例，不存在时返回null
  /// 副作用：无
  NavigationNode? getNode(String nodeId) {
    return _nodeRegistry[nodeId];
  }

  /// 获取指定分组中的所有节点ID
  /// 参数：groupId - 分组ID
  /// 返回：List<String> - 该分组中的节点ID列表
  /// 副作用：无
  List<String> getNodeIdsByGroup(String groupId) {
    return _nodeRegistry.values
        .where((NavigationNode node) => node.groupId == groupId)
        .map((NavigationNode node) => node.nodeId)
        .toList();
  }

  /// 清除所有已注册的节点
  /// 副作用：清空节点注册表和当前焦点
  void clearAll() {
    _nodeRegistry.clear();
    _currentFocusedNodeId = null;
    notifyListeners();
  }

  /// 检查指定节点是否当前获得焦点
  /// 参数：nodeId - 节点ID
  /// 返回：bool - 是否为当前焦点
  /// 副作用：无
  bool isFocused(String nodeId) {
    return _currentFocusedNodeId == nodeId;
  }

  @override
  void dispose() {
    _nodeRegistry.clear();
    super.dispose();
  }
}
