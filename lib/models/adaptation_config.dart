/// 适配配置模型
/// 定义CSS适配规则的配置结构，用于WebView页面注入CSS以适配TV大屏
/// 被自适应规则引擎和CSS注入器使用

/// 适配规则类型枚举
enum AdaptationRuleType {
  /// 隐藏元素规则，移除不需要在TV端显示的元素
  hideElement,

  /// 调整尺寸规则，修改元素大小以适配TV大屏
  resizeElement,

  /// 修改布局规则，调整元素位置和排列方式
  modifyLayout,

  /// 修改字体规则，增大字号以保证远距离可读
  modifyFontSize,

  /// 修改颜色规则，增强对比度以适配TV显示
  modifyColor,

  /// 自定义CSS规则，直接注入CSS代码
  customCss,
}

/// 单条适配规则
/// 描述对网页元素的某一项CSS修改操作
class AdaptationRule {
  /// 规则唯一标识
  final String ruleId;

  /// 规则类型
  final AdaptationRuleType ruleType;

  /// CSS选择器，指定规则作用的目标元素
  final String cssSelector;

  /// CSS属性名，如 'display', 'font-size' 等
  final String cssProperty;

  /// CSS属性值，如 'none', '24px' 等
  final String cssValue;

  /// 规则优先级，数值越大优先级越高
  final int priority;

  /// 规则适用的平台ID列表，为空表示所有平台通用
  final List<String> applicablePlatformIds;

  /// 规则版本号，用于自适应检测格式变化
  final int version;

  /// 构造函数
  /// 参数：ruleId - 规则ID / ruleType - 规则类型 / cssSelector - CSS选择器
  /// 参数：cssProperty - CSS属性 / cssValue - CSS值 / priority - 优先级
  /// 参数：applicablePlatformIds - 适用平台 / version - 版本号
  /// 副作用：无
  const AdaptationRule({
    required this.ruleId,
    required this.ruleType,
    required this.cssSelector,
    required this.cssProperty,
    required this.cssValue,
    this.priority = 0,
    this.applicablePlatformIds = const [],
    this.version = 1,
  });

  /// 将规则转换为CSS声明字符串
  /// 返回：String - CSS声明，如 '.nav { display: none; }'
  /// 副作用：无
  String toCssDeclaration() {
    return '$cssSelector { $cssProperty: $cssValue; }';
  }

  /// 检查规则是否适用于指定平台
  /// 参数：platformId - 平台标识
  /// 返回：bool - 是否适用
  /// 副作用：无
  bool isApplicableForPlatform(String platformId) {
    if (applicablePlatformIds.isEmpty) {
      return true;
    }
    return applicablePlatformIds.contains(platformId);
  }

  /// 从JSON映射创建AdaptationRule实例
  /// 参数：jsonMap - 包含规则数据的Map
  /// 返回：AdaptationRule - 解析后的适配规则
  /// 可能错误：当缺少必要字段时抛出异常
  factory AdaptationRule.fromJson(Map<String, dynamic> jsonMap) {
    return AdaptationRule(
      ruleId: jsonMap['ruleId'] as String,
      ruleType: AdaptationRuleType.values.firstWhere(
        (AdaptationRuleType type) =>
            type.name == jsonMap['ruleType'],
      ),
      cssSelector: jsonMap['cssSelector'] as String,
      cssProperty: jsonMap['cssProperty'] as String,
      cssValue: jsonMap['cssValue'] as String,
      priority: jsonMap['priority'] as int? ?? 0,
      applicablePlatformIds:
          (jsonMap['applicablePlatformIds'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      version: jsonMap['version'] as int? ?? 1,
    );
  }

  /// 转换为JSON映射
  /// 返回：Map<String, dynamic> - 可序列化的规则数据
  /// 副作用：无
  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'ruleType': ruleType.name,
      'cssSelector': cssSelector,
      'cssProperty': cssProperty,
      'cssValue': cssValue,
      'priority': priority,
      'applicablePlatformIds': applicablePlatformIds,
      'version': version,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptationRule && ruleId == other.ruleId && version == other.version;

  @override
  int get hashCode => Object.hash(ruleId, version);
}

/// 适配配置集合
/// 包含某个平台的所有适配规则，由规则引擎管理
class AdaptationConfig {
  /// 配置适用的平台ID
  final String platformId;

  /// 适配规则列表
  final List<AdaptationRule> rules;

  /// 配置版本号，用于检测网页格式变化
  final int configVersion;

  /// 配置最后更新时间戳（毫秒）
  final int lastUpdatedTimestamp;

  /// 构造函数
  /// 参数：platformId - 平台ID / rules - 规则列表
  /// 参数：configVersion - 配置版本 / lastUpdatedTimestamp - 更新时间
  /// 副作用：无
  const AdaptationConfig({
    required this.platformId,
    required this.rules,
    this.configVersion = 1,
    this.lastUpdatedTimestamp = 0,
  });

  /// 获取按优先级排序的规则列表
  /// 返回：List<AdaptationRule> - 优先级从高到低排序的规则
  /// 副作用：无，返回新列表
  List<AdaptationRule> getSortedRules() {
    final List<AdaptationRule> sortedRules = List<AdaptationRule>.from(rules);
    sortedRules.sort(
      (AdaptationRule first, AdaptationRule second) =>
          second.priority.compareTo(first.priority),
    );
    return sortedRules;
  }

  /// 生成完整的CSS注入字符串
  /// 返回：String - 包含所有规则的CSS代码
  /// 副作用：无
  String generateCss() {
    final StringBuffer buffer = StringBuffer();
    for (final AdaptationRule rule in getSortedRules()) {
      buffer.writeln(rule.toCssDeclaration());
    }
    return buffer.toString();
  }

  /// 创建副本，可修改部分字段
  /// 参数：可选修改字段
  /// 返回：AdaptationConfig - 新的配置实例
  /// 副作用：无
  AdaptationConfig copyWith({
    String? platformId,
    List<AdaptationRule>? rules,
    int? configVersion,
    int? lastUpdatedTimestamp,
  }) {
    return AdaptationConfig(
      platformId: platformId ?? this.platformId,
      rules: rules ?? this.rules,
      configVersion: configVersion ?? this.configVersion,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
    );
  }

  @override
  String toString() =>
      'AdaptationConfig(platform: $platformId, rules: ${rules.length}, version: $configVersion)';
}
