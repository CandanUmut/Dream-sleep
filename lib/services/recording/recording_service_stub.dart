import 'recording_service_base.dart';

RecordingService createRecordingServiceImpl() => _UnsupportedRecordingService();

class _UnsupportedRecordingService implements RecordingService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  bool get isSupported => false;

  @override
  String? get latestRecordingPath => null;

  @override
  Future<void> startRecording() async {}

  @override
  Future<String?> stopRecordingAndTranscribe() async => null;
}
