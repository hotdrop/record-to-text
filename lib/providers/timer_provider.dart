import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerProvider = NotifierProvider<TimerNotifier, int>(TimerNotifier.new);

class TimerNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return 0;
  }

  void start() {
    _timer?.cancel();
    state = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => state++);
  }

  void stop() {
    _timer?.cancel();
  }
}
