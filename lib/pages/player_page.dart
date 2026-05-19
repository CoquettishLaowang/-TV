/// 播放器页面模块
/// 视频全屏播放页面，优化TV端视频播放体验
/// 被平台页面调用

import 'package:flutter/material.dart';

import '../core/theme/tv_dimensions.dart';
import '../web/tv_webview.dart';
import '../web/webview_controller.dart';

/// 播放器页面
/// 全屏展示视频内容，支持TV遥控器控制播放/暂停/快进等
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
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildVideoPlayer(),
            if (_showControls) _buildControlOverlay(),
          ],
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
  /// 返回：Widget - 播放控制栏
  /// 副作用：无
  Widget _buildControlOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: kBottomBarHeight + 40,
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
        padding: const EdgeInsets.symmetric(
          horizontal: kPageHorizontalPadding,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _handlePlayPause,
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: kIconSizeLarge,
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _handleRewind,
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
                size: kIconSizeLarge,
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _handleForward,
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: kIconSizeLarge,
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: widget.onGoBack,
              icon: const Icon(
                Icons.fullscreen_exit,
                color: Colors.white,
                size: kIconSizeLarge,
              ),
            ),
          ],
        ),
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
