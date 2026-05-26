import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  background,
  menu,
  wing,
  point,
  hit,
  die,
  win,
  lose,
  button
}

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    WidgetsBinding.instance.addObserver(this);
    _initPool();
    _loadSoundSetting();
  }

  // Player chính
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _menuPlayer = AudioPlayer();

  // Pool cho hiệu ứng ngắn (tái sử dụng → không leak)
  final List<AudioPlayer> _effectPool = [];
  final int _maxPoolSize = 8;

  bool _isBackgroundPlaying = false;
  bool _isMenuPlaying = false;
  bool _soundEnabled = true;

  double _musicVolume = 0.5;
  double _effectVolume = 0.5;

  final Map<SoundType, String> _sounds = {
    SoundType.background: "assets/audio/bgm_gameplay.mp3",
    SoundType.menu:       "assets/audio/bgm_menu.mp3",
    SoundType.wing:       "assets/audio/wing.wav",
    SoundType.point:      "assets/audio/point.wav",
    SoundType.hit:        "assets/audio/hit.wav",
    SoundType.die:        "assets/audio/die.wav",
    SoundType.win:        "assets/audio/win.mp3",
    SoundType.lose:       "assets/audio/lose.mp3",
    SoundType.button:       "assets/audio/button.mp3",
  };

  void _initPool() {
    for (int i = 0; i < _maxPoolSize; i++) {
      _effectPool.add(AudioPlayer());
    }
  }

  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _effectVolume = prefs.getDouble('effectVolume') ?? 0.5;

    await _bgPlayer.setVolume(_musicVolume);
    await _menuPlayer.setVolume(_musicVolume);
  }

  // === CÀI ĐẶT ===
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _bgPlayer.setVolume(_musicVolume);
    await _menuPlayer.setVolume(_musicVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('effectVolume', _effectVolume);
  }

  Future<void> enableSound() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = true;
    await prefs.setBool('soundEnabled', true);
    if (_isBackgroundPlaying) await _bgPlayer.play();
    if (_isMenuPlaying) await _menuPlayer.play();
  }

  Future<void> disableSound() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = false;
    await prefs.setBool('soundEnabled', false);
    await _bgPlayer.pause();
    await _menuPlayer.pause();
  }

  // === NHẠC NỀN ===
  Future<void> playBackground() async {
    if (!_soundEnabled || _isBackgroundPlaying) return;
    try {
      await stopMenu();
      await _bgPlayer.setAsset(_sounds[SoundType.background]!);
      await _bgPlayer.setLoopMode(LoopMode.one);
      await _bgPlayer.setVolume(_musicVolume);
      await _bgPlayer.play();
      _isBackgroundPlaying = true;
    } catch (e) {
      debugPrint("Lỗi BGM gameplay: $e");
    }
  }

  Future<void> stopBackground() async {
    await _fadeOut(_bgPlayer);
    await _bgPlayer.stop();
    _isBackgroundPlaying = false;
  }

  Future<void> playMenu() async {
    if (!_soundEnabled || _isMenuPlaying) return;
    try {
      await stopBackground();
      await _menuPlayer.setAsset(_sounds[SoundType.menu]!);
      await _menuPlayer.setLoopMode(LoopMode.one);
      await _menuPlayer.setVolume(_musicVolume);
      await _menuPlayer.play();
      _isMenuPlaying = true;
    } catch (e) {
      debugPrint("Lỗi BGM menu: $e");
    }
  }

  Future<void> stopMenu() async {
    await _fadeOut(_menuPlayer);
    await _menuPlayer.stop();
    _isMenuPlaying = false;
  }

  // === HIỆU ỨNG ÂM THANH (wing, point, hit, die...) ===
  Future<void> playEffect(SoundType type) async {
    if (!_soundEnabled || type == SoundType.background || type == SoundType.menu) return;

    AudioPlayer player;

    // Lấy player từ pool
    if (_effectPool.isNotEmpty) {
      player = _effectPool.removeLast();
      await player.stop(); // reset trạng thái
    } else {
      player = AudioPlayer();
    }

    try {
      await player.setAsset(_sounds[type]!);
      await player.setVolume(_effectVolume);
      await player.play();

      // Đúng API mới: dùng player.playerStateStream
      player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      ).then((_) async {
        await player.stop();
        if (!_effectPool.contains(player) && _effectPool.length < _maxPoolSize + 5) {
          _effectPool.add(player);
        } else {
          await player.dispose();
        }
      }).catchError((_) async {
        await player.stop();
        if (!_effectPool.contains(player)) {
          _effectPool.add(player);
        }
      });
    } catch (e) {
      debugPrint("Lỗi phát effect $type: $e");
      // Nếu lỗi vẫn trả lại pool để dùng lại
      if (!_effectPool.contains(player)) {
        _effectPool.add(player);
      }
    }
  }

  // Hàm tiện ích
  void playWing()   => playEffect(SoundType.wing);
  void playPoint()  => playEffect(SoundType.point);
  void playHit()    => playEffect(SoundType.hit);
  void playDie()    => playEffect(SoundType.die);
  void playWin()    => playEffect(SoundType.win);
  void playLose()   => playEffect(SoundType.lose);
  void playButton()   => playEffect(SoundType.button);

  // Fade out mượt
  Future<void> _fadeOut(AudioPlayer player, {Duration duration = const Duration(milliseconds: 600)}) async {
    final steps = 12;
    final stepDuration = duration ~/ steps;
    final stepSize = _musicVolume / steps;

    for (int i = 0; i < steps; i++) {
      await player.setVolume(_musicVolume - (stepSize * (i + 1)));
      await Future.delayed(stepDuration);
    }
    await player.setVolume(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _bgPlayer.pause();
      _menuPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_soundEnabled && _isBackgroundPlaying) _bgPlayer.play();
      if (_soundEnabled && _isMenuPlaying) _menuPlayer.play();
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _bgPlayer.dispose();
    await _menuPlayer.dispose();
    for (final p in _effectPool) {
      await p.dispose();
    }
    _effectPool.clear();
  }

  // Getter
  bool get isSoundEnabled => _soundEnabled;
  double get musicVolume => _musicVolume;
  double get effectVolume => _effectVolume;
}