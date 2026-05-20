/// 视频平台信息模型
/// 定义单个视频平台的所有元数据，包括标识、名称、URL、品牌色等
/// 被适配器注册中心、首页平台选择、平台页面等使用
library;

/// 视频平台信息数据类
/// 包含平台的基础信息，用于平台选择和适配器匹配
class PlatformInfo {
  /// 平台唯一标识符，如 'iqiyi', 'bilibili' 等
  final String id;

  /// 平台显示名称，如 '爱奇艺', '哔哩哔哩' 等
  final String name;

  /// 平台网站基础URL，用于WebView加载
  final String baseUrl;

  /// 平台图标资源路径
  final String iconPath;

  /// 平台品牌主色值（ARGB整数）
  final int brandColor;

  /// 平台是否可用（网络可达性检查结果）
  final bool isAvailable;

  /// 构造函数
  /// 参数：id - 平台标识 / name - 显示名称 / baseUrl - 网站URL
  /// 参数：iconPath - 图标路径 / brandColor - 品牌色 / isAvailable - 是否可用
  /// 副作用：无
  const PlatformInfo({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.iconPath,
    required this.brandColor,
    this.isAvailable = true,
  });

  /// 从JSON映射创建PlatformInfo实例
  /// 参数：jsonMap - 包含平台数据的Map
  /// 返回：PlatformInfo - 解析后的平台信息
  /// 可能错误：当缺少必要字段时抛出异常
  factory PlatformInfo.fromJson(Map<String, dynamic> jsonMap) {
    return PlatformInfo(
      id: jsonMap['id'] as String,
      name: jsonMap['name'] as String,
      baseUrl: jsonMap['baseUrl'] as String,
      iconPath: jsonMap['icon'] as String,
      brandColor: _parseColor(jsonMap['color'] as String),
    );
  }

  /// 将十六进制颜色字符串解析为ARGB整数值
  /// 参数：hexColor - 十六进制颜色字符串，如 '#FF6A00'
  /// 返回：int - ARGB颜色值
  /// 副作用：无
  static int _parseColor(String hexColor) {
    final String cleanHex = hexColor.replaceFirst('#', '');
    return int.parse('FF$cleanHex', radix: 16);
  }

  /// 创建副本，可修改部分字段
  /// 参数：可选修改字段
  /// 返回：PlatformInfo - 新的平台信息实例
  /// 副作用：无
  PlatformInfo copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? iconPath,
    int? brandColor,
    bool? isAvailable,
  }) {
    return PlatformInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      iconPath: iconPath ?? this.iconPath,
      brandColor: brandColor ?? this.brandColor,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformInfo && id == other.id && baseUrl == other.baseUrl;

  @override
  int get hashCode => Object.hash(id, baseUrl);

  @override
  String toString() => 'PlatformInfo(id: $id, name: $name)';
}
