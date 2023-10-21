import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/core/constrains/bottom_rectangular_track_shape.dart';
import 'package:vif_previewer/core/constrains/style_constrains.dart';
import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/core/utils/extensions/duration_ext.dart';
import 'package:vif_previewer/src/domain/models/video_player_data.dart';
import 'package:vif_previewer/src/presentations/widgets/embed_video_player/embed_video_player_controller.dart';
import 'package:vif_previewer/src/presentations/widgets/default_loading_indicator.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';
import 'package:video_player/video_player.dart';

class EmbedVideoPlayer extends StatelessWidget {
  /// Embed video player for playing video in embed mode
  ///
  ///This widget will automatically load the video thumbnail and display it as a preview.
  ///This widget can be used to play video in embed mode or full screen mode.
  const EmbedVideoPlayer({
    required this.controller,
    super.key,
  });

  /// The [EmbedVideoPlayerController] instance to control the video player
  ///
  /// [EmbedVideoPlayerController] is a [GetxController] instance, so you can use [Get.find] to get the instance.
  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) => ColoredBox(
        color: Colors.black,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.toggleShowOverlayUI,
                child: Obx(
                  () => (controller.videoInitializeState.value.isSuccess ||
                          controller.isFullScreen.value)
                      ? _VideoPlayerView(controller: controller)
                      : _VideoThumbnail(controller: controller),
                ),
              ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 310),
                  child: Visibility(
                    key: Key('embed_overlay_ui_${DateTime.now().toString()}'),
                    visible:
                        (controller.thumbnailLoadingStatus.value.isSuccess &&
                            controller.isShowOverlayUI.value),
                    child: (controller.embedVideoOverlayUI != null)
                        ? controller.embedVideoOverlayUI!(
                            context,
                            VideoPlayerData(
                              videoState: controller.videoInitializeState.value,
                              isVideoPlaying: controller.isVideoPlaying.value,
                              videoPosition: controller.videoPosition.value,
                              videoDuration: controller.videoDuration.value,
                              isMuted: controller.isMuted.value,
                            ),
                          )
                        : _EmbedOverlayUI(controller: controller),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({
    required this.controller,
  });

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    const loadingWidget = DefaultLoadingIndicator();
    const errorWidget = PreviewError(
      message: 'Error when loading video thumbnail',
    );

    return Obx(() {
      switch (controller.thumbnailLoadingStatus.value) {
        case LoadingStatus.idle:
        case LoadingStatus.loading:
          return loadingWidget;
        case LoadingStatus.success:
          return ExtendedImage.memory(
            controller.videoThumbnail.value!,
            fit: BoxFit.contain,
            loadStateChanged: (state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return loadingWidget;
                case LoadState.completed:
                  return null;
                case LoadState.failed:
                  return errorWidget;
              }
            },
          );
        case LoadingStatus.error:
          return errorWidget;
      }
    });
  }
}

class _VideoPlayerView extends StatelessWidget {
  const _VideoPlayerView({
    required this.controller,
  });

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    const errorWidget = PreviewError(
      message: 'Error when loading video thumbnail',
    );

    if (controller.videoInitializeState.value.isError) {
      return errorWidget;
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(
          controller.videoPlayerController!,
        ),
      ),
    );
  }
}

class _EmbedOverlayUI extends StatelessWidget {
  const _EmbedOverlayUI({
    required this.controller,
  });

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (controller.videoInitializeState.value.isLoading)
            const DefaultLoadingIndicator()
          else if (controller.videoInitializeState.value.isIdle ||
              controller.videoInitializeState.value.isSuccess)
            _CenterControls(controller: controller),
          if (controller.videoInitializeState.value.isSuccess)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomControls(controller: controller),
            ),
        ],
      ),
    );
  }
}

class _CenterControls extends StatelessWidget {
  const _CenterControls({required this.controller});

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = IconButton.styleFrom(
      maximumSize: const Size.fromRadius(36),
      backgroundColor: Colors.black.withOpacity(.6),
      foregroundColor: Colors.white,
    );
    final playButtonStyle = IconButton.styleFrom(
      maximumSize: const Size.fromRadius(42),
      backgroundColor: Colors.black.withOpacity(.6),
      foregroundColor: Colors.white,
    );
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (controller.videoInitializeState.value.isSuccess)
            IconButton(
              style: buttonStyle,
              tooltip: 'Rewind 10 seconds',
              onPressed: () => controller.rewindVideo(),
              icon: const Icon(Icons.replay_10_outlined),
            ),
          kGapW12,
          IconButton(
            style: playButtonStyle,
            tooltip:
                controller.isVideoPlaying.value ? 'Pause video' : 'Play video',
            onPressed: () => controller.togglePlayPause(),
            icon: controller.isVideoPlaying.value
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          kGapW12,
          if (controller.videoInitializeState.value.isSuccess)
            IconButton(
              style: buttonStyle,
              tooltip: 'Forward 10 seconds',
              onPressed: () => controller.forwardVideo(),
              icon: const Icon(Icons.forward_10_outlined),
            ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.controller});

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    // final widgetSize = MediaQuery.of(context).size;
    const buttonIconSize = 18.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(.3),
            Colors.black.withOpacity(.5),
          ],
        ),
      ),
      child: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.videoPosition.value?.toHHmmss()} / ${controller.videoDuration.value?.toHHmmss()}',
                    style: Get.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        iconSize: buttonIconSize,
                        color: Colors.white,
                        onPressed: controller.toggleMute,
                        icon: Icon(controller.isMuted.value
                            ? Icons.volume_off_rounded
                            : Icons.volume_up),
                      ),
                      IconButton(
                        iconSize: buttonIconSize,
                        color: Colors.white,
                        onPressed: () => controller.toggleFullScreen(
                          fullScreen: true,
                        ),
                        icon: const Icon(Icons.fullscreen_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.videoInitializeState.value.isSuccess)
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  //Rounded
                  thumbShape: SliderComponentShape.noThumb,
                  // overlayShape: SliderComponentShape.noOverlay,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                  valueIndicatorShape:
                      const RectangularSliderValueIndicatorShape(),
                  trackShape: BottomRectangularSliderTrackShape(),

                  valueIndicatorColor: Colors.white.withOpacity(.4),
                ),
                child: Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(.5),
                  value: max(0, min(controller.videoProgress.value * 100, 100)),
                  min: 0,
                  max: 100,
                  onChangeStart: controller.onSeekStart,
                  onChangeEnd: controller.onSeekEnd,
                  onChanged: controller.onVideoProgressChange,
                ),
              )
          ],
        ),
      ),
    );
  }
}
