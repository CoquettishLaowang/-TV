/// 缓存管理模块
/// 统一管理图片缓存和WebView缓存的初始化、容量控制和清理策略
/// 针对低性能TV设备优化缓存行为，控制内存占用
/// 被应用入口main()调用以初始化缓存策略

import 'package:flutter/painting.dart';

import '../constants/performance_constants.dart';

/// 缓存管理器
/// 在应用启动时配置Flutter图片缓存容量和WebView缓存策略
/// 避免低性能TV设备因缓存膨胀导致OOM
class CacheManager {
  /// 图片缓存最大尺寸（逻辑对象数）
  /// TV端128MB内存设备限制为100张以下，避免单个图片缓存导致内存超标
  /// 来源：性能需求 - 内存占用<60%，以128MB设备为基准
  static const int _maxImageCacheCount = 80;

  /// 图片缓存最大内存占用（字节）= kImageCacheMaxSizeMb MB
  static const int _maxImageCacheBytes = kImageCacheMaxSizeMb * 1024 * 1024;

  /// 初始化缓存策略
  /// 在main()中WidgetsFlutterBinding初始化后立即调用
  /// 设置图片缓存上限和最大字节数，限制缓存增长
  /// 副作用：修改PaintingBinding的全局图片缓存配置
  static void initializeCachePolicy() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = _maxImageCacheCount;
    imageCache.maximumSizeBytes = _maxImageCacheBytes;
  }

  /// 获取图片缓存当前状态
  /// 返回：当前缓存图片数量
  /// 副作用：无
  static int get cachedImageCount {
    return PaintingBinding.instance.imageCache.currentSize;
  }

  /// 获取图片缓存活跃大小（字节）
  /// 返回：当前缓存占用的字节数
  /// 副作用：无
  static int get cachedImageBytes {
    return PaintingBinding.instance.imageCache.currentSizeBytes;
  }

  /// 清空所有图片缓存
  /// 在内存告急或页面退出时调用以释放内存
  /// 副作用：清除Flutter全局图片缓存
  static void clearImageCache() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
  }

  /// 降低缓存上限到最小值
  /// 在设备内存极度紧张时调用，限制后续缓存增长
  /// TV端降低至kImagePreCacheCount（5张）
  /// 副作用：修改全局图片缓存最大数量
  static void reduceCacheLimitForLowMemory() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = kImagePreCacheCount;
  }

  /// 恢复缓存上限到正常值
  /// 内存压力解除后恢复缓存容量
  /// 副作用：修改全局图片缓存最大数量
  static void restoreCacheLimit() {
    final ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = _maxImageCacheCount;
  }
}