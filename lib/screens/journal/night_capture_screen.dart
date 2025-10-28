import 'package:flutter/material.dart';

import '../../services/audio/audio_recorder_service.dart';
import '../../widgets/dream_background.dart';

class NightCaptureScreen extends StatefulWidget {
  const NightCaptureScreen({super.key});

  @override
  State<NightCaptureScreen> createState() => _NightCaptureScreenState();
}

class _NightCaptureScreenState extends State<NightCaptureScreen> with SingleTickerProviderStateMixin {
  late AudioRecorderService _recorderService;
  bool _isRecording = false;
  String? _path;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();
    _recorderService.init();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recorderService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorderService.stopRecording();
      setState(() {
        _isRecording = false;
        _path = path;
      });
    } else {
      final path = await _recorderService.startRecording();
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is needed.')),
        );
        return;
      }
      setState(() {
        _isRecording = true;
        _path = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DreamBackground(
          useSafeArea: false,
          child: const SizedBox.expand(),
        ),
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Night capture'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: Text(
                  'Tap anywhere to drop a whisper. Stay cosy, keep eyes closed, and speak softly so the memory stays fresh.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1 + (_pulseController.value * 0.12);
                        return Transform.scale(scale: _isRecording ? scale : 1, child: child);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _isRecording ? 190 : 160,
                        width: _isRecording ? 190 : 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: _isRecording
                                ? const [Color(0xFFFF9086), Color(0xFF7B5CD6)]
                                : const [Color(0x3385A2FF), Color(0x112C1B5B)],
                          ),
                          border: Border.all(
                            color: _isRecording ? Colors.white : Colors.white54,
                            width: 3,
                          ),
                          boxShadow: [
                            if (_isRecording)
                              const BoxShadow(
                                color: Color(0x66FF9086),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_path != null)
                      Text(
                        'Audio saved at $_path',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording
                          ? 'Tap again when the dream story feels complete.'
                          : 'You can add details in the morning. Your dream is safe here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
