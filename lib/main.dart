import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(AnimatedHeartbeatApp());
}

class AnimatedHeartbeatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Heartbeat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink,
          titleTextStyle: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      home: HeartbeatHomeScreen(),
    );
  }
}

class HeartbeatHomeScreen extends StatefulWidget {
  @override
  _HeartbeatHomeScreenState createState() => _HeartbeatHomeScreenState();
}

class _HeartbeatHomeScreenState extends State<HeartbeatHomeScreen>
    with TickerProviderStateMixin {
  bool _hasStarted = false;
  late AnimationController _heartbeatController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _remainingTime = 10;
  Timer? _timer;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _startTimer();
  }

  void _startAnimations() {
    _heartbeatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );
    _heartbeatController.repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.repeat(reverse: true);
  }

  void _startTimer() {
    _remainingTime = 10;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _heartbeatController.stop();
        _fadeController.stop();
        _audioPlayer.stop();
      }
    });
  }

  Future<void> _playMusic() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    await _audioPlayer.play('assets/music.mp3', isLocal: true);
  }

  void _restart() {
    _heartbeatController.reset();
    _heartbeatController.repeat(reverse: true);
    _fadeController.reset();
    _fadeController.repeat(reverse: true);
    _startTimer();
    _audioPlayer.stop();
    _playMusic();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _fadeController.dispose();
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_hasStarted) {
          _playMusic();
          setState(() {
            _hasStarted = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Animated Heartbeat App'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('assets/pink_hearts.png'),
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(
                Colors.pink.withOpacity(0.2),
                BlendMode.srcOver,
              ),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Time remaining: $_remainingTime seconds",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(2, 2))
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          Icons.favorite,
                          size: 120,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Happy Valentine's Day!\nLove is in the air!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  blurRadius: 4,
                                  color: Colors.black45,
                                  offset: Offset(2, 2))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FloatingHeart(left: 0.2, duration: Duration(seconds: 3)),
              FloatingHeart(left: 0.5, duration: Duration(seconds: 4)),
              FloatingHeart(left: 0.8, duration: Duration(seconds: 3)),
              if (!_hasStarted)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      "Tap to start music",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        shadows: [
                          Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _restart,
          tooltip: 'Restart Animation',
          child: Icon(Icons.refresh),
          backgroundColor: Colors.pink,
        ),
      ),
    );
  }
}

class FloatingHeart extends StatefulWidget {
  final double left;
  final Duration duration;

  const FloatingHeart({Key? key, required this.left, required this.duration})
      : super(key: key);

  @override
  _FloatingHeartState createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _verticalAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _verticalAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _verticalAnimation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Positioned(
          left: MediaQuery.of(context).size.width * widget.left,
          top: screenHeight * _verticalAnimation.value,
          child: Opacity(
            opacity: 1 - _verticalAnimation.value,
            child: Icon(
              Icons.favorite,
              size: 30,
              color: Colors.pinkAccent,
            ),
          ),
        );
      },
    );
  }
}
//Updated by Ramya
