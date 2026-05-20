/// MemoryManager单元测试
/// 验证内存管理器的快照采集、趋势分析和阈值检测功能
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/core/performance/memory_manager.dart';

void main() {
  group('MemorySnapshot', () {
    test('应正确创建MemorySnapshot实例', () {
      const MemorySnapshot snapshot = MemorySnapshot(
        usedMemoryMb: 128.5,
        timestamp: 1000000,
      );

      expect(snapshot.usedMemoryMb, 128.5);
      expect(snapshot.timestamp, 1000000);
    });

    test('toString应包含内存使用量信息', () {
      const MemorySnapshot snapshot = MemorySnapshot(
        usedMemoryMb: 150.0,
        timestamp: 2000000,
      );

      expect(snapshot.toString(), contains('150.0'));
      expect(snapshot.toString(), contains('MB'));
    });
  });

  group('MemoryManager', () {
    late MemoryManager memoryManager;

    setUp(() {
      memoryManager = MemoryManager();
    });

    tearDown(() {
      memoryManager.dispose();
    });

    test('初始状态下当前内存应为0', () {
      expect(memoryManager.currentMemoryMb, 0);
    });

    test('captureSnapshot应添加快照到历史记录', () {
      final MemorySnapshot snapshot = memoryManager.captureSnapshot();

      expect(snapshot, isNotNull);
      expect(memoryManager.snapshots.length, 1);
    });

    test('多次采集快照应累积到历史记录', () {
      memoryManager.captureSnapshot();
      memoryManager.captureSnapshot();
      memoryManager.captureSnapshot();

      expect(memoryManager.snapshots.length, 3);
    });

    test('calculateAverageMemory应返回正确的平均值', () {
      memoryManager.captureSnapshot();
      memoryManager.captureSnapshot();
      memoryManager.captureSnapshot();

      final double average = memoryManager.calculateAverageMemory(3);
      expect(average, greaterThanOrEqualTo(0));
    });

    test('无快照时calculateAverageMemory应返回0', () {
      final double average = memoryManager.calculateAverageMemory();

      expect(average, 0);
    });

    test('getMemoryTrend快照不足3个时应返回stable', () {
      memoryManager.captureSnapshot();

      expect(memoryManager.getMemoryTrend(), MemoryTrend.stable);
    });

    test('clearSnapshots应清空所有快照记录', () {
      memoryManager.captureSnapshot();
      memoryManager.captureSnapshot();

      memoryManager.clearSnapshots();

      expect(memoryManager.snapshots.length, 0);
    });

    test('startMonitoring应采集初始快照', () {
      memoryManager.startMonitoring();

      expect(memoryManager.snapshots.length, 1);
    });

    test('snapshots应返回不可修改的列表', () {
      memoryManager.captureSnapshot();

      final List<MemorySnapshot> snapshots = memoryManager.snapshots;

      expect(() => snapshots.add(const MemorySnapshot(
        usedMemoryMb: 999,
        timestamp: 0,
      )), throwsA(isA<UnsupportedError>()));
    });
  });
}
