class Player {
  final String id;
  final String name;
  double birdY;
  int score;
  bool isAlive;
  int timestamp;

  Player({
    required this.id,
    required this.name,
    this.birdY = 0,
    this.score = 0,
    this.isAlive = true,
    this.timestamp = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birdY': birdY,
    'score': score,
    'isAlive': isAlive,
    'timestamp': timestamp,
  };

  factory Player.fromJson(Map<dynamic, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Player',
      birdY: (json['birdY'] ?? 0).toDouble(),
      score: json['score'] ?? 0,
      isAlive: json['isAlive'] ?? true,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}