import 'player.dart';

class GameRoom {
  final String roomId;
  final String hostId;
  final String hostName;
  final List<Player> players;
  final String status; // 'waiting', 'playing', 'finished'
  final int playerCount;
  final int createdAt;

  GameRoom({
    required this.roomId,
    required this.hostId,
    this.hostName = "Ẩn danh",
    this.players = const [],
    this.status = 'waiting',
    required this.playerCount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'hostId': hostId,
    'hostName': hostName,
    'status': status,
    'playerCount': playerCount,
    'createdAt': createdAt,
  };

  factory GameRoom.fromJson(String roomId, Map<dynamic, dynamic> json) {
    return GameRoom(
      roomId: roomId,
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? 'Ẩn danh',
      status: json['status'] ?? 'waiting',
      playerCount: json['playerCount'] ?? 0,
      createdAt: json['createdAt'] ?? 0,
    );
  }
}
