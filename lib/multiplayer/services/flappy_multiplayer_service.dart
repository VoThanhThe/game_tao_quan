import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import '../models/game_room.dart';
import '../models/player.dart';

// 🎮 Multiplayer Service
class FlappyMultiplayerService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? currentRoomId;
  String? currentPlayerId;
  bool isLeaving = false;
  Map<String, Player> currentPlayers = {};

  StreamSubscription? _playersSubscription;
  StreamSubscription? _roomSubscription;

  // 📡 Callbacks
  Function(Map<String, Player>)? onPlayersUpdated;
  Function(String)? onGameStatusChanged;
  Function(String)? onHostChanged;
  Function()? onKickedFromRoom;
  Function()? onGameFinished;

  // 🆕 Callback cho game start timestamp (dùng làm seed đồng bộ)
  Function(int)? onGameStarted;

  // 🆕 Tạo room mới
  Future<String> createRoom(String playerName) async {
    try {
      final roomId = _generateRoomId();
      final playerId = _generatePlayerId();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Tạo room
      await _database.child('rooms/$roomId').set({
        'roomId': roomId,
        'hostId': playerId,
        'hostName': playerName,
        'status': 'waiting',
        'createdAt': now,
      });

      // Thêm player vào room
      await _database
          .child('rooms/$roomId/players/$playerId')
          .set(Player(id: playerId, name: playerName, timestamp: now).toJson());

      await _database
          .child('rooms/$roomId/players/$playerId')
          .onDisconnect()
          .remove();

      currentRoomId = roomId;
      currentPlayerId = playerId;
      onHostChanged?.call(playerId);

      _listenToRoom(roomId);

      return roomId;
    } catch (e) {
      throw Exception('Không thể tạo phòng: $e');
    }
  }

  // 🚪 Tham gia room
  Future<bool> joinRoom(String roomId, String playerName) async {
    try {
      final roomSnapshot = await _database.child('rooms/$roomId').get();
      if (!roomSnapshot.exists) {
        throw Exception('Phòng không tồn tại!');
      }

      final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

      final playersSnapshot = await _database
          .child('rooms/$roomId/players')
          .get();
      if (playersSnapshot.exists) {
        final playersData = playersSnapshot.value as Map<dynamic, dynamic>;
        if (playersData.length >= 5) {
          throw Exception('Phòng đã đầy!');
        }
      }

      if (roomData['status'] == 'playing') {
        throw Exception('Game đã bắt đầu!');
      }

      final playerId = _generatePlayerId();
      final now = DateTime.now().millisecondsSinceEpoch;

      await _database
          .child('rooms/$roomId/players/$playerId')
          .set(Player(id: playerId, name: playerName, timestamp: now).toJson());

      await _database
          .child('rooms/$roomId/players/$playerId')
          .onDisconnect()
          .remove();

      currentRoomId = roomId;
      currentPlayerId = playerId;

      _listenToRoom(roomId);

      return true;
    } catch (e) {
      debugPrint("Lỗi tham gia phòng: $e");
      throw Exception('Không thể tham gia: $e');
    }
  }

  // 🎯 Bắt đầu game (chỉ host)
  Future<void> startGame() async {
    if (currentRoomId == null) return;

    // 🆕 Lưu timestamp khi game bắt đầu (dùng làm seed)
    final startTimestamp = DateTime.now().millisecondsSinceEpoch;

    await _database.child('rooms/$currentRoomId').update({
      'status': 'playing',
      'gameStartTime': startTimestamp, // 🔥 Quan trọng: dùng làm seed
    });
  }

  // 🐦 Cập nhật vị trí bird
  Future<void> updateBirdPosition(double y, int score, bool isAlive) async {
    if (currentRoomId == null || currentPlayerId == null) return;

    try {
      await _database
          .child('rooms/$currentRoomId/players/$currentPlayerId')
          .update({
            'birdY': y,
            'score': score,
            'isAlive': isAlive,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      debugPrint('Lỗi update position: $e');
    }
  }

  // 👂 Lắng nghe thay đổi trong room
  void _listenToRoom(String roomId) {
    // Lắng nghe players
    _playersSubscription = _database
        .child('rooms/$roomId/players')
        .onValue
        .listen((event) {
          if (event.snapshot.value != null) {
            final playersData = event.snapshot.value as Map<dynamic, dynamic>;
            final players = <String, Player>{};

            playersData.forEach((key, value) {
              players[key] = Player.fromJson(value);
            });
            currentPlayers = players;
            onPlayersUpdated?.call(players);

            if (currentPlayerId != null &&
                !players.containsKey(currentPlayerId)) {
              onKickedFromRoom?.call();
            }
          } else {
            currentPlayers = {};
            onPlayersUpdated?.call({});
          }
        });

    // Lắng nghe toàn bộ room
    // Trong _listenToRoom → thêm lắng nghe status 'finished'
    _roomSubscription = _database.child('rooms/$roomId').onValue.listen((
      event,
    ) {
      if (event.snapshot.value != null) {
        final roomData = Map<String, dynamic>.from(event.snapshot.value as Map);
        final status = roomData['status']?.toString() ?? 'waiting';

        onGameStatusChanged?.call(status);
        onHostChanged?.call(roomData['hostId']?.toString() ?? '');

        // Khi game bắt đầu
        if (status == 'playing' && roomData.containsKey('gameStartTime')) {
          final startTime = roomData['gameStartTime'] as int;
          onGameStarted?.call(startTime);
        }

        // KHI HẾT GIỜ → SERVER BÁO XONG!
        if (status == 'finished') {
          onGameFinished?.call(); // TẤT CẢ CLIENT ĐỀU NHẬN ĐƯỢC NGAY!
        }
      }
    });
  }

  // 🔍 Lấy danh sách rooms available
  Future<List<GameRoom>> getAvailableRooms() async {
    try {
      final snapshot = await _database.child('rooms').get();

      if (!snapshot.exists || snapshot.value == null) {
        debugPrint("⚠️ Không có phòng nào tồn tại");
        return [];
      }

      final List<GameRoom> rooms = [];
      final rawData = snapshot.value;

      if (rawData is Map) {
        for (var entry in rawData.entries) {
          try {
            final roomId = entry.key.toString();
            final roomValue = entry.value;

            if (roomValue is! Map) {
              debugPrint(
                "⚠️ Phòng $roomId không hợp lệ (value không phải Map)",
              );
              continue;
            }

            final roomData = Map<String, dynamic>.from(roomValue);
            final status = roomData['status']?.toString() ?? '';

            if (status != 'waiting') {
              continue;
            }

            int playerCount = 0;
            if (roomData.containsKey('players') &&
                roomData['players'] != null) {
              final playersData = roomData['players'];
              if (playersData is Map) {
                playerCount = playersData.length;
              }
            }

            final room = GameRoom(
              roomId: roomId,
              hostId: roomData['hostId']?.toString() ?? '',
              hostName: roomData['hostName']?.toString() ?? 'Ẩn danh',
              playerCount: playerCount,
              status: status,
              createdAt: roomData['createdAt'] as int? ?? 0,
            );

            rooms.add(room);
          } catch (e) {
            debugPrint("⚠️ Lỗi parse phòng ${entry.key}: $e");
            continue;
          }
        }
      } else {
        debugPrint(
          "⚠️ Dữ liệu rooms không phải Map, type: ${rawData.runtimeType}",
        );
      }

      return rooms;
    } catch (e, stack) {
      debugPrint('❌ Lỗi lấy danh sách phòng: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  // 🚪 Rời phòng
  Future<void> leaveRoom() async {
    if (isLeaving) return;
    isLeaving = true;

    if (currentRoomId == null || currentPlayerId == null) return;

    try {
      debugPrint('🗑 Người chơi này rời phòng: $currentPlayerId');
      final roomRef = _database.child('rooms/$currentRoomId');

      final roomSnapshot = await roomRef.get();
      if (!roomSnapshot.exists) return;

      final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
      final currentHostId = roomData['hostId'];

      // 1️⃣ Xóa player hiện tại khỏi danh sách
      await roomRef.child('players/$currentPlayerId').remove();
      debugPrint('🗑 Xoá người chơi này khỏi phòng: $currentPlayerId');
      // 2️⃣ Lấy lại danh sách players
      final playersSnapshot = await roomRef.child('players').get();

      if (!playersSnapshot.exists) {
        // 3️⃣ Không còn ai → xóa đúng phòng hiện tại
        debugPrint('🗑 Không còn người chơi nào, xóa phòng: $currentRoomId');
        await roomRef.remove(); // ✅ chỉ xóa "rooms/<currentRoomId>"
        _cleanup();
        return;
      }

      // 4️⃣ Nếu người rời là host → nhường quyền cho người khác
      if (currentPlayerId == currentHostId) {
        final Map<String, dynamic> players = Map<String, dynamic>.from(
          playersSnapshot.value as Map,
        );

        final newHostId = players.keys.first;
        final newHostData = Map<String, dynamic>.from(players[newHostId]);
        final newHostName = newHostData['name']?.toString() ?? 'Unknown';

        await roomRef.update({'hostId': newHostId, 'hostName': newHostName});

        debugPrint(
          '👑 Host $currentPlayerId rời → nhường host cho: $newHostName ($newHostId)',
        );
        onHostChanged?.call(newHostId);
      }

      // 5️⃣ Hoàn tất dọn dẹp
      _cleanup();
    } catch (e) {
      debugPrint('❌ Lỗi rời phòng: $e');
    } finally {
      isLeaving = false;
    }
  }

  // 🧹 Cleanup
  void _cleanup() {
    _playersSubscription?.cancel();
    _roomSubscription?.cancel();
    currentRoomId = null;
    currentPlayerId = null;
    onHostChanged = null;
    onKickedFromRoom = null;
    onGameStarted = null;
  }

  // 🪓 Kick player khỏi phòng (chỉ host)
  Future<void> kickPlayer(String playerId) async {
    if (currentRoomId == null || currentPlayerId == null) return;

    final roomRef = _database.child('rooms/$currentRoomId');

    try {
      final roomSnapshot = await roomRef.get();
      if (!roomSnapshot.exists) return;

      final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
      final currentHostId = roomData['hostId'];

      if (currentPlayerId != currentHostId) {
        debugPrint('Bạn không phải host, không thể kick player');
        return;
      }

      if (playerId == currentPlayerId) {
        debugPrint('Host không thể tự kick bản thân');
        return;
      }

      final playerRef = roomRef.child('players/$playerId');
      await playerRef.remove();

      debugPrint('Đã kick player: $playerId');
    } catch (e) {
      debugPrint('Lỗi kick player: $e');
    }
  }

  // Thêm hàm finishGame() (chỉ host gọi)
  Future<void> finishGame() async {
    if (currentRoomId == null) return;
    await _database.child('rooms/$currentRoomId').update({
      'status': 'finished',
      'finishedAt': ServerValue.timestamp,
    });
  }

  // 🎲 Generate random Room ID
  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // 🎲 Generate random Player ID
  String _generatePlayerId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }

  // 💣 Dispose
  void dispose() {
    _cleanup();
  }
}
