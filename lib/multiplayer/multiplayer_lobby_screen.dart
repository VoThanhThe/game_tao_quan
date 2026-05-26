import 'dart:async';

import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../widgets/avatar_oval.dart';
import '../widgets/flappy_button.dart';
import 'models/game_room.dart';
import 'services/flappy_multiplayer_service.dart';
import 'views/waiting_room_screen.dart';

// Use GameRoom model from flappy_multiplayer_service.dart
// The GameRoom class is defined in flappy_multiplayer_service.dart and is imported at the top of this file.
// This avoids duplicate type definitions that cause assignment/type conflicts.

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final FlappyMultiplayerService multiplayerService =
      FlappyMultiplayerService();
  final TextEditingController _nameController = TextEditingController(
    text: 'Player',
  );
  final TextEditingController _roomCodeController = TextEditingController();

  bool _isLoading = false;
  String? errorMessage;
  List<GameRoom> _availableRooms = [];
  final ScrollController roomListScrollController = ScrollController();
  bool showScrollIndicator = false;
  bool isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableRooms();
    // Lắng nghe scroll để update indicator
    roomListScrollController.addListener(onScroll);
    // Auto refresh mỗi 5 giây
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadAvailableRooms();
      } else {
        timer.cancel();
      }
    });
  }

  void onScroll() {
    if (!roomListScrollController.hasClients) return;

    final maxScroll = roomListScrollController.position.maxScrollExtent;
    final currentScroll = roomListScrollController.offset;

    setState(() {
      // Hiện indicator khi có thể scroll (maxScroll > 10)
      showScrollIndicator = maxScroll > 10;
      // Check nếu đang ở cuối (cách đáy < 10px)
      isAtBottom = (maxScroll - currentScroll) < 10;
    });
  }

  void scrollToEnd() {
    AudioService().playButton();
    if (isAtBottom) {
      // Scroll lên đầu
      roomListScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Scroll xuống cuối
      roomListScrollController.animateTo(
        roomListScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadAvailableRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await multiplayerService.getAvailableRooms();
      // debugPrint('Loaded ${rooms.length} available rooms.');
      // debugPrint('Loaded Room $rooms');
      setState(() {
        _availableRooms = rooms;
      });
    } catch (e) {
      debugPrint('Lỗi load rooms: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🆕 Tạo phòng mới
  Future<void> _createRoom() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Vui lòng nhập tên!');
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final roomId = await multiplayerService.createRoom(
        _nameController.text.trim(),
      );

      if (mounted) {
        // Chuyển đến màn hình chờ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WaitingRoomScreen(
              multiplayerService: multiplayerService,
              roomId: roomId,
              isHost: true,
            ),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🚪 Tham gia phòng
  Future<void> _joinRoom(String? roomCode) async {
    final code = roomCode ?? _roomCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError('Vui lòng nhập mã phòng!');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError('Vui lòng nhập tên!');
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      await multiplayerService.joinRoom(code, _nameController.text.trim());

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WaitingRoomScreen(
              multiplayerService: multiplayerService,
              roomId: code,
              isHost: false,
            ),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    roomListScrollController.dispose(); // ← THÊM DÒNG NÀY
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chơi Multiplayer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'FzCoTrang',
          ),
        ),
        backgroundColor: Color(0xFFDD0303),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            AudioService().playButton();
            Navigator.of(context).pop();
            AudioService().playMenu();
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDD0303), Color(0xFFFA812F), Color(0xFFED3F27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🎮 Card nhập tên
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AvatarOval(
                        imageUrl:
                            "https://i.pinimg.com/736x/b7/7f/65/b77f65dee5957b1175ad32cffaf61df7.jpg",
                        size: 50,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FzCoTrang',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên của bạn',
                          hintStyle: const TextStyle(fontFamily: 'FzCoTrang'),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                FlappyButton(
                  onPressed: () {
                    AudioService().playButton();
                    if (!_isLoading) _createRoom();
                  },
                  backgroundColor: const Color(0xFF4CAF50),
                  textColor: Colors.white,
                  borderColor: const Color(0xFF388E3C),
                  text: 'Tạo Phòng Mới',
                  iconLeft: Icons.add_circle,
                ),
                const SizedBox(height: 30),
                // Divider với text
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha((0.5 * 255).toInt()),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'HOẶC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FzCoTrang',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withAlpha((0.5 * 255).toInt()),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🚪 Card tham gia bằng mã
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.vpn_key,
                        size: 50,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tham gia bằng mã phòng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FzCoTrang',
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _roomCodeController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontFamily: 'FzCoTrang',
                        ),
                        decoration: InputDecoration(
                          hintText: 'ABCD12',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'FzCoTrang',
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FlappyButton(
                              onPressed: () {
                                if (!_isLoading) _joinRoom(null);
                              },
                              backgroundColor: const Color(0xFF2196F3),
                              textColor: Colors.white,
                              borderColor: const Color(0xFF1976D2),
                              text: 'Tham Gia',
                              iconLeft: Icons.login,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 📋 Danh sách phòng có sẵn
                _buildRoomListSection(),

                // if (_isLoading)
                //   Container(
                //     margin: const EdgeInsets.only(top: 20),
                //     padding: const EdgeInsets.all(20),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: const Column(
                //       children: [
                //         CircularProgressIndicator(
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             Color(0xFFFAB12F),
                //           ),
                //         ),
                //         SizedBox(height: 15),
                //         Text(
                //           'Đang xử lý...',
                //           style: TextStyle(
                //             fontFamily: 'FzCoTrang',
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget cho phần danh sách phòng
  Widget _buildRoomListSection() {
    return Container(
      padding: const EdgeInsets.all(20).copyWith(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.group, color: Color(0xFFFAB12F), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Phòng đang chờ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FzCoTrang',
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAB12F).withAlpha((0.1 * 255).toInt()),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFFAB12F)),
                  onPressed: () {
                    AudioService().playButton();
                    _loadAvailableRooms();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Hiển thị theo điều kiện
          if (_availableRooms.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    'Chưa có phòng nào',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontFamily: 'FzCoTrang',
                    ),
                  ),
                ],
              ),
            )
          else
            Stack(
              children: [
                // List với scroll
                Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: WidgetStateProperty.all(
                        true,
                      ), // luôn hiển thị
                      trackVisibility: WidgetStateProperty.all(true),
                      thickness: WidgetStateProperty.all(8),
                      radius: const Radius.circular(20),
                      thumbColor: WidgetStateProperty.all(
                        Colors.orange,
                      ), // 🎨 màu thanh cuộn
                    ),
                  ),
                  child: Scrollbar(
                    controller: roomListScrollController,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(right: 12),
                        controller: roomListScrollController,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _availableRooms.length,
                        itemBuilder: (context, index) {
                          final room = _availableRooms[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFFFFE29F,
                                  ).withAlpha((0.4 * 255).toInt()),
                                  const Color(
                                    0xFFFFA99F,
                                  ).withAlpha((0.4 * 255).toInt()),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(
                                  0xFFFAB12F,
                                ).withAlpha((0.4 * 255).toInt()),
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFAD961),
                                      Color(0xFFF76B1C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    room.roomId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'FzCoTrang',
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(
                                        (0.2 * 255).toInt(),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${room.playerCount}/5',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontFamily: 'FzCoTrang',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Chủ phòng: ${room.hostName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'FzCoTrang',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: FlappyButton(
                                onPressed: () => _joinRoom(room.roomId),
                                backgroundColor: const Color(0xFF4CAF50),
                                textColor: Colors.white,
                                borderColor: const Color(0xFF388E3C),
                                text: 'Vào',
                                textSize: 16,
                                paddingHZ: 12,
                                paddingVT: 6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Scroll indicator với animation
                if (showScrollIndicator)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: scrollToEnd,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 8.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, value),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFAB12F),
                                      Color(0xFFF76B1C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFAB12F,
                                      ).withAlpha((0.5 * 255).toInt()),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isAtBottom
                                      ? Icons.keyboard_double_arrow_up
                                      : Icons.keyboard_double_arrow_down,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Loop animation
                            if (mounted && showScrollIndicator) {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
