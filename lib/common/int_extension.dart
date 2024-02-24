extension FormatExecuteTime on int {
  String formatExecTime() {
    if (this < 1000) {
      return '$this ms';
    }

    // 60秒未満の場合
    if (this <= 60000) {
      double seconds = this / 1000;
      return "${seconds.toStringAsFixed(3)}s"; // 小数点以下3桁まで表示
    }

    // 60秒以上の場合
    int minutes = this ~/ 60000;
    int seconds = (this % 60000) ~/ 1000;
    return "${minutes}m${seconds}s";
  }
}
