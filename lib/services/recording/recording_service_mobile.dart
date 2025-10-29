import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../audio/audio_recorder_service.dart';
import 'recording_service_base.dart';

RecordingService createRecordingServiceImpl() => MobileRecordingService();

class MobileRecordingService implements RecordingService {
  MobileRecordingService()
      : _recorder = AudioRecorderService(),
        _speech = stt.SpeechToText();

  final AudioRecorderService _recorder;
  final stt.SpeechToText _speech;

  bool _initialized = false;
  bool _speechAvailable = false;
  String? _latestPath;
  String _transcriptBuffer = '';

  @override
  bool get isSupported => _speechAvailable;

  @override
  String? get latestRecordingPath => _latestPath;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _recorder.init();
    _speechAvailable = await _speech.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
    _initialized = true;
  }

  @override
  Future<void> startRecording() async {
    await initialize();
    _transcriptBuffer = '';
    final path = await _recorder.startRecording();
    _latestPath = path;
    if (path == null) {
      _speechAvailable = false;
      return;
    }
    if (!_speechAvailable) {
      return;
    }
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _transcriptBuffer = result.recognizedWords;
        }
      },
      pauseFor: const Duration(seconds: 4),
      listenFor: const Duration(minutes: 2),
      partialResults: true,
    );
  }

  @override
  Future<String?> stopRecordingAndTranscribe() async {
    _latestPath = await _recorder.stopRecording();
    if (_speech.isListening) {
      await _speech.stop();
    }
    final transcript = _transcriptBuffer.trim();
    return transcript.isEmpty ? null : transcript;
  }

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
    await _speech.cancel();
  }
}
