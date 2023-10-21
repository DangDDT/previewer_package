extension DurationExt on Duration {
  ///Convert duration to format hh:mm:ss
  String toHHmmss() {
    var formattedDuration = '';
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    formattedDuration =
        '${hours > 0 ? '$hoursStr:' : ''}$minutesStr:$secondsStr';
    return formattedDuration;
  }
}
