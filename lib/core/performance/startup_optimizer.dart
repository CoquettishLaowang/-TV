/// 启动优化模块
/// 优化应用冷启动性能，确保冷启动时间<3秒
/// 被应用入口main()函数使用
library;

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../constants/performance_constants.dart';

/// 启动阶段枚举
/// 定义应用启动过程中的各个阶段
enum StartupPhase {
  /// 预初始化阶段：Flutter引擎加载
  preInit,

  /// 核心初始化阶段：加载核心模块和依赖
  coreInit,

  /// UI渲染阶段：首帧渲染
  uiRender,

  /// 启动完成
  completed,
}

/// 启动性能记录
/// 记录启动各阶段的时间戳
class StartupRecord {
  /// 应用启动开始时间戳（毫秒）
  final int startTimestamp;

  /// 预初始化完成时间戳
  int? preInitCompletedTimestamp;

  /// 核心初始化完成时间戳
  int? coreInitCompletedTimestamp;

  /// UI渲染完成时间戳
  int? uiRenderCompletedTimestamp;

  /// 启动完成时间戳
  int? completedTimestamp;

  /// 构造函数
  StartupRecord({required this.startTimestamp});

  /// 计算总启动耗时（毫秒）
  /// 返回：int? - 总耗时，未完成时返回null
  /// 副作用：无
  int? get totalDurationMs {
    if (completedTimestamp == null) {
      return null;
    }
    return completedTimestamp! - startTimestamp;
  }

  /// 检查启动是否超过性能阈值
  /// 返回：bool - 是否超过冷启动阈值
  /// 副作用：无
  bool get isOverThreshold {
    final int? duration = totalDurationMs;
    if (duration == null) {
      return false;
    }
    return duration > kColdStartThresholdMs;
  }
}

/// 启动优化器
/// 管理应用启动流程，记录启动性能数据，执行延迟初始化策略
class StartupOptimizer {
  /// 当前启动记录
  StartupRecord? _currentRecord;

  /// 历史启动记录
  final List<StartupRecord> _history = [];

  /// 延迟初始化任务队列
  final List<VoidCallback> _lazyInitTasks = [];

  /// 获取当前启动记录
  StartupRecord? get currentRecord => _currentRecord;

  /// 标记启动开始
  /// 在main()函数最开始调用
  /// 副作用：创建新的启动记录
  void markStartupBegin() {
    _currentRecord = StartupRecord(
      startTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 标记启动阶段完成
  /// 参数：phase - 完成的启动阶段
  /// 副作用：更新启动记录的时间戳
  void markPhaseCompleted(StartupPhase phase) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_currentRecord == null) {
      return;
    }
    switch (phase) {
      case StartupPhase.preInit:
        _currentRecord!.preInitCompletedTimestamp = now;
      case StartupPhase.coreInit:
        _currentRecord!.coreInitCompletedTimestamp = now;
      case StartupPhase.uiRender:
        _currentRecord!.uiRenderCompletedTimestamp = now;
      case StartupPhase.completed:
        _currentRecord!.completedTimestamp = now;
        _finalizeStartupRecord();
    }
  }

  /// 完成启动记录
  /// 将当前记录移入历史并执行延迟任务
  /// 副作用：修改历史记录列表，执行延迟初始化任务
  void _finalizeStartupRecord() {
    if (_currentRecord == null) {
      return;
    }
    _history.add(_currentRecord!);
    if (_history.length > kPerformanceLogMaxEntries) {
      _history.removeAt(0);
    }
    _executeLazyInitTasks();
  }

  /// 注册延迟初始化任务
  /// 这些任务在启动完成后执行，不影响启动速度
  /// 参数：task - 延迟执行的初始化函数
  /// 副作用：添加到延迟任务队列
  void registerLazyInitTask(VoidCallback task) {
    _lazyInitTasks.add(task);
  }

  /// 执行所有延迟初始化任务
  /// 副作用：依次执行所有延迟任务
  void _executeLazyInitTasks() {
    for (final VoidCallback task in _lazyInitTasks) {
      task();
    }
    _lazyInitTasks.clear();
  }

  /// 获取平均启动时间（毫秒）
  /// 返回：double - 平均启动时间
  /// 副作用：无
  double getAverageStartupTime() {
    final List<int> durations = _history
        .map((StartupRecord record) => record.totalDurationMs)
        .where((int? duration) => duration != null)
        .cast<int>()
        .toList();
    if (durations.isEmpty) {
      return 0;
    }
    final int total = durations.reduce((int a, int b) => a + b);
    return total / durations.length;
  }

  /// 获取启动记录历史
  /// 返回：List<StartupRecord> - 只读历史记录
  /// 副作用：无
  List<StartupRecord> get history =>
      List<StartupRecord>.unmodifiable(_history);
}
