/// 按键事件处理模块
/// 处理TV遥控器的按键输入，将物理按键映射为应用内的导航动作
/// 被TV导航控制器调用

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// 遥控器按键动作枚举
/// 定义所有遥控器可触发的操作类型
enum RemoteKeyAction {
  /// 导航 - 上
  navigateUp,

  /// 导航 - 下
  navigateDown,

  /// 导航 - 左
  navigateLeft,

  /// 导航 - 右
  navigateRight,

  /// 确认/选择
  confirm,

  /// 返回
  goBack,

  /// 菜单呼出
  menu,

  /// 音量增加
  volumeUp,

  /// 音量减少
  volumeDown,

  /// 静音切换
  muteToggle,

  /// 首页键
  home,

  /// 未知按键
  unknown,
}

/// 按键事件处理器
/// 负责将RawKeyEvent转换为应用内的RemoteKeyAction
/// 使用防抖机制防止遥控器按键重复触发
class KeyEventHandler {
  /// 上次按键触发的时间戳，用于防抖计算
  int _lastKeyTimestamp = 0;

  /// 获取当前时间戳（毫秒）
  /// 返回：int - 当前时间戳
  /// 副作用：无
  int _currentTimestampMs() => DateTime.now().millisecondsSinceEpoch;

  /// 检查按键是否因防抖而被过滤
  /// 返回：bool - true表示按键被过滤（应忽略）
  /// 副作用：更新上次按键时间戳
  bool _shouldDebounce() {
    final int currentMs = _currentTimestampMs();
    final int elapsed = currentMs - _lastKeyTimestamp;
    if (elapsed < kKeyDebounceIntervalMs) {
      return true;
    }
    _lastKeyTimestamp = currentMs;
    return false;
  }

  /// 处理RawKeyDownEvent，将其转换为RemoteKeyAction
  /// 参数：event - Flutter原始按键事件
  /// 返回：RemoteKeyAction - 映射后的遥控器动作
  /// 副作用：无
  RemoteKeyAction handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return RemoteKeyAction.unknown;
    }

    if (_shouldDebounce()) {
      return RemoteKeyAction.unknown;
    }

    return _mapLogicalKey(event.logicalKey);
  }

  /// 将LogicalKeyboardKey映射为RemoteKeyAction
  /// 参数：logicalKey - 逻辑按键键值
  /// 返回：RemoteKeyAction - 对应的遥控器动作
  /// 副作用：无
  RemoteKeyAction _mapLogicalKey(LogicalKeyboardKey logicalKey) {
    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      return RemoteKeyAction.navigateUp;
    }
    if (logicalKey == LogicalKeyboardKey.arrowDown) {
      return RemoteKeyAction.navigateDown;
    }
    if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      return RemoteKeyAction.navigateLeft;
    }
    if (logicalKey == LogicalKeyboardKey.arrowRight) {
      return RemoteKeyAction.navigateRight;
    }
    if (logicalKey == LogicalKeyboardKey.select ||
        logicalKey == LogicalKeyboardKey.enter) {
      return RemoteKeyAction.confirm;
    }
    if (logicalKey == LogicalKeyboardKey.goBack ||
        logicalKey == LogicalKeyboardKey.escape) {
      return RemoteKeyAction.goBack;
    }
    if (logicalKey == LogicalKeyboardKey.contextMenu) {
      return RemoteKeyAction.menu;
    }
    return _mapMediaKeys(logicalKey);
  }

  /// 映射媒体控制键
  /// 参数：logicalKey - 逻辑按键键值
  /// 返回：RemoteKeyAction - 对应的遥控器动作
  /// 副作用：无
  RemoteKeyAction _mapMediaKeys(LogicalKeyboardKey logicalKey) {
    if (logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      return RemoteKeyAction.volumeUp;
    }
    if (logicalKey == LogicalKeyboardKey.audioVolumeDown) {
      return RemoteKeyAction.volumeDown;
    }
    if (logicalKey == LogicalKeyboardKey.audioVolumeMute) {
      return RemoteKeyAction.muteToggle;
    }
    return RemoteKeyAction.unknown;
  }

  /// 重置防抖状态，用于场景切换时清除防抖锁定
  /// 副作用：将上次按键时间戳归零
  void resetDebounce() {
    _lastKeyTimestamp = 0;
  }
}
