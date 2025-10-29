import 'recording_service_base.dart';
import 'recording_service_stub.dart'
    if (dart.library.html) 'recording_service_web.dart'
    if (dart.library.io) 'recording_service_mobile.dart';

export 'recording_service_base.dart';

RecordingService createRecordingService() => createRecordingServiceImpl();
