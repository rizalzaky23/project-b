import 'dart:io';

String getBaseUrl() {
  if (Platform.isAndroid) {
    // Android Emulator: 10.0.2.2 adalah alias ke localhost host machine
    return 'http://10.0.2.2:8000/api';
  }
  // macOS, iOS, Windows, Linux
  return 'http://127.0.0.1:8000/api';
}
