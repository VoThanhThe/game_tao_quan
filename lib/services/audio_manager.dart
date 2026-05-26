// 1. Tạo 1 file duy nhất quản lý âm thanh – tên là audio_manager.dart
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;
  bool _isInitialized = false;

  // Khởi tạo 1 lần duy nhất khi app chạy
  Future<void> init() async {
    if (_isInitialized) return;

    // Preload tất cả âm thanh để latency = 0
    await FlameAudio.audioCache.loadAll([
      'wing.wav',
      'point.wav',
      'hit.wav',
      'die.wav',
      'win.mp3',
      'sfx_lose.mp3',
    ]);

    // Nhạc nền (nếu có)
    await FlameAudio.bgm.initialize();
    // await FlameAudio.bgm.load('bgm_gameplay.mp3'); // nếu bạn dùng BGM

    _isInitialized = true;
  }

  // === TẮT/MỞ ÂM THANH ===
  void enableSound() {
    _soundEnabled = true;
  }

  void disableSound() {
    _soundEnabled = false;
    FlameAudio.bgm.pause();
  }

  // === HIỆU ỨNG NGẮN (dùng nhiều nhất) ===
  void playWing() => _playIfEnabled('wing.wav');
  void playPoint() => _playIfEnabled('point.wav');
  void playHit() => _playIfEnabled('hit.wav');
  void playDie() => _playIfEnabled('die.wav');
  void playWin() => _playIfEnabled('sfx_win.mp3');
  void playLose() => _playIfEnabled('sfx_lose.mp3');

  void _playIfEnabled(String file) {
    if (_soundEnabled) {
      FlameAudio.play(file, volume: 0.8);
    }
  }

  // === NHẠC NỀN (nếu bạn muốn dùng) ===
  Future<void> playBackgroundMusic() async {
    if (!_soundEnabled) return;
    await FlameAudio.bgm.play('bgm_gameplay.mp3', volume: 0.5);
  }

  Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await FlameAudio.bgm.pause();
  }

  // === QUAN TRỌNG NHẤT: DỌN DẸP KHI CHƠI LẠI HOẶC THOÁT ===
  Future<void> clearCache() async {
    await FlameAudio.audioCache.clearAll();
    await FlameAudio.bgm.stop();
    // Không cần dispose pool vì FlameAudio tự quản lý
  }

  // Gọi khi reset game (rất quan trọng!)
  Future<void> reset() async {
    await clearCache();
    // Reload lại để lần sau vẫn phát được
    await FlameAudio.audioCache.loadAll([
      'wing.wav',
      'point.wav',
      'hit.wav',
      'die.wav',
      'sfx_win.mp3',
      'sfx_lose.mp3',
    ]);
  }
}
