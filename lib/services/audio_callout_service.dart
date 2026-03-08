/// Stub for audio callouts — full TTS implementation comes in RIDER-10.
class AudioCalloutService {
  Future<void> announceJoin(String displayName) async {
    // TODO(RIDER-10): speak "$displayName has joined the ride" via TTS
  }

  Future<void> announceLeave(String displayName) async {
    // TODO(RIDER-10): speak "$displayName has left the ride" via TTS
  }

  Future<void> announceRideEnded() async {
    // TODO(RIDER-10): speak "The ride has ended" via TTS
  }

  Future<void> announceNewDestination(String? placeName) async {
    // TODO(RIDER-10): speak "New destination set: ${placeName ?? 'a new location'}" via TTS
  }
}
