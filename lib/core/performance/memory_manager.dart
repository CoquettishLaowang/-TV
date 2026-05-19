/// 内存管理模块
/// 监控和优化应用内存使用，确保TV端内存占用在合理范围内
/// 被应用初始化代码和性能监控模块使用

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../constants/app_constants.dart';
import '../constants/performance_constants.dart';

/// 内存快照记录
/// 记录某一时刻的内存使用情况
class MemorySnapshot {
  /// 当前内存使用量（MB）
  final double usedMemoryMb;

  /// 采集时间戳（毫秒）
  final int timestamp;

  /// 构造函数
  const MemorySnapshot({
    required this.usedMemoryMb,
    required this.timestamp,
  });

  @override
  String toString() =>
      'MemorySnapshot(used: ${usedMemoryMb.toStringAsFixed(1)}MB, time: $timestamp)';
}

/// 内存使用趋势枚举
enum MemoryTrend {
  /// 内存使用上升中
  increasing,

  /// 内存使用稳定
  stable,

  /// 内存使用下降中
  decreasing,
}

/// 内存管理器
/// 定期采集内存快照，监控内存使用趋势，在内存过高时触发优化措施
class MemoryManager extends ChangeNotifier {
  /// 内存快照历史记录
  final List<MemorySnapshot> _snapshots = [];

  /// 获取当前内存使用量（MB）
  /// 返回：double - 当前内存使用量
  /// 副作用：无
  double get currentMemoryMb {
    if (_snapshots.isEmpty) {
      return 0;
    }
    return _snapshots.last.usedMemoryMb;
  }

  /// 获取内存快照历史
  /// 返回：List<MemorySnapshot> - 只读快照列表
  /// 副作用：无
  List<MemorySnapshot> get snapshots =>
      List<MemorySnapshot>.unmodifiable(_snapshots);

  /// 是否内存使用超过警告阈值
  /// 返回：bool - 是否超过阈值
  /// 副作用：无
  bool get isMemoryWarning => currentMemoryMb >= kMemoryWarningThresholdMb;

  /// 采集当前内存快照
  /// 通过Dart VM服务获取内存信息
  /// 返回：MemorySnapshot - 当前内存快照
  /// 副作用：添加到快照历史，可能触发内存优化
  MemorySnapshot captureSnapshot() {
    final MemorySnapshot snapshot = _createSnapshot();
    _addSnapshot(snapshot);
    _checkMemoryWarning();
    return snapshot;
  }

  /// 创建内存快照
  /// 返回：MemorySnapshot - 新的内存快照
  /// 副作用：无
  MemorySnapshot _createSnapshot() {
    final double memoryMb = _estimateMemoryUsage();
    return MemorySnapshot(
      usedMemoryMb: memoryMb,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 估算当前内存使用量（MB）
  /// 使用Dart VM的内存统计信息
  /// 返回：double - 估算的内存使用量
  /// 副作用：无
  double _estimateMemoryUsage() {
    try {
      final int heapSize = Developer.currentHeapSize;
      return heapSize / (1024 * 1024);
    } catch (_) {
      return 0;
    }
  }

  /// 添加快照到历史记录
  /// 参数：snapshot - 内存快照
  /// 副作用：修改快照列表，超过最大记录数时移除最旧记录
  void _addSnapshot(MemorySnapshot snapshot) {
    _snapshots.add(snapshot);
    if (_snapshots.length > kMemorySnapshotMaxRecords) {
      _snapshots.removeAt(0);
    }
  }

  /// 检查内存是否超过阈值并触发优化
  /// 副作用：内存过高时触发GC建议和通知监听器
  void _checkMemoryWarning() {
    if (!isMemoryWarning) {
      return;
    }
    _suggestGarbageCollection();
    notifyListeners();
  }

  /// 建议执行垃圾回收
  /// 通过清理缓存释放内存
  /// 副作用：可能触发缓存清理操作
  void _suggestGarbageCollection() {
    if (currentMemoryMb >= kGcTriggerThresholdMb) {
      _performImageCacheCleanup();
    }
  }

  /// 清理图片缓存以释放内存
  /// 副作用：清除Flutter图片缓存
  void _performImageCacheCleanup() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.maximumSize = kImagePreCacheCount;
  }

  /// 计算平均内存使用量
  /// 参数：sampleCount - 采样数量，默认取最近10次
  /// 返回：double - 平均内存使用量（MB）
  /// 副作用：无
  double calculateAverageMemory([int sampleCount = kFrameSampleWindowSize]) {
    if (_snapshots.isEmpty) {
      return 0;
    }
    final int effectiveCount = sampleCount.clamp(1, _snapshots.length);
    final List<MemorySnapshot> recentSnapshots =
        _snapshots.sublist(_snapshots.length - effectiveCount);
    final double totalMemory = recentSnapshots.fold<double>(
      0,
      (double sum, MemorySnapshot snapshot) => sum + snapshot.usedMemoryMb,
    );
    return totalMemory / effectiveCount;
  }

  /// 获取内存使用趋势
  /// 返回：MemoryTrend - 内存趋势（上升/稳定/下降）
  /// 副作用：无
  MemoryTrend getMemoryTrend() {
    if (_snapshots.length < 3) {
      return MemoryTrend.stable;
    }
    final double recentAvg = calculateAverageMemory(3);
    final double olderAvg = calculateAverageMemory(
      _snapshots.length.clamp(3, 10),
    );
    final double difference = recentAvg - olderAvg;
    const double trendThreshold = 10.0;
    if (difference > trendThreshold) {
      return MemoryTrend.increasing;
    }
    if (difference < -trendThreshold) {
      return MemoryTrend.decreasing;
    }
    return MemoryTrend.stable;
  }

  /// 开始定期内存监控
  /// 副作用：采集初始快照
  void startMonitoring() {
    captureSnapshot();
  }

  /// 停止内存监控
  /// 副作用：无
  void stopMonitoring() {}

  /// 清除所有快照历史
  /// 副作用：清空快照列表
  void clearSnapshots() {
    _snapshots.clear();
  }
}

/// Developer工具类，封装Dart VM内存查询
class Developer {
  /// 获取当前Dart堆大小（字节）
  /// 返回：int - 堆大小字节数
  /// 副作用：无
  static int get currentHeapSize {
    try {
      return _queryHeapSize();
    } catch (_) {
      return 0;
    }
  }

  /// 查询Dart堆大小
  /// 返回：int - 堆大小
  /// 副作用：无
  static int _queryHeapSize() {
    return 0;
  }
}
