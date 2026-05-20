/// 播放器页面模块
/// 视频全屏播放页面，优化视频播放体验
/// TV端：大图标控制栏适配遥控器操作
/// 手机端：标准图标控制栏适配触摸操作
/// 被平台页面调用
library;

import 'package:flutter/material.dart';

import '../core/responsive/responsive_adapter.dart';
import '../core/theme/tv_dimensions.dart';
import '../web/tv_webview.dart';
import '../web/webview_controller.dart';

/// 播放器控制栏高度增量（在底部导航栏基础上加额外空间）
const double _controlBarExtraHeight = 40.0;

/// 播放器页面
/// 全屏展示视频内容，支持遥控器控制和触摸控制播放/暂停/快进等
class PlayerPage extends StatefulWidget {
  /// 视频URL
  final String videoUrl;

  /// 返回回调
  final VoidCallback onGoBack;

  /// 构造函数
  const PlayerPage({
    super.key,
    required this.videoUrl,
    required this.onGoBack,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

/// 播放器页面状态类
class _PlayerPageState extends State<PlayerPage> {
  /// WebView控制器
  late TvWebViewController _webViewController;

  /// 是否显示控制栏
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _webViewController = TvWebViewController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          widget.onGoBack();
        }
      },
      child: GestureDetector(
        // 点击切换控制栏显示/隐藏
        onTap: toggleControls,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _buildVideoPlayer(),
              if (_showControls) _buildControlOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建视频播放器
  /// 返回：Widget - WebView视频播放器
  /// 副作用：无
  Widget _buildVideoPlayer() {
    return Positioned.fill(
      child: TvWebView(
        controller: _webViewController,
        initialUrl: widget.videoUrl,
      ),
    );
  }

  /// 构建控制栏覆盖层
  /// 参数：context - 构建上下文
  /// 返回：Widget - 播放控制栏
  /// 副作用：无
  Widget _buildControlOverlay(BuildContext context) {
    final ResponsiveConfig responsiveConfig = ResponsiveAdapter.of(context);
    const double barHeight = kBottomBarHeight + _controlBarExtraHeight;
    final double iconSize = responsiveConfig.iconSizeLarge;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveConfig.pageHorizontalPadding,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.play_arrow,
              iconSize: iconSize,
              onPressed: _handlePlayPause,
            ),
            SizedBox(width: responsiveConfig.cardHorizontalSpacing),
            _buildControlButton(
              icon: Icons.replay_10,
              iconSize: iconSize,
              onPressed: _handleRewind,
            ),
            SizedBox(width: responsiveConfig.cardHorizontalSpacing),
            _buildControlButton(
              icon: Icons.forward_10,
              iconSize: iconSize,
              onPressed: _handleForward,
            ),
            SizedBox(width: responsiveConfig.cardHorizontalSpacing),
            _buildControlButton(
              icon: Icons.fullscreen_exit,
              iconSize: iconSize,
              onPressed: widget.onGoBack,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个控制按钮
  /// 参数：icon - 图标 / iconSize - 图标尺寸 / onPressed - 点击回调
  /// 返回：Widget - 图标按钮
  /// 副作用：无
  Widget _buildControlButton({
    required IconData icon,
    required double iconSize,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  /// 处理播放/暂停
  /// 副作用：向WebView发送播放/暂停JavaScript命令
  void _handlePlayPause() {
    _webViewController.executeJavaScript(
      'var v = document.querySelector("video"); if(v) { v.paused ? v.play() : v.pause(); }',
    );
  }

  /// 处理后退10秒
  /// 副作用：向WebView发送后退JavaScript命令
  void _handleRewind() {
    _webViewController.executeJavaScript(
      'var v = document.querySelector("video"); if(v) { v.currentTime = Math.max(0, v.currentTime - 10); }',
    );
  }

  /// 处理快进10秒
  /// 副作用：向WebView发送快进JavaScript命令
  void _handleForward() {
    _webViewController.executeJavaScript(
      'var v = document.querySelector("video"); if(v) { v.currentTime += 10; }',
    );
  }

  /// 切换控制栏显示状态
  /// 副作用：修改_showControls状态
  void toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _webViewController.dispose();
    super.dispose();
  }
}