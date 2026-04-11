import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identifiers for every sound the app can play.
enum SoundEffect {
  /// Short click used for every pet action button press.
  action,

  /// Positive jingle when the pet reacts happily.
  happy,

  /// Level-up fanfare.
  levelUp,

  /// Evolution celebration melody.
  evolution,

  /// Achievement unlocked ding.
  achievement,

  /// Warning sound when stats are critical / pet about to faint.
  critical,

  /// Pet fainted — deep thud.
  fainted,

  /// Coin earned sound.
  coin,
}

/// Maps each [SoundEffect] to its asset path under assets/sounds/.
const Map<SoundEffect, String> _soundAssets = {
  SoundEffect.action:      'sounds/action.mp3',
  SoundEffect.happy:       'sounds/happy.mp3',
  SoundEffect.levelUp:     'sounds/level_up.mp3',
  SoundEffect.evolution:   'sounds/evolution.mp3',
  SoundEffect.achievement: 'sounds/achievement.mp3',
  SoundEffect.critical:    'sounds/critical.mp3',
  SoundEffect.fainted:     'sounds/fainted.mp3',
  SoundEffect.coin:        'sounds/coin.mp3',
};

class SoundService {
  SoundService._();

  static bool _enabled = true;
  static bool get enabled => _enabled;

  // Pool of players for short SFX so rapid calls don't cut each other off.
  static final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  static int _poolIndex = 0;

  // Dedicated player for BGM (looped background music).
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static bool _bgmPlaying = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Call once at app start. Restores the persisted [enabled] preference.
  static Future<void> init() async {
    // Suppress all audioplayers console output (e.g. missing-file errors on web).
    AudioLogger.logLevel = AudioLogLevel.none;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('sound_enabled') ?? true;
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  static Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    if (!value) {
      await _bgmPlayer.stop();
      _bgmPlaying = false;
    }
  }

  // ── SFX ──────────────────────────────────────────────────────────────────

  /// Plays a one-shot sound effect. Silently ignored when sound is disabled or
  /// when the asset file does not exist yet (so missing files don't crash).
  static Future<void> play(SoundEffect effect) async {
    if (!_enabled) return;
    final path = _soundAssets[effect];
    if (path == null) return;
    // runZonedGuarded catches web async exceptions that escape try/catch
    // (e.g. AudioPlayerException fired from a JS DOM event callback).
    runZonedGuarded(() {
      final player = _pool[_poolIndex % _pool.length];
      _poolIndex++;
      player.play(AssetSource(path)).catchError((_) {});
    }, (_, err) {});
  }

  // ── BGM ───────────────────────────────────────────────────────────────────

  /// Starts looping background music. Safe to call multiple times.
  static Future<void> playBgm(String asset) async {
    if (!_enabled || _bgmPlaying) return;
    runZonedGuarded(() async {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer.play(AssetSource(asset)).catchError((_) {});
      _bgmPlayer.setVolume(0.35);
      _bgmPlaying = true;
    }, (_, err) {});
  }

  static Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _bgmPlaying = false;
  }

  static Future<void> pauseBgm() async => _bgmPlayer.pause();
  static Future<void> resumeBgm() async {
    if (_enabled) await _bgmPlayer.resume();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  static Future<void> dispose() async {
    for (final p in _pool) {
      await p.dispose();
    }
    await _bgmPlayer.dispose();
  }
}
