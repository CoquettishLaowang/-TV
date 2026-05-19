/// 导航节点模型
/// 定义TV遥控器导航的焦点节点结构，用于构建二维导航图
/// 被TV导航控制器和焦点管理器使用

/// 导航方向枚举，对应遥控器的四个方向键
enum NavigationDirection {
  /// 向上导航
  up,

  /// 向下导航
  down,

  /// 向左导航
  left,

  /// 向右导航
  right,
}

/// 导航节点，表示TV界面中一个可聚焦的元素
/// 每个节点存储其在导航图中的邻居关系
class NavigationNode {
  /// 节点唯一标识，通常对应FocusNode的标识
  final String nodeId;

  /// 节点所属的分组标识，用于限制导航范围
  final String groupId;

  /// 上方邻居节点ID，遥控器按上键时跳转目标
  String? upNeighborId;

  /// 下方邻居节点ID，遥控器按下键时跳转目标
  String? downNeighborId;

  /// 左侧邻居节点ID，遥控器按左键时跳转目标
  String? leftNeighborId;

  /// 右侧邻居节点ID，遥控器按右键时跳转目标
  String? rightNeighborId;

  /// 节点在网格中的行索引，用于自动计算邻居
  int? rowIndex;

  /// 节点在网格中的列索引，用于自动计算邻居
  int? columnIndex;

  /// 构造函数
  /// 参数：nodeId - 节点标识 / groupId - 分组标识
  /// 副作用：无
  NavigationNode({
    required this.nodeId,
    required this.groupId,
    this.upNeighborId,
    this.downNeighborId,
    this.leftNeighborId,
    this.rightNeighborId,
    this.rowIndex,
    this.columnIndex,
  });

  /// 获取指定方向的邻居节点ID
  /// 参数：direction - 导航方向
  /// 返回：String? - 邻居节点ID，无邻居时返回null
  /// 副作用：无
  String? getNeighborId(NavigationDirection direction) {
    switch (direction) {
      case NavigationDirection.up:
        return upNeighborId;
      case NavigationDirection.down:
        return downNeighborId;
      case NavigationDirection.left:
        return leftNeighborId;
      case NavigationDirection.right:
        return rightNeighborId;
    }
  }

  /// 设置指定方向的邻居节点ID
  /// 参数：direction - 导航方向 / neighborId - 邻居节点ID
  /// 副作用：修改当前节点的邻居关系
  void setNeighborId(NavigationDirection direction, String? neighborId) {
    switch (direction) {
      case NavigationDirection.up:
        upNeighborId = neighborId;
      case NavigationDirection.down:
        downNeighborId = neighborId;
      case NavigationDirection.left:
        leftNeighborId = neighborId;
      case NavigationDirection.right:
        rightNeighborId = neighborId;
    }
  }

  /// 检查节点是否有指定方向的邻居
  /// 参数：direction - 导航方向
  /// 返回：bool - 是否存在该方向的邻居
  /// 副作用：无
  bool hasNeighbor(NavigationDirection direction) {
    return getNeighborId(direction) != null;
  }

  @override
  String toString() => 'NavigationNode(id: $nodeId, group: $groupId)';
}
