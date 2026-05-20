/// DOM分析器模块
/// 分析WebView中的DOM结构，检测网页格式变化
/// 被自适应规则引擎使用，实现网页格式变化时的自动适配
library;

import '../web/webview_controller.dart';

/// DOM结构快照
/// 记录网页DOM的关键特征，用于比较格式变化
class DomSnapshot {
  /// 导航栏元素数量
  final int navElementCount;

  /// 视频卡片元素数量
  final int videoCardCount;

  /// 链接元素数量
  final int linkCount;

  /// 图片元素数量
  final int imageCount;

  /// 页面主要结构特征哈希
  final String structureHash;

  /// 采集时间戳
  final int timestamp;

  /// 构造函数
  const DomSnapshot({
    required this.navElementCount,
    required this.videoCardCount,
    required this.linkCount,
    required this.imageCount,
    required this.structureHash,
    required this.timestamp,
  });

  /// 计算与另一个快照的差异度
  /// 返回值0.0表示完全相同，1.0表示完全不同
  /// 参数：other - 另一个DOM快照
  /// 返回：double - 差异度（0.0~1.0）
  /// 副作用：无
  double calculateDifference(DomSnapshot other) {
    int differenceCount = 0;
    const int totalMetrics = 4;

    if (navElementCount != other.navElementCount) differenceCount++;
    if (videoCardCount != other.videoCardCount) differenceCount++;
    if (linkCount != other.linkCount) differenceCount++;
    if (imageCount != other.imageCount) differenceCount++;

    return differenceCount / totalMetrics;
  }
}

/// DOM分析器
/// 通过JavaScript查询WebView中的DOM结构，检测格式变化
class DomAnalyzer {
  /// DOM变化检测阈值，差异度超过此值认为格式已变化
  /// 来源：经验值，0.5表示超过一半的指标发生变化
  static const double _changeThreshold = 0.5;

  /// 上次采集的DOM快照缓存
  final Map<String, DomSnapshot> _snapshotCache = {};

  /// 获取指定平台的缓存快照
  /// 参数：platformId - 平台ID
  /// 返回：DomSnapshot? - 缓存的快照
  /// 副作用：无
  DomSnapshot? getCachedSnapshot(String platformId) {
    return _snapshotCache[platformId];
  }

  /// 从WebView采集当前DOM结构快照
  /// 参数：controller - WebView控制器 / platformId - 平台ID
  /// 返回：Future<DomSnapshot> - 当前DOM快照
  /// 副作用：执行JavaScript查询DOM
  Future<DomSnapshot> captureSnapshot(
    TvWebViewController controller,
    String platformId,
  ) async {
    final int navCount = await _queryElementCount(controller, 'nav, header, [role="navigation"]');
    final int cardCount = await _queryElementCount(controller, '.video-card, .card, .feed-card, article');
    final int linkCount = await _queryElementCount(controller, 'a');
    final int imageCount = await _queryElementCount(controller, 'img');

    final DomSnapshot snapshot = DomSnapshot(
      navElementCount: navCount,
      videoCardCount: cardCount,
      linkCount: linkCount,
      imageCount: imageCount,
      structureHash: _computeHash(navCount, cardCount, linkCount, imageCount),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _snapshotCache[platformId] = snapshot;
    return snapshot;
  }

  /// 查询WebView中匹配选择器的元素数量
  /// 参数：controller - WebView控制器 / selector - CSS选择器
  /// 返回：Future<int> - 匹配的元素数量
  /// 副作用：执行JavaScript
  Future<int> _queryElementCount(
    TvWebViewController controller,
    String selector,
  ) async {
    final String? result = await controller.executeJavaScript(
      'document.querySelectorAll("$selector").length',
    );
    if (result == null) {
      return 0;
    }
    return int.tryParse(result) ?? 0;
  }

  /// 计算结构特征哈希
  /// 参数：navCount - 导航元素数 / cardCount - 卡片数 / linkCount - 链接数 / imageCount - 图片数
  /// 返回：String - 特征哈希字符串
  /// 副作用：无
  String _computeHash(int navCount, int cardCount, int linkCount, int imageCount) {
    return '${navCount}_${cardCount}_${linkCount}_$imageCount';
  }

  /// 检测DOM是否发生显著变化
  /// 参数：platformId - 平台ID / currentSnapshot - 当前快照
  /// 返回：bool - 是否发生显著变化（需要重新适配）
  /// 副作用：无
  bool hasSignificantChange(String platformId, DomSnapshot currentSnapshot) {
    final DomSnapshot? previousSnapshot = _snapshotCache[platformId];
    if (previousSnapshot == null) {
      return false;
    }
    final double difference = previousSnapshot.calculateDifference(currentSnapshot);
    return difference >= _changeThreshold;
  }

  /// 清除指定平台的快照缓存
  /// 参数：platformId - 平台ID
  /// 副作用：删除缓存
  void clearSnapshot(String platformId) {
    _snapshotCache.remove(platformId);
  }

  /// 清除所有快照缓存
  /// 副作用：清空缓存
  void clearAllSnapshots() {
    _snapshotCache.clear();
  }
}
