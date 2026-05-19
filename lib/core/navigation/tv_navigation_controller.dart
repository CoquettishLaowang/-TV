/// TV导航控制器模块
/// 统一管理TV遥控器导航逻辑，协调按键事件、焦点管理和页面导航
/// 被App根组件和各页面使用

import 'package:flutter/widgets.dart';

import '../../models/navigation_node.dart';
import 'focus_manager.dart';
import 'key_event_handler.dart';

/// TV导航控制器
/// 整合按键处理、焦点管理和页面导航，提供统一的TV遥控器操作接口
class TvNavigationController extends ChangeNotifier {
  /// 按键事件处理器
  final KeyEventHandler _keyEventHandler = KeyEventHandler();

  /// 焦点管理器
  final TvFocusManager _focusManager = TvFocusManager();

  /// 导航动作回调，用于页面级导航操作（如返回、菜单）
  final void Function(RemoteKeyAction action)? onNavigationAction;

  /// 获取焦点管理器实例
  /// 返回：TvFocusManager - 焦点管理器
  /// 副作用：无
  TvFocusManager get focusManager => _focusManager;

  /// 构造函数
  /// 参数：onNavigationAction - 导航动作回调（可选）
  /// 副作用：无
  TvNavigationController({this.onNavigationAction});

  /// 处理按键事件
  /// 将Flutter的KeyEvent转换为导航动作并执行
  /// 参数：event - Flutter按键事件
  /// 返回：bool - 事件是否被处理
  /// 副作用：可能改变焦点状态或触发导航回调
  bool handleKeyEvent(KeyEvent event) {
    final RemoteKeyAction action = _keyEventHandler.handleKeyEvent(event);

    if (action == RemoteKeyAction.unknown) {
      return false;
    }

    return _executeAction(action);
  }

  /// 执行导航动作
  /// 参数：action - 要执行的遥控器动作
  /// 返回：bool - 动作是否被成功处理
  /// 副作用：可能改变焦点状态或触发导航回调
  bool _executeAction(RemoteKeyAction action) {
    switch (action) {
      case RemoteKeyAction.navigateUp:
        return _focusManager.moveFocus(NavigationDirection.up);
      case RemoteKeyAction.navigateDown:
        return _focusManager.moveFocus(NavigationDirection.down);
      case RemoteKeyAction.navigateLeft:
        return _focusManager.moveFocus(NavigationDirection.left);
      case RemoteKeyAction.navigateRight:
        return _focusManager.moveFocus(NavigationDirection.right);
      case RemoteKeyAction.confirm:
        return _handleConfirm();
      case RemoteKeyAction.goBack:
      case RemoteKeyAction.menu:
      case RemoteKeyAction.home:
        _notifyNavigationAction(action);
        return true;
      case RemoteKeyAction.volumeUp:
      case RemoteKeyAction.volumeDown:
      case RemoteKeyAction.muteToggle:
        return false;
      case RemoteKeyAction.unknown:
        return false;
    }
  }

  /// 处理确认键动作
  /// 返回：bool - 是否成功处理
  /// 副作用：可能触发焦点节点的确认回调
  bool _handleConfirm() {
    final String? focusedId = _focusManager.currentFocusedNodeId;
    if (focusedId == null) {
      return false;
    }
    notifyListeners();
    return true;
  }

  /// 通知导航动作给外部监听者
  /// 参数：action - 导航动作
  /// 副作用：调用外部回调
  void _notifyNavigationAction(RemoteKeyAction action) {
    onNavigationAction?.call(action);
  }

  /// 注册导航节点
  /// 参数：node - 导航节点
  /// 副作用：修改焦点管理器的节点注册表
  void registerNode(NavigationNode node) {
    _focusManager.registerNode(node);
  }

  /// 批量注册导航节点
  /// 参数：nodes - 导航节点列表
  /// 副作用：修改焦点管理器的节点注册表
  void registerNodes(List<NavigationNode> nodes) {
    _focusManager.registerNodes(nodes);
  }

  /// 注销导航节点
  /// 参数：nodeId - 节点ID
  /// 副作用：修改焦点管理器的节点注册表
  void unregisterNode(String nodeId) {
    _focusManager.unregisterNode(nodeId);
  }

  /// 设置焦点到指定节点
  /// 参数：nodeId - 目标节点ID
  /// 返回：bool - 是否成功设置
  /// 副作用：修改当前焦点
  bool setFocusTo(String nodeId) {
    return _focusManager.setFocusTo(nodeId);
  }

  /// 获取当前焦点节点ID
  /// 返回：String? - 当前焦点节点ID
  /// 副作用：无
  String? get currentFocusId => _focusManager.currentFocusedNodeId;

  /// 重置按键防抖状态
  /// 副作用：重置按键处理器的时间戳
  void resetKeyDebounce() {
    _keyEventHandler.resetDebounce();
  }

  /// 清除所有导航状态
  /// 副作用：清空焦点管理器
  void clearAll() {
    _focusManager.clearAll();
  }

  @override
  void dispose() {
    _focusManager.dispose();
    super.dispose();
  }
}
