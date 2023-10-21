class DebounceHelpers {
  ///Wait until [predicate] is true, then execute [action] with [duration] delay.
  ///Stop when [stopWhen] is true.
  static Future<void> waitUntil(
    Future<bool> Function() predicate,
    Future<void> Function() action, {
    Duration duration = const Duration(milliseconds: 300),
    Future<bool> Function()? stopWhen,
  }) async {
    while (true) {
      if (stopWhen != null && await stopWhen()) {
        break;
      }
      if (await predicate()) {
        await Future.delayed(duration);
        if (await predicate()) {
          await action();
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
