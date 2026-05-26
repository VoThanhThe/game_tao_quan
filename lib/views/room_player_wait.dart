import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  List<String?> players = ["Tôi", null, null];
  final List<String> friends = ["Minh", "Lan", "Huy", "Trang", "Đạt", "Phương"];
  bool isHost = true;

  void inviteFriend(String name) {
    final index = players.indexWhere((p) => p == null);
    if (index != -1) {
      setState(() {
        players[index] = name;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Phòng đã đầy!")));
    }
  }

  void startGame() {
    final hasEmpty = players.contains(null);
    if (hasEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cần đủ người chơi để bắt đầu!")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Trò chơi bắt đầu! 🚀")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Phòng chờ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'FzCoTrang',
          ),
        ),
        backgroundColor: const Color(0xFFFAB12F),
        centerTitle: true,
      ),

      endDrawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFAB12F)),
              child: Center(
                child: Text(
                  "Mời bạn bè",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FzCoTrang',
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 1,
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFAD961), Color(0xFFF76B1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          "https://i.pinimg.com/736x/b7/7f/65/b77f65dee5957b1175ad32cffaf61df7.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      friend,
                      style: const TextStyle(fontFamily: 'FzCoTrang'),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        inviteFriend(friend);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFAB12F),
                      ),
                      child: const Text(
                        "Mời",
                        style: TextStyle(fontFamily: 'FzCoTrang'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // === GRID CÁC SLOT NGƯỜI CHƠI ===
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: players.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 ô ngang
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 140, // chiều cao mỗi ô
                ),
                itemBuilder: (context, index) {
                  final player = players[index];
                  isHost = index == 0;

                  return Column(
                    children: [
                      // --- Khung Avatar ---
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: player != null
                                    ? Colors.orangeAccent
                                    : Colors.grey,
                                width: 3,
                              ),
                              gradient: player != null
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFAD961),
                                        Color(0xFFF76B1C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: player == null ? Colors.grey[300] : null,
                            ),
                            child: ClipOval(
                              child: player != null
                                  ? Image.network(
                                      "https://i.pinimg.com/736x/b7/7f/65/b77f65dee5957b1175ad32cffaf61df7.jpg",
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                            ),
                          ),
                          if (isHost)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFAD961),
                                        Color(0xFFF76B1C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Chủ phòng',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontFamily: 'FzCoTrang',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // --- Tên người chơi ---
                      Text(
                        player ?? "Trống",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'FzCoTrang',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Column(
              children: [
                const Text(
                  "Chia sẻ mã phòng để mời bạn bè tham gia:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FzCoTrang',
                  ),
                ),
                const SizedBox(height: 8),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // === MÃ PHÒNG ===
                      Text(
                        "ABCD1234",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
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

                      // === NÚT COPY ===
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: "ABCD1234"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã sao chép mã phòng!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.9 * 255).toInt()),
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
                ),
              ],
            ),
            const SizedBox(height: 10),

            // === Nút hành động ===
            // if (isHost)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Builder(
                  builder: (context) {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        "Mời bạn bè",
                        style: TextStyle(fontFamily: 'FzCoTrang'),
                      ),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFAB12F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    "Bắt đầu chơi",
                    style: TextStyle(fontFamily: 'FzCoTrang'),
                  ),
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
