import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/core/utils/extensions/media_preview_data_ext.dart';

import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/domain/models/video_player_data.dart';
import 'package:vif_previewer/src/domain/models/video_play_config.dart';

import 'package:vif_previewer/src/presentations/widgets/embed_video_player/full_screen_video_player.dart';
import 'package:video_player/video_player.dart';

class EmbedVideoPlayerController extends GetxController {
  /// Create a new instance of [EmbedVideoPlayerController] used in [EmbedVideoPlayer].
  ///
  /// Provide some control methods to control the video player like:
  /// - [play]
  /// - [pause]
  /// - [seekTo]
  /// - [toggleFullScreen]
  /// - [toggleMute]
  /// - [rePlay]
  EmbedVideoPlayerController({
    required this.video,
    this.videoPlayConfig = VideoPlayConfig.defaultConfig,
    this.initVideoPlayerOnStart = false,
    this.embedVideoOverlayUI,
    this.fullScreenVideoOverlayUI,
  }) : assert(video.type.isVideo, 'Media type must be video');

  /// The [MediaPreviewData] instance
  ///
  /// The [MediaPreviewData.type] must be [MediaType.video]
  final MediaPreviewData video;

  /// Build your own custom UI overlay when the video is playing in embed mode
  ///
  /// This UI will be displayed on top of the video player. If not provided, the default UI will be displayed
  ///
  /// Note that when you use custom UI, you have to handle the video player control by yourself.
  final Widget Function(BuildContext context, VideoPlayerData data)?
      embedVideoOverlayUI;

  /// Build your own custom UI overlay when the video is playing in full screen mode
  ///
  /// This UI will be displayed on top of the video player. If not provided, the default UI will be displayed
  ///
  /// Note that when you use custom UI, you have to handle the video player control by yourself.
  final Widget Function(BuildContext context, VideoPlayerData data)?
      fullScreenVideoOverlayUI;

  /// The [VideoPlayConfig] instance to configure the video player
  final VideoPlayConfig videoPlayConfig;

  /// Whether to initialize the video player when the controller is initialized.
  ///
  /// If [initVideoPlayerOnStart] is set to `true` and also use custom overlay UI, you have to handle initializing the video player by yourself by calling [initializeVideoPlayer] method.
  ///
  /// [Warning] : If you set this to `true`, the video player will be initialized when the controller is initialized, even if the video is not playing.
  final bool initVideoPlayerOnStart;

  VideoPlayerController? _videoPlayerController;

  /// The [VideoPlayerController] instance
  ///
  /// [Warning] : Don't use it this variable directly, use other control methods instead.
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  ///Thumbnail loading status
  final thumbnailLoadingStatus = LoadingStatus.loading.obs;

  /// The video thumbnail
  final videoThumbnail = Rxn<Uint8List>();

  //Helper variables
  double _updateProgressInterval = 0.0;
  Timer? _autoHideOverlayDebounce;

  /// Variable to store the current video progress
  final videoInitializeState = LoadingStatus.idle.obs;
  final isVideoPlaying = false.obs;
  final videoPosition = Rxn<Duration>();
  final videoDuration = Rxn<Duration>();
  final videoProgress = 0.0.obs;
  final isDraggingProgressBar = false.obs;
  final isMuted = true.obs;
  final isFullScreen = false.obs;
  final isShowOverlayUI = true.obs;

  @override
  void onInit() {
    _loadThumbnail();
    if (initVideoPlayerOnStart) {
      initializeVideoPlayer();
    }
    super.onInit();
  }

  @override
  void onClose() {
    _videoPlayerController?.dispose();
    super.onClose();
  }

  Future<void> _loadThumbnail() async {
    thumbnailLoadingStatus.value = LoadingStatus.loading;
    try {
      final thumbnail = await video.getVideoThumbnail();
      if (thumbnail == null) {
        throw Exception('Thumbnail is null');
      }
      videoThumbnail.value = thumbnail;
      thumbnailLoadingStatus.value = LoadingStatus.success;
    } catch (e) {
      thumbnailLoadingStatus.value = LoadingStatus.error;
    }
  }

  /// Initialize the video player with the given [video]
  ///
  /// If the video player is already initialized, do nothing
  Future<void> initializeVideoPlayer() async {
    if (videoPlayerController != null) return;

    videoInitializeState.call(LoadingStatus.loading);

    if (video is AssetMediaPreviewData) {
      _videoPlayerController = VideoPlayerController.asset(video.data);
    } else if (video is NetworkMediaPreviewData) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(video.data),
      );
    } else if (video is FileMediaPreviewData) {
      _videoPlayerController = VideoPlayerController.file(video.data);
    } else if (video is MemoryMediaPreviewData) {
      final file = await video.getFile();
      _videoPlayerController = VideoPlayerController.file(file);
    } else {
      throw Exception('Media type not supported');
    }

    videoPlayerController
        ?.initialize()
        .then((_) => _onVideoInitialized())
        .onError(_onInitError);
  }

  Future<void> _onVideoInitialized() async {
    videoDuration.value = null;
    videoPosition.value = null;

    videoPlayerController?.addListener(_onVideoUpdate);

    if (isMuted.value && videoPlayConfig.muteOnStart) {
      videoPlayerController?.setVolume(0);
    }

    if (videoPlayConfig.autoPlay) {
      play();
    }

    videoInitializeState.call(LoadingStatus.success);
  }

  void _onInitError(Object? error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print(error.toString());
    }
    videoInitializeState.value = LoadingStatus.error;
  }

  Future<void> _onVideoUpdate() async {
    if (isClosed || videoPlayerController == null) return;

    if (!videoPlayerController!.value.isInitialized) return;
    // Update video progress every 200ms
    // This is to prevent too many updates to the progress bar
    if (Platform.isAndroid) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_updateProgressInterval > now) {
        return;
      }
      _updateProgressInterval = now + 200.0;
    }

    videoDuration.value ??= videoPlayerController!.value.duration;

    var duration = videoDuration.value;

    var position = await videoPlayerController!.position;

    if (duration == null || position == null) return;

    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inMilliseconds + 500 >= duration.inMilliseconds;

    videoPosition.value = position;
    videoProgress.value = position.inMilliseconds.ceilToDouble() /
        duration.inMilliseconds.ceilToDouble();

    if (!isEndOfClip) return;

    isVideoPlaying.value = false;

    toggleShowOverlayUI(isShow: true);

    if (!videoPlayConfig.looping) return;

    rePlay();
  }

  /// Check if the video is playing and the overlay UI is showing,
  /// then hide the overlay UI after a few seconds of inactivity.
  void _autoHideOverlayUI() {
    if (!videoPlayConfig.autoHide) return;

    _autoHideOverlayDebounce?.cancel();
    _autoHideOverlayDebounce = Timer(videoPlayConfig.autoHideDuration, () {
      if (!isShowOverlayUI.value || !isVideoPlaying.value) return;
      isShowOverlayUI.value = false;
    });
  }

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  void _showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Toggle the overlay UI visibility
  ///
  /// If [isShow] is not provided, the overlay UI will toggle to the opposite of the current state.
  void toggleShowOverlayUI({bool? isShow}) {
    isShowOverlayUI.value = isShow ?? !isShowOverlayUI.value;
    if (isShowOverlayUI.value && isVideoPlaying.value) {
      _autoHideOverlayUI();
    }
  }

  /// Replay the video from the beginning
  void rePlay() {
    videoPlayerController?.seekTo(Duration.zero);
    videoPlayerController?.play();
    isVideoPlaying.value = true;
    _autoHideOverlayUI();
  }

  /// Toggle the video player's play/pause state.
  ///
  /// If the video is not initialized, initialize the video player first.
  void togglePlayPause() {
    if (isVideoPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  /// Play the video.
  ///
  /// If the video is not initialized, initialize the video player first.
  Future<void> play() async {
    if (videoPlayerController == null) {
      await initializeVideoPlayer();
    } else {
      await videoPlayerController?.play();
      isVideoPlaying.value = true;
      _autoHideOverlayUI();
    }
  }

  /// Pause the video.
  ///
  /// If the video is not playing or the video is not initialized, do nothing
  Future<void> pause() async {
    if (videoPlayerController == null) return;
    await videoPlayerController?.pause();
    isVideoPlaying.value = false;
  }

  /// Seek to the given position.
  ///
  /// If the video is not initialized, do nothing
  void seekTo(Duration position) {
    if (videoPlayerController == null) return;

    videoPlayerController?.seekTo(position);
  }

  /// Toggle the video player's full-screen mode.
  ///
  /// If [fullScreen] is not provided, the video player will toggle to the opposite of the current state.
  Future<void> toggleFullScreen({bool? fullScreen}) async {
    isFullScreen.value = fullScreen ?? !isFullScreen.value;
    final isPlaying = isVideoPlaying.value;

    if (isPlaying) await pause();

    if (isFullScreen.value) {
      Get.to(
        () => FullScreenVideoPlayer(controller: this),
        duration: const Duration(milliseconds: 310),
        transition: Transition.fadeIn,
        opaque: false,
      );
      _hideStatusBar();
    } else {
      _showStatusBar();
      Get.back();
    }

    if (isPlaying) await play();
  }

  /// Toggle the video player's mute state.
  ///
  /// If [mute] is not provided, the video player will toggle to the opposite of the current state.
  void toggleMute({bool? mute}) {
    if (videoPlayerController == null) return;

    mute ??= !isMuted.value;

    if (mute) {
      videoPlayerController?.setVolume(0);
    } else {
      videoPlayerController?.setVolume(1);
    }

    isMuted.value = mute;
    _autoHideOverlayUI();
  }

  /// Rewind the video by duration.
  ///
  /// If [duration] is not provided, the video will be rewinded by 10 seconds.
  ///
  /// If the video is not initialized, do nothing
  void rewindVideo({Duration? duration}) {
    if (videoPlayerController == null) return;

    final position = videoPlayerController!.value.position;

    final newPosition = position - const Duration(seconds: 10);

    if (newPosition < Duration.zero) {
      videoPlayerController!.seekTo(Duration.zero);
    } else {
      videoPlayerController!.seekTo(newPosition);
    }
    _autoHideOverlayUI();
  }

  /// Forward the video by duration.
  ///
  /// If [duration] is not provided, the video will be forwarded by 10 seconds.
  ///
  /// If the video is not initialized, do nothing
  void forwardVideo({Duration? duration}) {
    if (videoPlayerController == null) return;

    final videoDuration = videoPlayerController!.value.duration;
    final position = videoPlayerController!.value.position;

    final newPosition = position + (duration ?? const Duration(seconds: 10));

    if (newPosition > videoDuration) {
      videoPlayerController!.seekTo(videoDuration);
    } else {
      videoPlayerController!.seekTo(newPosition);
    }
    _autoHideOverlayUI();
  }

  void onSeekStart(double value) {
    _autoHideOverlayDebounce?.cancel();
    videoPlayerController?.pause();
    isDraggingProgressBar.value = true;
  }

  void onSeekEnd(double value) {
    isDraggingProgressBar.value = false;
    if (isVideoPlaying.value) {
      videoPlayerController?.play();
      _autoHideOverlayUI();
    }
  }

  void onVideoProgressChange(double value) {
    if (videoPlayerController == null) return;

    final duration = videoPlayerController!.value.duration;

    videoProgress.value = value * 0.01;
    var newValue = max(0, min(value, 99)) * 0.01;
    var milliseconds = (duration.inMilliseconds * newValue).toInt();

    videoPlayerController!.seekTo(Duration(milliseconds: milliseconds));
  }
}
