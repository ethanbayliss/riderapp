/// Stub for audio callouts — full TTS implementation comes in RIDER-10.
class AudioCalloutService {
  Future<void> announceJoin(String displayName) async {
    // TODO(RIDER-10): speak "$displayName has joined the ride" via TTS
  }
}
