import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/exercise.dart';
import '../widgets/glass_container.dart';
import '../services/theme_service.dart';
import 'camera_tracker_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.exercise.videoUrl;
    
    if (url.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(url);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    
    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                const SizedBox(height: 20),
                Hero(
                  tag: 'exercise_${widget.exercise.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _controller.value.isInitialized
                            ? ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 250),
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    VideoPlayer(_controller),
                                    VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: Colors.greenAccent, backgroundColor: Colors.white24)),
                                    Center(
                                      child: AnimatedOpacity(
                                        opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]),
                                            child: const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Invisible tap area to pause
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                            : const SizedBox(
                                height: 250,
                                child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.greenAccent),
                          SizedBox(width: 10),
                          Text('Instrucciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.exercise.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _controller.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraTrackerScreen(exercise: widget.exercise)),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 28),
                        SizedBox(width: 12),
                        Text('Activar IA (Comenzar)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
