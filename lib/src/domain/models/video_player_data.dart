// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:vif_previewer/core/enums/private_enum.dart';

class VideoPlayerData {
  const VideoPlayerData({
    required this.videoState,
    required this.isVideoPlaying,
    required this.videoPosition,
    required this.videoDuration,
    required this.isMuted,
  });

  /// The current state of the video player.
  final LoadingStatus videoState;

  /// Whether the video is playing or not.
  ///
  /// This value can be used to show the current state of the video.
  final bool isVideoPlaying;

  /// The current position of the video.
  ///
  ///This value can be used to show the current position of the video.
  final Duration? videoPosition;

  /// The duration of the video.
  ///
  /// This value can be used to show the total duration of the video.
  final Duration? videoDuration;

  /// Whether the video is muted or not.
  ///
  /// This value can be used to show the current state of the video.
  final bool isMuted;

  @override
  bool operator ==(covariant VideoPlayerData other) {
    if (identical(this, other)) return true;

    return other.videoState == videoState &&
        other.isVideoPlaying == isVideoPlaying &&
        other.videoPosition == videoPosition &&
        other.videoDuration == videoDuration &&
        other.isMuted == isMuted;
  }

  @override
  int get hashCode {
    return videoState.hashCode ^
        isVideoPlaying.hashCode ^
        videoPosition.hashCode ^
        videoDuration.hashCode ^
        isMuted.hashCode;
  }
}
