import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'splash_animation.dart';

class SplashVideoScreen extends StatefulWidget {
  @override
  _SplashVideoScreenState createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          'https://www.youtube.com/watch?v=sO1OFGdVly4') ??
          '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  void _skipVideo() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashAnimationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Center the video with padding
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AspectRatio(
                aspectRatio: 16 / 12,
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
              ),
            ),
          ),

          /// Positioned Skip button at bottom-right
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: _skipVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7AA9D4),
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
