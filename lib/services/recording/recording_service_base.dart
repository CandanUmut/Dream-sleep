abstract class RecordingService {
  bool get isSupported;
  String? get latestRecordingPath;

  Future<void> initialize();
  Future<void> startRecording();
  Future<String?> stopRecordingAndTranscribe();
  Future<void> dispose();
}
