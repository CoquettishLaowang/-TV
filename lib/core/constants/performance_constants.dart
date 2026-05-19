/// 性能优化相关常量定义模块
/// 定义性能监控、内存管理、启动优化等相关的阈值和配置
/// 被性能优化模块引用

/// 帧率采样间隔（毫秒），每隔此时间采集一次帧率数据
const int kFrameSampleIntervalMs = 500;

/// 帧率采样窗口大小，保留最近N次采样数据用于计算平均帧率
const int kFrameSampleWindowSize = 10;

/// 内存快照采集间隔（秒），定期采集内存使用情况
const int kMemorySnapshotIntervalSeconds = 30;

/// 内存快照历史记录最大条数，超过此数自动清理最旧记录
const int kMemorySnapshotMaxRecords = 100;

/// 图片缓存最大容量（MB），控制WebView和本地图片缓存
const int kImageCacheMaxSizeMb = 50;

/// WebView缓存最大容量（MB）
const int kWebViewCacheMaxSizeMb = 100;

/// 启动阶段定义：预初始化阶段（毫秒），Flutter引擎加载前
const int kStartupPhasePreInitMs = 500;

/// 启动阶段定义：核心初始化阶段（毫秒），加载核心模块
const int kStartupPhaseCoreInitMs = 1000;

/// 启动阶段定义：UI渲染阶段（毫秒），首帧渲染完成
const int kStartupPhaseUiRenderMs = 1500;

/// 懒加载延迟时间（毫秒），非核心模块的延迟加载间隔
const int kLazyLoadDelayMs = 100;

/// 列表预加载阈值，距离底部还有N个item时触发预加载
const int kListPreloadThreshold = 5;

/// 图片预缓存数量，首页平台图标预缓存
const int kImagePreCacheCount = 5;

/// 动画降级帧率阈值，当设备性能不足时降级到此帧率
const int kAnimationDegradedFps = 30;

/// 性能监控日志最大条数
const int kPerformanceLogMaxEntries = 200;

/// GC触发阈值（MB），当内存使用超过此值时主动触发GC建议
const int kGcTriggerThresholdMb = 180;

/// 卡顿判定阈值（毫秒），单帧渲染超过此时间视为卡顿
const int kJankThresholdMs = 16;

/// 严重卡顿判定阈值（毫秒），单帧渲染超过此时间视为严重卡顿
const int kSevereJankThresholdMs = 32;

/// 性能报告上传间隔（秒），定期上传性能数据
const int kPerformanceReportIntervalSeconds = 300;
