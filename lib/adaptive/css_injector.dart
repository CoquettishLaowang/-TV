/// CSS注入器模块
/// 负责将适配规则转换为CSS代码并注入到WebView中
/// 被平台适配器和WebView控制器使用

import '../models/adaptation_config.dart';
import '../web/webview_controller.dart';

/// CSS注入器
/// 将AdaptationConfig中的规则转换为CSS代码，并通过WebView控制器注入
class CssInjector {
  /// TV适配基础CSS模板
  /// 包含TV端通用的样式调整，如隐藏滚动条、增大字体、调整布局等
  static const String _tvBaseCss = '''
    * {
      -webkit-tap-highlight-color: transparent;
    }
    body {
      overflow-x: hidden;
      background: #000;
    }
    ::-webkit-scrollbar {
      display: none;
    }
    .tv-focus-highlight {
      outline: 3px solid #1A91FF !important;
      outline-offset: 2px;
      box-shadow: 0 0 12px rgba(26, 145, 255, 0.5);
    }
  ''';

  /// 生成完整的TV适配CSS代码
  /// 将基础CSS与平台特定规则合并
  /// 参数：config - 适配配置
  /// 返回：String - 完整的CSS代码
  /// 副作用：无
  String generateFullCss(AdaptationConfig config) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('/* TV Video Hub - 适配CSS */');
    buffer.writeln('/* 平台: ${config.platformId} */');
    buffer.writeln('/* 版本: ${config.configVersion} */');
    buffer.writeln();
    buffer.writeln(_tvBaseCss);
    buffer.writeln();
    buffer.writeln(config.generateCss());
    return buffer.toString();
  }

  /// 注入适配CSS到WebView
  /// 参数：controller - WebView控制器 / config - 适配配置
  /// 副作用：向WebView注入CSS代码
  void injectAdaptationCss(
    TvWebViewController controller,
    AdaptationConfig config,
  ) {
    final String css = generateFullCss(config);
    controller.injectCss(css);
  }

  /// 注入焦点高亮CSS
  /// 为WebView中的可聚焦元素添加TV焦点样式
  /// 参数：controller - WebView控制器 / selectors - 可聚焦元素的CSS选择器列表
  /// 副作用：向WebView注入焦点样式CSS
  void injectFocusStyles(
    TvWebViewController controller,
    List<String> selectors,
  ) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('/* TV焦点样式 */');
    for (final String selector in selectors) {
      buffer.writeln('''
        $selector {
          cursor: pointer;
          transition: all 0.2s ease;
        }
        $selector:focus, $selector.tv-focus-highlight {
          outline: 3px solid #1A91FF;
          outline-offset: 2px;
          box-shadow: 0 0 12px rgba(26, 145, 255, 0.5);
          transform: scale(1.05);
          z-index: 10;
        }
      ''');
    }
    controller.injectCss(buffer.toString());
  }

  /// 注入视频播放器优化CSS
  /// 使视频播放器在TV端全屏显示并优化控制按钮大小
  /// 参数：controller - WebView控制器
  /// 副作用：向WebView注入视频播放器样式
  void injectVideoPlayerOptimization(TvWebViewController controller) {
    const String videoCss = '''
      /* 视频播放器TV优化 */
      video {
        width: 100vw !important;
        height: 100vh !important;
        object-fit: contain;
        background: #000;
      }
      .video-player, .player-container, [class*="player"] {
        width: 100vw !important;
        height: 100vh !important;
      }
      .video-player button, .player-container button {
        min-width: 48px;
        min-height: 48px;
      }
      .video-player input[type="range"],
      .player-container input[type="range"] {
        height: 8px;
      }
    ''';
    controller.injectCss(videoCss);
  }

  /// 注入布局调整CSS
  /// 将网页的多列布局调整为适合TV大屏的单列或双列布局
  /// 参数：controller - WebView控制器
  /// 副作用：向WebView注入布局样式
  void injectLayoutAdjustment(TvWebViewController controller) {
    const String layoutCss = '''
      /* TV布局调整 */
      .main-content, [class*="main"], [class*="content"] {
        max-width: 100vw;
        padding: 0 48px;
      }
      .grid-view, [class*="grid"], [class*="list"] {
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 24px;
      }
      .sidebar, [class*="sidebar"], [class*="side-bar"] {
        display: none !important;
      }
    ''';
    controller.injectCss(layoutCss);
  }
}
