import 'dart:collection';

import 'package:flutter_tts/flutter_tts.dart';

/// Singleton TTS service that queues callouts and plays them sequentially.
class AudioCalloutService {
  static final AudioCalloutService _instance = AudioCalloutService._();
  factory AudioCalloutService() => _instance;

  AudioCalloutService._() {
    _init();
  }

  final _tts = FlutterTts();
  final _queue = Queue<String>();
  bool _speaking = false;
  bool muted = false;

  Future<void> _init() async {
    await _tts.setLanguage('en-AU');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  void _enqueue(String text) {
    if (muted) return;
    _queue.add(text);
    if (!_speaking) _processQueue();
  }

  Future<void> _processQueue() async {
    _speaking = true;
    while (_queue.isNotEmpty) {
      final text = _queue.removeFirst();
      await _tts.speak(text);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _speaking = false;
  }

  Future<void> announceJoin(String displayName) async =>
      _enqueue('$displayName has joined the ride');

  Future<void> announceLeave(String displayName) async =>
      _enqueue('$displayName has left the ride');

  Future<void> announceRideEnded() async =>
      _enqueue('The ride has ended');

  Future<void> announceNewDestination(String? placeName) async =>
      _enqueue('New destination: ${placeName ?? 'a new location'}');

  Future<void> announceArrived(String displayName) async =>
      _enqueue('$displayName has arrived');

  Future<void> announceAllArrived() async =>
      _enqueue('All riders have arrived');
}
