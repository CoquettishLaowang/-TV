/// KeyEventHandler单元测试
/// 验证遥控器按键映射和防抖机制

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/core/navigation/key_event_handler.dart';

void main() {
  group('KeyEventHandler', () {
    late KeyEventHandler handler;

    setUp(() {
      handler = KeyEventHandler();
    });

    test('方向上键应映射为navigateUp', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.navigateUp);
    });

    test('方向下键应映射为navigateDown', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowDown,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.navigateDown);
    });

    test('方向左键应映射为navigateLeft', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowLeft,
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.navigateLeft);
    });

    test('方向右键应映射为navigateRight', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowRight,
          physicalKey: PhysicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.navigateRight);
    });

    test('回车键应映射为confirm', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.enter,
          physicalKey: PhysicalKeyboardKey.enter,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.confirm);
    });

    test('ESC键应映射为goBack', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.escape,
          physicalKey: PhysicalKeyboardKey.escape,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.goBack);
    });

    test('音量增加键应映射为volumeUp', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.audioVolumeUp,
          physicalKey: PhysicalKeyboardKey.audioVolumeUp,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.volumeUp);
    });

    test('音量减少键应映射为volumeDown', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.audioVolumeDown,
          physicalKey: PhysicalKeyboardKey.audioVolumeDown,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.volumeDown);
    });

    test('静音键应映射为muteToggle', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.audioVolumeMute,
          physicalKey: PhysicalKeyboardKey.audioVolumeMute,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.muteToggle);
    });

    test('未识别的键应映射为unknown', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.unknown);
    });

    test('KeyUpEvent应返回unknown', () {
      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyUpEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.unknown);
    });

    test('resetDebounce应重置防抖状态', () {
      handler.resetDebounce();

      final RemoteKeyAction action = handler.handleKeyEvent(
        KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
      );

      expect(action, RemoteKeyAction.navigateUp);
    });
  });
}
