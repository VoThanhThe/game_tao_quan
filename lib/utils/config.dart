// class Config {
//   static const baseSpeed = 100.0;
//   static const backgroundSpeed = 10.0;
//   static const groundHeight = 112.0;
//   static const gravity = 600.0;
//   static const velocity = -250.0;
//   static const pipeHeight = 320.0;
//   static const spaceCenterPipe = 330.0;
//   static final itemPointHeight = ((spaceCenterPipe) / 2);
// }

class Config {
  static const baseSpeed = 120.0;
  static const backgroundSpeed = 10.0;
  static const groundHeight = 112.0;
  static const gravity = 600.0;
  static const velocity = -250.0;
  static const pipeHeight = 320.0;
  static double characterSize = 80.0;

  static const iphoneSE = 700.0;
  static const miniIpad = 1024.0;
  static const ipadPro = 1300.0;

  // 🔥 Dynamic space calculation based on screen height
  static double getSpaceCenterPipe(double screenHeight) {
    // Tính toán khoảng cách dựa trên tỷ lệ màn hình
    final playableHeight = screenHeight - groundHeight;

    // Khoảng cách pipe = 35-40% chiều cao có thể chơi
    // Điều chỉnh tỷ lệ này để game dễ hoặc khó hơn
    return playableHeight * 0.38;
  }

  // 🔥 Dynamic item height calculation
  static double getItemPointHeight(double screenHeight) {
    return getSpaceCenterPipe(screenHeight) / 2;
  }

  // Legacy constants (deprecated - use dynamic methods instead)
  static double spaceCenterPipe = 330.0; // Fallback value
  static double itemPointHeight = spaceCenterPipe / 2; // Fallback value

  static void updateByCharacterSize() {
    spaceCenterPipe =
        (characterSize * 4.0) + 5; // ví dụ: tỉ lệ 4x kích thước chim
    itemPointHeight = spaceCenterPipe / 2;
  }

  // 🔥 Safe zone margins for pipe generation
  static double getMinTopMargin(double screenHeight) {
    return screenHeight * 0.12; // 12% from top
  }

  static double getMinBottomMargin(double screenHeight) {
    return screenHeight * 0.12; // 12% from bottom
  }

  // 🔥 Maximum random variation for pipes
  static double getMaxTopMargin(double screenHeight) {
    return screenHeight * 0.30; // 30% from top
  }

  static double getMaxBottomMargin(double screenHeight) {
    return screenHeight * 0.30; // 30% from bottom
  }
}
