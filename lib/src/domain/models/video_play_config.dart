// ignore_for_file: public_member_api_docs, sort_constructors_first
class VideoPlayConfig {
  const VideoPlayConfig({
    this.autoPlay = true,
    this.looping = false,
    this.muteOnStart = true,
    this.autoHide = true,
    this.autoHideDuration = const Duration(seconds: 3),
  });

  /// The default configuration for the video player:
  /// ```dart
  /// VideoPlayConfig(
  ///   autoPlay: true,
  ///   looping: false,
  ///   muteOnStart: true,
  ///   autoHide: true,
  ///   autoHideDuration: Duration(seconds: 3),
  /// );
  /// ```
  static const defaultConfig = VideoPlayConfig(
    autoPlay: true,
    looping: false,
    muteOnStart: true,
    autoHide: true,
    autoHideDuration: Duration(seconds: 3),
  );

  /// Whether to automatically start playing the video when initialized.
  final bool autoPlay;

  /// Whether to loop the video when it reaches the end.
  final bool looping;

  /// Whether to mute the video when it starts for the first time.
  final bool muteOnStart;

  /// Whether to hide the controls after a few seconds of inactivity.
  final bool autoHide;

  /// The duration after which the controls should be hidden.
  final Duration autoHideDuration;
}
