// import 'package:flutter/material.dart';
// import 'package:flame/game.dart';

// import '../flappy_multiplayer_service.dart';
// import 'multiplayer_game_screen.dart';
// // import 'multiplayer_flame_game.dart';
// // import '../services/flappy_multiplayer_service.dart';

// /// Widget để chạy multiplayer game
// /// Sử dụng trong WaitingRoomScreen khi game bắt đầu
// class MultiplayerGameWrapper extends StatefulWidget {
//   final FlappyMultiplayerService multiplayerService;

//   const MultiplayerGameWrapper({
//     super.key,
//     required this.multiplayerService,
//   });

//   @override
//   State<MultiplayerGameWrapper> createState() => _MultiplayerGameWrapperState();
// }

// class _MultiplayerGameWrapperState extends State<MultiplayerGameWrapper> {
//   late MultiplayerGameScreen game;

//   @override
//   void initState() {
//     super.initState();
//     game = MultiplayerGameScreen(multiplayerService: widget.multiplayerService);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Game chính
//           GameWidget(game: game),

//           // Scoreboard ở góc trên
//           Positioned(
//             top: 150,
//             left: 10,
//             child: _buildScoreboard(),
//           ),

//           // Nút thoát
//           Positioned(
//             top: 40,
//             right: 10,
//             child: IconButton(
//               icon: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 30,
//               ),
//               onPressed: () => _showExitDialog(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScoreboard() {
//     return StreamBuilder<Map<String, Player>>(
//       stream: _getPlayersStream(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();

//         final players = snapshot.data!;
//         final sortedPlayers = players.entries.toList()
//           ..sort((a, b) => b.value.score.compareTo(a.value.score));

//         return Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: sortedPlayers.map((entry) {
//               final player = entry.value;
//               final isMe = entry.key == widget.multiplayerService.currentPlayerId;
              
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 2),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: _getPlayerColor(sortedPlayers.indexOf(entry)),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       isMe ? 'Bạn' : player.name,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${player.score}',
//                       style: const TextStyle(
//                         color: Colors.yellow,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (!player.isAlive)
//                       const Padding(
//                         padding: EdgeInsets.only(left: 5),
//                         child: Text(
//                           '💀',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Color _getPlayerColor(int index) {
//     final colors = [
//       Colors.yellow,
//       Colors.red,
//       Colors.blue,
//       Colors.green,
//       Colors.purple,
//     ];
//     return colors[index % colors.length];
//   }

//   Stream<Map<String, Player>> _getPlayersStream() {
//     // Tạo stream từ callback
//     return Stream.periodic(const Duration(milliseconds: 100), (_) {
//       // Lấy danh sách players từ game
//       final players = <String, Player>{};
      
//       // Thêm player của mình
//       if (widget.multiplayerService.currentPlayerId != null) {
//         players[widget.multiplayerService.currentPlayerId!] = Player(
//           id: widget.multiplayerService.currentPlayerId!,
//           name: 'Bạn',
//           birdY: game.playerComponent.position.y,
//           score: game.playerComponent.score,
//           isAlive: game.playerComponent.isAlive ?? true,
//         );
//       }

//       // Thêm opponents
//       game.opponents.forEach((id, opponent) {
//         players[id] = Player(
//           id: id,
//           name: opponent.playerName,
//           birdY: opponent.birdY,
//           score: opponent.score,
//           isAlive: opponent.isAlive,
//         );
//       });

//       return players;
//     });
//   }

//   void _showExitDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Thoát game?'),
//         content: const Text('Bạn có chắc muốn thoát không?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Hủy'),
//           ),
//           TextButton(
//             onPressed: () {
//               widget.multiplayerService.leaveRoom();
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             child: const Text('Thoát', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     game.onRemove();
//     super.dispose();
//   }
// }

// // 🎯 CÁCH SỬ DỤNG:
// // 
// // Trong WaitingRoomScreen, khi game status = 'playing':
// // 
// // Navigator.pushReplacement(
// //   context,
// //   MaterialPageRoute(
// //     builder: (_) => MultiplayerGameWrapper(
// //       multiplayerService: widget.multiplayerService,
// //     ),
// //   ),
// // );