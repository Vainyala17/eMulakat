import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'splash_animation.dart';

class SplashVideoScreen extends StatefulWidget {
  @override
  _SplashVideoScreenState createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the video
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // autoplay
      })
      ..setLooping(false);

    // Listen for when the video ends
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _skipVideo();
      }
    });
  }

  void _skipVideo() {
    _controller.pause();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashAnimationScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : CircularProgressIndicator(color: Colors.white),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: _skipVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
