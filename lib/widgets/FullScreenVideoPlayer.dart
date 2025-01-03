import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _isPlaying = true;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    widget.controller.addListener(() {
      setState(() {
        _sliderValue = widget.controller.value.position.inSeconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _isPlaying = false;
      } else {
        widget.controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreenExit() {
    setState(() {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 0.0,
                    max: widget.controller.value.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        widget.controller
                            .seekTo(Duration(seconds: value.toInt()));
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.fullscreen_exit),
                      onPressed: _toggleFullScreenExit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
