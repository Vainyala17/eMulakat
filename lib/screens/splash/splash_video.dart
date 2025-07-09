import 'package:flutter/material.dart';
import 'splash_animation.dart';

class SplashVideoScreen extends StatefulWidget {
  @override
  _SplashVideoScreenState createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  bool _isVideoPlaying = true;

  void _skipVideo() {
    setState(() {
      _isVideoPlaying = false;
    });
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
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Introduction Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Playing introduction video...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _skipVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Play Video'),
                  ),
                ],
              ),
            ),
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