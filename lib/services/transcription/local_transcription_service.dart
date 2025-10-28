import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class LocalTranscriptionService {
  LocalTranscriptionService() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;

  Future<bool> init() async {
    return _speech.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
  }

  Future<String> transcribeOnce() async {
    final hasSpeech = await _speech.initialize();
    if (!hasSpeech) {
      return '';
    }
    final completer = Completer<String>();
    final buffer = StringBuffer();
    _speech.listen(
      listenFor: const Duration(seconds: 60),
      partialResults: true,
      onResult: (result) {
        buffer.clear();
        buffer.write(result.recognizedWords);
        if (result.finalResult) {
          completer.complete(buffer.toString());
          _speech.stop();
        }
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 65),
      onTimeout: () {
        _speech.stop();
        return buffer.toString();
      },
    );
  }

  Future<void> dispose() async {
    _speech.cancel();
  }
}
