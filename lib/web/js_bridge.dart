/// JS桥接模块
/// 定义Flutter与WebView之间的JavaScript通信接口
/// 被WebView控制器使用，实现双向通信

import 'dart:convert';

/// JS桥接消息类型枚举
/// 定义Flutter与WebView之间所有可传递的消息类型
enum JsBridgeMessageType {
  /// DOM结构变化通知
  domChanged,

  /// 页面加载完成通知
  pageLoaded,

  /// 视频播放状态变化
  videoStatusChanged,

  /// 导航请求（用户点击链接）
  navigationRequest,

  /// 适配规则请求
  adaptationRequest,

  /// 错误报告
  errorReport,

  /// 未知消息类型
  unknown,
}

/// JS桥接消息
/// 封装Flutter与WebView之间传递的消息数据
class JsBridgeMessage {
  /// 消息类型
  final JsBridgeMessageType messageType;

  /// 消息负载数据
  final Map<String, dynamic> payload;

  /// 消息时间戳（毫秒）
  final int timestamp;

  /// 构造函数
  const JsBridgeMessage({
    required this.messageType,
    required this.payload,
    required this.timestamp,
  });

  /// 从JSON字符串解析桥接消息
  /// 参数：jsonString - WebView传递的JSON字符串
  /// 返回：JsBridgeMessage - 解析后的消息
  /// 可能错误：JSON格式错误时抛出FormatException
  factory JsBridgeMessage.fromJsonString(String jsonString) {
    final Map<String, dynamic> decoded =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return JsBridgeMessage(
      messageType: _parseMessageType(decoded['type'] as String?),
      payload: decoded['payload'] as Map<String, dynamic>? ?? {},
      timestamp: decoded['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 解析消息类型字符串为枚举
  /// 参数：typeString - 消息类型字符串
  /// 返回：JsBridgeMessageType - 对应的枚举值
  /// 副作用：无
  static JsBridgeMessageType _parseMessageType(String? typeString) {
    if (typeString == null) {
      return JsBridgeMessageType.unknown;
    }
    return JsBridgeMessageType.values.firstWhere(
      (JsBridgeMessageType type) => type.name == typeString,
      orElse: () => JsBridgeMessageType.unknown,
    );
  }

  /// 转换为JSON字符串
  /// 返回：String - 可传递给WebView的JSON字符串
  /// 副作用：无
  String toJsonString() {
    return jsonEncode({
      'type': messageType.name,
      'payload': payload,
      'timestamp': timestamp,
    });
  }
}

/// JS桥接脚本生成器
/// 生成注入到WebView中的JavaScript代码，用于监听DOM变化和用户交互
class JsBridgeScriptGenerator {
  /// 生成DOM变化监听脚本
  /// 使用MutationObserver监听DOM结构变化，当检测到变化时通知Flutter端
  /// 返回：String - JavaScript代码
  /// 副作用：无
  static String generateDomObserverScript() {
    return '''
      (function() {
        var observer = new MutationObserver(function(mutations) {
          var changeCount = mutations.length;
          window.TvBridge.postMessage(JSON.stringify({
            type: "domChanged",
            payload: { changeCount: changeCount },
            timestamp: Date.now()
          }));
        });
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          attributes: true
        });
      })();
    ''';
  }

  /// 生成页面加载完成通知脚本
  /// 返回：String - JavaScript代码
  /// 副作用：无
  static String generatePageLoadedScript() {
    return '''
      (function() {
        window.TvBridge.postMessage(JSON.stringify({
          type: "pageLoaded",
          payload: { url: window.location.href, title: document.title },
          timestamp: Date.now()
        }));
      })();
    ''';
  }

  /// 生成视频播放状态监听脚本
  /// 监听video标签的播放/暂停/结束事件
  /// 返回：String - JavaScript代码
  /// 副作用：无
  static String generateVideoStatusScript() {
    return '''
      (function() {
        var videos = document.getElementsByTagName("video");
        for (var i = 0; i < videos.length; i++) {
          videos[i].addEventListener("play", function() {
            window.TvBridge.postMessage(JSON.stringify({
              type: "videoStatusChanged",
              payload: { status: "playing", index: i },
              timestamp: Date.now()
            }));
          });
          videos[i].addEventListener("pause", function() {
            window.TvBridge.postMessage(JSON.stringify({
              type: "videoStatusChanged",
              payload: { status: "paused", index: i },
              timestamp: Date.now()
            }));
          });
        }
      })();
    ''';
  }

  /// 生成CSS注入脚本
  /// 将适配CSS动态注入到页面中
  /// 参数：cssContent - 要注入的CSS代码
  /// 返回：String - JavaScript代码
  /// 副作用：无
  static String generateCssInjectionScript(String cssContent) {
    final String escapedCss = cssContent
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n');
    return '''
      (function() {
        var existingStyle = document.getElementById("tv-adaptation-style");
        if (existingStyle) {
          existingStyle.remove();
        }
        var style = document.createElement("style");
        style.id = "tv-adaptation-style";
        style.textContent = '$escapedCss';
        document.head.appendChild(style);
      })();
    ''';
  }

  /// 生成元素焦点高亮脚本
  /// 在WebView中模拟TV焦点效果
  /// 参数：selector - 要高亮的元素CSS选择器
  /// 返回：String - JavaScript代码
  /// 副作用：无
  static String generateFocusHighlightScript(String selector) {
    return '''
      (function() {
        var prev = document.querySelector(".tv-focus-highlight");
        if (prev) {
          prev.classList.remove("tv-focus-highlight");
        }
        var target = document.querySelector("$selector");
        if (target) {
          target.classList.add("tv-focus-highlight");
          target.scrollIntoView({ behavior: "smooth", block: "center" });
        }
      })();
    ''';
  }
}
