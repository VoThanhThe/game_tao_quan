import 'package:firebase_database/firebase_database.dart';

class GameService {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> createRoom(String roomId, String playerId) async {
    await _db.child('rooms/$roomId').set({
      'started': false,
      'players': {
        playerId: {'y': 300, 'score': 0}
      }
    });
  }

  Future<void> joinRoom(String roomId, String playerId) async {
    await _db.child('rooms/$roomId/players/$playerId').set({
      'y': 300,
      'score': 0,
    });
  }

  Stream<Map<String, dynamic>> roomStream(String roomId) {
    return _db.child('rooms/$roomId/players').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return data?.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))) ?? {};
    });
  }

  Future<void> updatePlayer(String roomId, String playerId, double y, int score) async {
    await _db.child('rooms/$roomId/players/$playerId').update({
      'y': y,
      'score': score,
    });
  }
}
