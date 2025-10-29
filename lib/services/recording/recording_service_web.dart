import 'dart:async';
import 'dart:html' as html;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

import 'recording_service_base.dart';

RecordingService createRecordingServiceImpl() => WebRecordingService();

class WebRecordingService implements RecordingService {
  WebRecordingService() {
    _isSupported = js_util.hasProperty(html.window, 'SpeechRecognition') ||
        js_util.hasProperty(html.window, 'webkitSpeechRecognition');
    if (_isSupported) {
      final constructor = js_util.hasProperty(html.window, 'SpeechRecognition')
          ? js_util.getProperty(html.window, 'SpeechRecognition')
          : js_util.getProperty(html.window, 'webkitSpeechRecognition');
      _recognition = js_util.callConstructor(constructor, []);
    }
  }

  late final bool _isSupported;
  dynamic _recognition;
  Completer<String?>? _resultCompleter;
  String? _latestTranscript;

  @override
  bool get isSupported => _isSupported;

  @override
  String? get latestRecordingPath => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startRecording() async {
    if (!_isSupported || _recognition == null) {
      return;
    }
    _resultCompleter = Completer<String?>();
    _latestTranscript = null;
    js_util.setProperty(_recognition, 'continuous', false);
    js_util.setProperty(_recognition, 'interimResults', true);
    js_util.setProperty(_recognition, 'lang', html.window.navigator.language ?? 'en-US');
    js_util.setProperty(_recognition, 'maxAlternatives', 1);

    js_util.setProperty(
      _recognition,
      'onresult',
      allowInterop((event) {
        try {
          final results = js_util.getProperty(event, 'results');
          final length = (js_util.getProperty(results, 'length') as num?)?.toInt() ?? 0;
          if (length == 0) {
            return;
          }
          final result = js_util.callMethod(results, 'item', [length - 1]);
          final isFinal = js_util.getProperty(result, 'isFinal') == true;
          final alternative = js_util.callMethod(result, 'item', [0]);
          final transcript = js_util.getProperty(alternative, 'transcript') as String?;
          if (transcript != null) {
            _latestTranscript = transcript;
            if (isFinal && !(_resultCompleter?.isCompleted ?? true)) {
              _resultCompleter?.complete(transcript.trim());
            }
          }
        } catch (_) {
          if (!(_resultCompleter?.isCompleted ?? true)) {
            _resultCompleter?.complete(null);
          }
        }
      }),
    );

    js_util.setProperty(
      _recognition,
      'onerror',
      allowInterop((dynamic event) {
        if (!(_resultCompleter?.isCompleted ?? true)) {
          _resultCompleter?.completeError(event);
        }
      }),
    );

    js_util.callMethod(_recognition, 'start', []);
  }

  @override
  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isSupported || _recognition == null) {
      return null;
    }
    try {
      js_util.callMethod(_recognition, 'stop', []);
    } catch (_) {}
    if (_resultCompleter == null) {
      return _latestTranscript?.trim();
    }
    try {
      return await _resultCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => _latestTranscript?.trim(),
      );
    } catch (_) {
      return _latestTranscript?.trim();
    } finally {
      _resultCompleter = null;
    }
  }

  @override
  Future<void> dispose() async {
    if (_recognition != null) {
      try {
        js_util.callMethod(_recognition, 'abort', []);
      } catch (_) {}
    }
  }
}
