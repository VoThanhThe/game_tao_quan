import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/audio_service.dart';
import '../../widgets/flappy_button.dart';
import '../../widgets/show_remove_player_confirm_dialog.dart';
import '../../widgets/show_removed_from_room_dialog.dart';
import '../models/player.dart';
import '../services/flappy_multiplayer_service.dart';
import 'start_game_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final FlappyMultiplayerService multiplayerService;
  final String roomId;
  final bool isHost;

  const WaitingRoomScreen({
    super.key,
    required this.multiplayerService,
    required this.roomId,
    required this.isHost,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with WidgetsBindingObserver {
  Map<String, Player> _players = {};
  String? hostId;
  Timer? leaveRoomTimer;

  final List<String> playerImages = [
    'ong_tao.png',
    'ninja_girl.png',
    'jack.png',
    'santa.png',
    'red_hat.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Sửa lại tất cả callback: luôn kiểm tra mounted trước khi setState
    widget.multiplayerService.onPlayersUpdated = (players) {
      if (!mounted) return; // Quan trọng nhất
      setState(() {
        _players = players;
      });
    };

    widget.multiplayerService.onGameStatusChanged = (status) {
      if (!mounted) return;
      if (status == 'playing') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StartGameScreen(multiplayerService: widget.multiplayerService),
          ),
        );
      }
    };

    widget.multiplayerService.onHostChanged = (newHostId) {
      if (!mounted) return; // Thêm dòng này
      setState(() {
        hostId = newHostId;
      });
    };

    widget.multiplayerService.onKickedFromRoom = () async {
      if (!mounted) return;
      if (widget.multiplayerService.isLeaving) return;

      leaveRoomTimer?.cancel();

      Navigator.of(context).pop();
      await showRemovedFromRoomDialog(context);
    };
  }

  void _copyRoomCode() {
    AudioService().playButton();
    Clipboard.setData(ClipboardData(text: widget.roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã copy mã phòng!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  @override
  void dispose() {
    // HỦY TẤT CẢ CALLBACK ĐỂ TRÁNH LỌI GỌI setState SAU KHI DISPOSE
    widget.multiplayerService.onPlayersUpdated = null;
    widget.multiplayerService.onGameStatusChanged = null;
    widget.multiplayerService.onHostChanged = null;
    widget.multiplayerService.onKickedFromRoom = null;

    WidgetsBinding.instance.removeObserver(this);
    leaveRoomTimer?.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      debugPrint("App bị xoá");
      await widget.multiplayerService.leaveRoom();
      return;
    }

    if (state == AppLifecycleState.paused) {
      // App chuyển nền: khởi động timer 3 phút
      leaveRoomTimer?.cancel();
      leaveRoomTimer = Timer(const Duration(seconds: 5000), () async {
        // Chỉ leave khi chưa bị kick
        if (mounted) {
          await widget.multiplayerService.leaveRoom();
          if (mounted) {
            // Pop màn hình mà không show dialog kick
            Navigator.of(context).pop();
          }
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      // App trở lại: hủy timer nếu còn chạy
      leaveRoomTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = _players.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Phòng chờ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'FzCoTrang',
            ),
          ),
          backgroundColor: const Color(0xFFFAB12F),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
            onPressed: () async {
              AudioService().playButton();
              // Gọi API rời phòng trước khi pop
              await widget.multiplayerService.leaveRoom();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Mã phòng với gradient đẹp
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ).copyWith(top: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha((0.4 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Mã phòng:',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'FzCoTrang',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.roomId,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            fontFamily: 'FzCoTrang',
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _copyRoomCode,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                (0.9 * 255).toInt(),
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: Color(0xFFFF7A00),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Danh sách người chơi
              const Text(
                'Người chơi:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FzCoTrang',
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final entry = sortedPlayers[index];
                    final player = entry.value;
                    final playerId = entry.key;

                    final isCurrentPlayer =
                        playerId == widget.multiplayerService.currentPlayerId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCurrentPlayer
                              ? [
                                  const Color(
                                    0xFFFAD961,
                                  ).withAlpha((0.3 * 255).toInt()),
                                  const Color(
                                    0xFFF76B1C,
                                  ).withAlpha((0.3 * 255).toInt()),
                                ]
                              : [Colors.white, Colors.grey[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isCurrentPlayer
                              ? const Color(0xFFFAB12F)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          // backgroundColor:
                          //     Colors.primaries[index % Colors.primaries.length],
                          // child: Text(
                          //   player.name[0].toUpperCase(),
                          //   style: const TextStyle(
                          //     color: Colors.white,
                          //     fontWeight: FontWeight.bold,
                          //     fontFamily: 'FzCoTrang',
                          //   ),
                          // ),
                          backgroundColor: Colors.grey[100],
                          backgroundImage: AssetImage(
                            'assets/images/${playerImages[index % playerImages.length]}', // index giờ đúng!
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FzCoTrang',
                          ),
                        ),
                        trailing: isCurrentPlayer
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFAD961),
                                      Color(0xFFF76B1C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Bạn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'FzCoTrang',
                                  ),
                                ),
                              )
                            : widget.multiplayerService.currentPlayerId ==
                                  hostId // chỉ host mới thấy nút
                            ? IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  AudioService().playButton();
                                  final confirm =
                                      await showRemovePlayerConfirmDialog(
                                        context,
                                      );

                                  if (confirm == true) {
                                    // Gọi API kick player
                                    await widget.multiplayerService.kickPlayer(
                                      player.id,
                                    );
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Nút bắt đầu (chỉ host)
              if (widget.multiplayerService.currentPlayerId == hostId)
                Opacity(
                  opacity: _players.length >= 2 ? 1.0 : 0.5,
                  child: Row(
                    children: [
                      Expanded(
                        child: FlappyButton(
                          onPressed: () {
                            if (_players.length >= 2) {
                              widget.multiplayerService.startGame();
                            }
                          },
                          backgroundColor: const Color(0xFF4CAF50),
                          textColor: Colors.white,
                          borderColor: const Color(0xFF388E3C),
                          text: 'Bắt Đầu Game',
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFAB12F),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, color: Color(0xFFFAB12F)),
                      SizedBox(width: 10),
                      Text(
                        'Đang chờ host bắt đầu...',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'FzCoTrang',
                          color: Color(0xFFFAB12F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
