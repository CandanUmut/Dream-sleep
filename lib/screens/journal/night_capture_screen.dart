import 'package:flutter/material.dart';

import '../../services/audio/audio_recorder_service.dart';

class NightCaptureScreen extends StatefulWidget {
  const NightCaptureScreen({super.key});

  @override
  State<NightCaptureScreen> createState() => _NightCaptureScreenState();
}

class _NightCaptureScreenState extends State<NightCaptureScreen> {
  late AudioRecorderService _recorderService;
  bool _isRecording = false;
  String? _path;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioRecorderService();
    _recorderService.init();
  }

  @override
  void dispose() {
    _recorderService.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleRecording,
        child: Container(
          color: Colors.black,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: _isRecording ? colorScheme.secondary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? colorScheme.secondary : Colors.white38,
                  width: 4,
                ),
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 72,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _path == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Audio saved at $_path\nYou can add details in the morning.\nYour dreams stay private.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
