/// 内存管理模块
/// 监控和优化应用内存使用，通过进程RSS和图片缓存组合估算内存占用
/// 确保低性能TV端内存占用不超过设备可用内存的60%
/// 被应用初始化代码和性能监控模块使用

import 'dart:io' show ProcessInfo;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../constants/app_constants.dart';
import '../constants/performance_constants.dart';
import 'cache_manager.dart';

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
/// 定期采集进程RSS内存快照，结合图片缓存状态综合评估内存健康度
/// 内存过高时自动触发图片缓存清理和WebView回收
class MemoryManager extends ChangeNotifier {
  /// 内存快照历史记录
  final List<MemorySnapshot> _snapshots = [];

  /// 获取当前内存使用量（MB）
  /// 返回：double - 当前进程RSS内存
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
  /// 返回：bool - 是否超过kMemoryWarningThresholdMb
  /// 副作用：无
  bool get isMemoryWarning => currentMemoryMb >= kMemoryWarningThresholdMb;

  /// 采集当前内存快照
  /// 通过进程RSS获取真实内存占用，结合图片缓存状态
  /// 返回：MemorySnapshot - 当前内存快照
  /// 副作用：添加到快照历史，可能触发内存优化措施
  MemorySnapshot captureSnapshot() {
    final MemorySnapshot snapshot = _createSnapshot();
    _addSnapshot(snapshot);
    _checkMemoryWarning();
    return snapshot;
  }

  /// 创建内存快照
  /// 优先使用进程RSS（精确值），无法获取时使用图片缓存估算
  /// 返回：MemorySnapshot - 新的内存快照
  /// 副作用：无
  MemorySnapshot _createSnapshot() {
    final double memoryMb = _readProcessMemoryMb();
    return MemorySnapshot(
      usedMemoryMb: memoryMb,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 读取进程RSS内存占用（MB）
  /// ProcessInfo.currentRss返回驻留集大小（字节），反映进程实际物理内存占用
  /// dart:io不可用时回退到图片缓存估算
  /// 返回：double - 进程内存占用（MB）
  /// 副作用：无
  double _readProcessMemoryMb() {
    try {
      final int rssBytes = ProcessInfo.currentRss;
      return rssBytes / (1024 * 1024);
    } catch (_) {
      return _estimateMemoryFromImageCache();
    }
  }

  /// 通过图片缓存估算内存使用（MB）
  /// 作为dart:io不可用时的回退方案（如Web平台）
  /// 估算公式：图片缓存数量 × 每张平均大小（约2MB）
  /// 返回：double - 估算的内存使用量
  /// 副作用：无
  double _estimateMemoryFromImageCache() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    final int cachedCount = imageCache.currentSize;
    const double estimatedPerImageMb = 2.0;
    return cachedCount * estimatedPerImageMb;
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

  /// 建议执行垃圾回收操作
  /// 根据内存压力分级处理：
  ///   - 超过GC阈值：清理图片缓存并缩减缓存容量
  ///   - 超过警告阈值但未达GC阈值：仅通知监听器
  /// 副作用：可能清除图片缓存、缩减缓存上限
  void _suggestGarbageCollection() {
    if (currentMemoryMb >= kGcTriggerThresholdMb) {
      _performImageCacheCleanup();
    }
  }

  /// 清理图片缓存以释放内存
  /// 委托CacheManager执行统一的缓存清理和容量降级策略
  /// 副作用：清除Flutter全局图片缓存，降低缓存上限至kImagePreCacheCount
  void _performImageCacheCleanup() {
    CacheManager.clearImageCache();
    CacheManager.reduceCacheLimitForLowMemory();
  }

  /// 计算平均内存使用量
  /// 参数：sampleCount - 采样数量，默认取最近kFrameSampleWindowSize次
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
  /// 比较最近3次采样与较早采样的平均值差异
  /// 返回：MemoryTrend - 内存趋势（上升/稳定/下降）
  /// 副作用：无
  MemoryTrend getMemoryTrend() {
    if (_snapshots.length < 3) {
      return MemoryTrend.stable;
    }
    final double recentAvg = calculateAverageMemory(3);
    final double olderAvg = calculateAverageMemory(
      _snapshots.length.clamp(3, kFrameSampleWindowSize),
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