/// 帧率监控模块
/// 监控应用帧率性能，检测卡顿并记录性能数据
/// 被性能监控模块和调试工具使用
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../constants/app_constants.dart';
import '../constants/performance_constants.dart';

/// 帧率采样记录
/// 记录单次帧率采样的数据
class FrameSample {
  /// 当前帧率（fps）
  final double framesPerSecond;

  /// 采样时间戳（毫秒）
  final int timestamp;

  /// 是否发生卡顿
  final bool isJank;

  /// 构造函数
  const FrameSample({
    required this.framesPerSecond,
    required this.timestamp,
    required this.isJank,
  });
}

/// 帧率监控器
/// 使用Flutter的SchedulerBinding监听帧回调，计算实时帧率
class FrameMonitor extends ChangeNotifier {
  /// 帧率采样历史
  final List<FrameSample> _samples = [];

  /// 上一帧的时间戳（微秒）
  int? _lastFrameTimestamp;

  /// 是否正在监控
  bool _isMonitoring = false;

  /// 连续卡顿帧数计数器
  int _consecutiveJankFrames = 0;

  /// 获取当前帧率
  /// 返回：double - 当前帧率，无数据时返回0
  /// 副作用：无
  double get currentFps {
    if (_samples.isEmpty) {
      return 0;
    }
    return _samples.last.framesPerSecond;
  }

  /// 获取平均帧率
  /// 返回：double - 平均帧率
  /// 副作用：无
  double get averageFps {
    if (_samples.isEmpty) {
      return 0;
    }
    final double totalFps = _samples.fold<double>(
      0,
      (double sum, FrameSample sample) => sum + sample.framesPerSecond,
    );
    return totalFps / _samples.length;
  }

  /// 是否正在发生卡顿
  /// 返回：bool - 当前帧率是否低于卡顿阈值
  /// 副作用：无
  bool get isJanking => currentFps > 0 && currentFps < kFrameDropThreshold;

  /// 获取采样历史
  /// 返回：List<FrameSample> - 只读采样列表
  /// 副作用：无
  List<FrameSample> get samples => List<FrameSample>.unmodifiable(_samples);

  /// 开始帧率监控
  /// persistent frame callback仅注册一次，SchedulerBinding每帧自动调用
  /// 副作用：注册持久帧回调，开始采集帧率数据
  void startMonitoring() {
    if (_isMonitoring) {
      return;
    }
    _isMonitoring = true;
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  /// 停止帧率监控
  /// 副作用：移除帧回调
  void stopMonitoring() {
    _isMonitoring = false;
  }

  /// 帧回调处理
  /// persistent callback由SchedulerBinding自动每帧调用，无需重复注册
  /// 参数：durationStamp - 帧时间戳
  /// 副作用：计算帧率，添加采样记录
  void _onFrame(Duration durationStamp) {
    if (!_isMonitoring) {
      return;
    }

    final int currentTimestamp = durationStamp.inMicroseconds;
    if (_lastFrameTimestamp == null) {
      _lastFrameTimestamp = currentTimestamp;
      return;
    }

    final int frameDelta = currentTimestamp - _lastFrameTimestamp!;
    _lastFrameTimestamp = currentTimestamp;

    if (frameDelta <= 0) {
      return;
    }

    _processFrameDelta(frameDelta);
  }

  /// 处理帧间隔数据
  /// 参数：frameDeltaMicroseconds - 帧间隔（微秒）
  /// 副作用：添加采样记录，检测卡顿
  void _processFrameDelta(int frameDeltaMicroseconds) {
    final double fps = 1000000.0 / frameDeltaMicroseconds;
    final bool isJank = frameDeltaMicroseconds > kJankThresholdMs * 1000;

    if (isJank) {
      _consecutiveJankFrames++;
    } else {
      _consecutiveJankFrames = 0;
    }

    final FrameSample sample = FrameSample(
      framesPerSecond: fps,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isJank: isJank,
    );

    _addSample(sample);

    if (_consecutiveJankFrames >= kFrameSampleWindowSize) {
      _handleSustainedJank();
    }
  }

  /// 添加采样记录
  /// 参数：sample - 帧率采样
  /// 副作用：修改采样列表，超过最大记录数时移除最旧记录
  void _addSample(FrameSample sample) {
    _samples.add(sample);
    if (_samples.length > kPerformanceLogMaxEntries) {
      _samples.removeAt(0);
    }
  }

  /// 处理持续卡顿
  /// 当连续多帧卡顿时触发性能优化措施
  /// 副作用：通知监听器
  void _handleSustainedJank() {
    notifyListeners();
  }

  /// 计算指定时间范围内的平均帧率
  /// 参数：durationMs - 时间范围（毫秒）
  /// 返回：double - 平均帧率
  /// 副作用：无
  double calculateFpsInRange(int durationMs) {
    final int cutoffTimestamp =
        DateTime.now().millisecondsSinceEpoch - durationMs;
    final List<FrameSample> recentSamples = _samples
        .where((FrameSample sample) => sample.timestamp >= cutoffTimestamp)
        .toList();
    if (recentSamples.isEmpty) {
      return 0;
    }
    final double totalFps = recentSamples.fold<double>(
      0,
      (double sum, FrameSample sample) => sum + sample.framesPerSecond,
    );
    return totalFps / recentSamples.length;
  }

  /// 获取卡顿帧数统计
  /// 返回：int - 卡顿帧总数
  /// 副作用：无
  int get jankFrameCount =>
      _samples.where((FrameSample sample) => sample.isJank).length;

  /// 清除所有采样记录
  /// 副作用：清空采样列表
  void clearSamples() {
    _samples.clear();
    _consecutiveJankFrames = 0;
  }

  @override
  /// dispose()设计说明：
  ///   - Flutter的SchedulerBinding.addPersistentFrameCallback 注册的回调
  ///     在SchedulerBinding生命周期内持续有效，无直接的remove API
  ///   - 通过设置 _isMonitoring = false 标志，每次回调都会做早期返回（见_onFrame首行检查）
  ///   - 这是Flutter中停止PersistentFrameCallback的标准做法，
  ///     参考 SchedulerBinding.handleDrawFrame 的实现模式
  ///   - 副作用：回调函数对象仍保留在SchedulerBinding的_callbacks列表中，
  ///     但不执行任何操作，内存开销可忽略（单个闭包引用）
  void dispose() {
    _isMonitoring = false;
    _samples.clear();
    super.dispose();
  }
}
