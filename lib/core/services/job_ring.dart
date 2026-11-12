import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';

/// Rings while a job popup waits for the partner's answer. Uses the phone's
/// ringtone volume, so it follows the partner's silent mode.
class JobRing {
  JobRing._();

  static AudioPlayer? _player;
  static int _openPopups = 0;

  static bool get isRinging => _starting || _openPopups > 0;

  /// Tests turn the audio off.
  static bool enabled = true;

  static Future<void> start() async {
    if (!enabled || _player != null) return;
    try {
      final player = AudioPlayer();
      _player = player;
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.notificationRingtone,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      developer.log('Job ring error: $e');
    }
    // Answered while the sound was starting.
    if (_openPopups == 0 && !_starting) await _stop();
  }

  /// True from the push's arrival until its popup opens or is ruled out.
  static bool _starting = false;

  /// A push arrived; its popup follows once the job details load.
  static Future<void> pushArrived() {
    _starting = true;
    return start();
  }

  /// The push produced no popup (job expired or cancelled).
  static Future<void> noPopup() async {
    _starting = false;
    if (_openPopups == 0) await _stop();
  }

  static void popupOpened() {
    _starting = false;
    _openPopups++;
    start();
  }

  /// The partner answered, or the popup closed.
  static void popupFinished() {
    if (_openPopups > 0) _openPopups--;
    if (_openPopups == 0 && !_starting) _stop();
  }

  static Future<void> _stop() async {
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.stop();
      await player.dispose();
    } catch (e) {
      developer.log('Job ring stop error: $e');
    }
  }
}
