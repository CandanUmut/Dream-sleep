import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  AudioRecorderService()
      : _recorder = FlutterSoundRecorder(logLevel: Level.error);

  final FlutterSoundRecorder _recorder;
  String? _currentPath;

  Future<void> init() async {
    await _recorder.openRecorder();
  }

  Future<bool> ensurePermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    final granted = await ensurePermissions();
    if (!granted) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filename = 'dream_${DateTime.now().millisecondsSinceEpoch}.aac';
    final path = '${directory.path}/$filename';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    _currentPath = path;
    return path;
  }

  Future<String?> stopRecording() async {
    if (!_recorder.isRecording) {
      return _currentPath;
    }
    final path = await _recorder.stopRecorder();
    _currentPath = path;
    return path;
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }

  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
