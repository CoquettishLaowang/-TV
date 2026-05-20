/// StartupOptimizer单元测试
/// 验证启动优化器的阶段记录和延迟初始化功能
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:tv_video_hub/core/performance/startup_optimizer.dart';

void main() {
  group('StartupRecord', () {
    test('totalDurationMs未完成时应返回null', () {
      final StartupRecord record = StartupRecord(
        startTimestamp: 1000,
      );

      expect(record.totalDurationMs, isNull);
    });

    test('totalDurationMs完成后应返回正确耗时', () {
      final StartupRecord record = StartupRecord(
        startTimestamp: 1000,
      );
      record.completedTimestamp = 3500;

      expect(record.totalDurationMs, 2500);
    });

    test('isOverThreshold超过3秒时应返回true', () {
      final StartupRecord record = StartupRecord(
        startTimestamp: 1000,
      );
      record.completedTimestamp = 5000;

      expect(record.isOverThreshold, true);
    });

    test('isOverThreshold未超过3秒时应返回false', () {
      final StartupRecord record = StartupRecord(
        startTimestamp: 1000,
      );
      record.completedTimestamp = 2000;

      expect(record.isOverThreshold, false);
    });

    test('isOverThreshold未完成时应返回false', () {
      final StartupRecord record = StartupRecord(
        startTimestamp: 1000,
      );

      expect(record.isOverThreshold, false);
    });
  });

  group('StartupOptimizer', () {
    late StartupOptimizer optimizer;

    setUp(() {
      optimizer = StartupOptimizer();
    });

    test('markStartupBegin应创建启动记录', () {
      optimizer.markStartupBegin();

      expect(optimizer.currentRecord, isNotNull);
    });

    test('markPhaseCompleted应更新对应阶段时间戳', () {
      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.preInit);

      expect(
        optimizer.currentRecord!.preInitCompletedTimestamp,
        isNotNull,
      );
    });

    test('完成启动后应将记录移入历史', () {
      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.completed);

      expect(optimizer.history.length, 1);
    });

    test('延迟初始化任务应在启动完成后执行', () {
      bool lazyTaskExecuted = false;
      optimizer.registerLazyInitTask(() {
        lazyTaskExecuted = true;
      });

      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.completed);

      expect(lazyTaskExecuted, true);
    });

    test('getAverageStartupTime应返回正确的平均值', () {
      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.completed);

      optimizer.markStartupBegin();
      optimizer.markPhaseCompleted(StartupPhase.completed);

      expect(optimizer.getAverageStartupTime(), greaterThanOrEqualTo(0));
    });

    test('无历史记录时平均启动时间应为0', () {
      expect(optimizer.getAverageStartupTime(), 0);
    });
  });
}
