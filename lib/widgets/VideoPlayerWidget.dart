import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'FullScreenVideoPlayer.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,
    ))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.addListener(() {
      setState(() {
        _sliderValue = _controller.value.position.inSeconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(controller: _controller),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
          body: Center(
              child: _controller.value.isInitialized
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20.0),
                          ),
                          child: Slider(
                            value: _sliderValue,
                            min: 0.0,
                            max:
                                _controller.value.duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _controller
                                    .seekTo(Duration(seconds: value.toInt()));
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                              ),
                              onPressed: _toggleFullScreen,
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()))),
    );
  }
}
