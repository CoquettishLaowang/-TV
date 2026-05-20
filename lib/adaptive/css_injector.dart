/// CSS注入器模块
/// 负责将适配规则转换为CSS代码并注入到WebView中
/// 被平台适配器和WebView控制器使用
library;

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
    html, body {
      overflow-x: hidden;
      background: #0a0a0a;
      font-size: 20px;
      line-height: 1.6;
    }
    ::-webkit-scrollbar {
      display: none;
    }
    .tv-focus-highlight {
      outline: 3px solid #1A91FF !important;
      outline-offset: 2px;
      box-shadow: 0 0 16px rgba(26, 145, 255, 0.6);
      transform: scale(1.05);
      z-index: 100;
    }
  ''';

  /// TV布局完整转换CSS - 将PC网页转换为TV大屏布局
  static const String _tvLayoutTransformCss = '''
    body {
      zoom: 1.0;
    }
    nav, header, .header, [class*="nav"], [class*="header"] {
      min-height: 60px;
      padding: 8px 32px;
    }
    nav a, header a, .nav-item, .nav-link, [class*="nav"] a {
      font-size: 20px !important;
      padding: 14px 24px !important;
      min-width: 80px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    h1 { font-size: 36px !important; }
    h2 { font-size: 30px !important; }
    h3 { font-size: 26px !important; }
    h4 { font-size: 22px !important; }
    h5, h6 { font-size: 20px !important; }
    p, span, div, li, td, th {
      font-size: 20px !important;
    }
    p, li { line-height: 1.7; }
    img, video {
      max-width: 100%;
      height: auto;
    }
    button, .btn, [role="button"], [type="button"], [type="submit"] {
      min-height: 48px !important;
      min-width: 64px !important;
      font-size: 20px !important;
      padding: 12px 28px !important;
      border-radius: 8px;
    }
    input, textarea, select {
      font-size: 20px !important;
      min-height: 44px !important;
      padding: 10px 16px !important;
      border-radius: 6px;
    }
    input[type="checkbox"], input[type="radio"] {
      min-width: 24px !important;
      min-height: 24px !important;
    }
    a {
      font-size: 20px !important;
      min-height: 44px;
      display: inline-flex;
      align-items: center;
    }
    .video-card, .card, [class*="card"], [class*="poster"], [class*="thumb"] {
      min-width: 280px;
      min-height: 180px;
    }
    .video-card img, .card img, [class*="poster"] img, [class*="thumb"] img {
      min-height: 160px;
      object-fit: cover;
    }
    form, .form, [class*="form"] {
      max-width: 800px;
      margin: 0 auto;
    }
    .login-form, .login-container, .login-box, [class*="login"] {
      max-width: 600px;
      margin: 40px auto;
      padding: 32px;
    }
    .login-form input, .login-container input, .login-box input, [class*="login"] input {
      width: 100%;
      margin-bottom: 16px;
      font-size: 22px !important;
      min-height: 52px !important;
    }
    .login-form button, .login-container button, .login-box button, [class*="login"] button {
      width: 100%;
      min-height: 56px !important;
      font-size: 22px !important;
    }
  ''';

  static const String _tvMediaQueryCss = '''
    @media screen and (min-width: 1280px) {
      body {
        font-size: 22px;
      }
      .video-card, .card, [class*="card"], [class*="poster"] {
        min-width: 320px;
      }
    }
    @media screen and (min-width: 1920px) {
      body {
        font-size: 24px;
      }
      h1 { font-size: 42px !important; }
      h2 { font-size: 36px !important; }
      h3 { font-size: 30px !important; }
      .video-card, .card, [class*="card"], [class*="poster"] {
        min-width: 360px;
      }
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
    buffer.writeln(_tvLayoutTransformCss);
    buffer.writeln();
    buffer.writeln(_tvMediaQueryCss);
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
      video {
        width: 100vw !important;
        height: auto !important;
        max-height: 70vh;
        object-fit: contain;
        background: #000;
      }
      .video-player, .player-container, [class*="player"] {
        width: 100vw !important;
        max-width: 100vw !important;
      }
      .video-player video, .player-container video, [class*="player"] video {
        width: 100% !important;
        height: auto !important;
      }
      .video-player button, .player-container button, [class*="player"] button,
      .video-player .control-btn, [class*="player"] .control-btn {
        min-width: 56px !important;
        min-height: 56px !important;
        font-size: 22px !important;
        padding: 10px 16px !important;
      }
      .video-player input[type="range"],
      .player-container input[type="range"],
      [class*="player"] input[type="range"] {
        height: 10px !important;
        min-height: 10px !important;
      }
      .video-player .progress-bar,
      .player-container .progress-bar,
      [class*="player"] .progress-bar {
        height: 8px !important;
      }
      .video-player .volume-slider,
      .player-container .volume-slider,
      [class*="player"] .volume-slider {
        height: 8px !important;
      }
      .video-player .time-display,
      .player-container .time-display,
      [class*="player"] .time-display {
        font-size: 20px !important;
      }
      .video-player .quality-btn,
      .player-container .quality-btn,
      [class*="player"] .quality-btn,
      .video-player .fullscreen-btn,
      .player-container .fullscreen-btn {
        min-width: 56px !important;
        min-height: 56px !important;
        font-size: 20px !important;
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
      .main-content, [class*="main"], [class*="content"] {
        max-width: 100vw;
        padding: 0 48px;
        margin: 0;
      }
      .grid-view, [class*="grid"], [class*="list"] {
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 24px;
      }
      .sidebar, [class*="sidebar"], [class*="side-bar"], [class*="aside"] {
        display: none !important;
      }
      .container, .wrap, .wrapper, [class*="container"], [class*="wrapper"] {
        max-width: 100vw !important;
        padding: 16px 48px !important;
      }
      .page, .page-content, [class*="page"] {
        width: 100vw !important;
        max-width: 100vw !important;
      }
      section, .section, [class*="section"] {
        padding: 24px 0;
      }
      .row, [class*="row"] {
        margin: 0 -12px;
      }
      .col, [class*="col"] {
        padding: 12px;
      }
      .video-list, .card-list, [class*="list"] {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 24px;
      }
      .video-list > *, .card-list > *, [class*="list"] > * {
        width: 100%;
      }
      .modal, .dialog, .popup, .overlay, [class*="modal"], [class*="dialog"] {
        max-width: 90vw;
        max-height: 85vh;
      }
      .modal input, .dialog input, .popup input, .overlay input,
      [class*="modal"] input, [class*="dialog"] input {
        font-size: 20px !important;
        min-height: 48px !important;
      }
      .modal button, .dialog button, .popup button, .overlay button,
      [class*="modal"] button, [class*="dialog"] button {
        min-height: 52px !important;
        font-size: 20px !important;
        padding: 12px 28px !important;
      }
      .tab-bar, .tabs, [class*="tab"] {
        font-size: 20px !important;
      }
      .tab-bar a, .tabs a, [class*="tab"] a, .tab-item {
        padding: 14px 28px !important;
        font-size: 20px !important;
        min-width: 100px;
      }
      .dropdown, .select, [class*="dropdown"], [class*="select"] {
        font-size: 20px !important;
        min-height: 44px !important;
      }
      .pagination, [class*="pagination"], .page-nav {
        font-size: 20px !important;
      }
      .pagination a, [class*="pagination"] a, .page-nav a,
      .pagination button, [class*="pagination"] button {
        min-width: 48px !important;
        min-height: 48px !important;
        font-size: 20px !important;
      }
      footer, .footer, [class*="footer"] {
        font-size: 18px !important;
        padding: 24px 48px !important;
      }
    ''';
    controller.injectCss(layoutCss);
  }
}
