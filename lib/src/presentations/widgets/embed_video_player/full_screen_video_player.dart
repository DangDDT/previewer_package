// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:vif_previewer/core/constrains/style_constrains.dart';
import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/core/utils/extensions/duration_ext.dart';
import 'package:vif_previewer/src/domain/models/video_player_data.dart';
import 'package:vif_previewer/src/presentations/widgets/embed_video_player/embed_video_player_controller.dart';
import 'package:vif_previewer/src/presentations/widgets/default_loading_indicator.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  const FullScreenVideoPlayer({super.key, required this.controller});

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.toggleFullScreen(fullScreen: false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.toggleShowOverlayUI(),
                child: Obx(() =>
                    (controller.videoInitializeState.value.isSuccess)
                        ? _VideoPlayerView(controller: controller)
                        : _VideoThumbnail(controller: controller)),
              ),
            ),
            Positioned.fill(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 310),
                  child: Visibility(
                    key: Key('overlay_ui_${controller.isShowOverlayUI.value}'),
                    visible:
                        (controller.thumbnailLoadingStatus.value.isSuccess &&
                            controller.isShowOverlayUI.value),
                    child: (controller.fullScreenVideoOverlayUI != null)
                        ? controller.fullScreenVideoOverlayUI!(
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
        case LoadingStatus.loading:
        case LoadingStatus.idle:
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
  const _EmbedOverlayUI({required this.controller});
  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _Header(controller),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _VideoControllerUI(controller),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(.5),
            Colors.black.withOpacity(.3),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: IconButton(
                  onPressed: () => controller.toggleFullScreen(
                    fullScreen: false,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _VideoControllerUI extends StatelessWidget {
  const _VideoControllerUI(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 210),
        child: Visibility(
          key: controller.videoInitializeState.value.isSuccess
              ? const Key('video_footer')
              : const Key('image_footer'),
          visible: controller.videoInitializeState.value.isSuccess,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.2),
                  Colors.black.withOpacity(.4),
                  Colors.black.withOpacity(.8),
                ],
              ),
            ),
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _VideoProgressSlider(controller),
                  kGapH4,
                  _VideoDurationText(controller),
                  _VideoPlayerControl(controller),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class _VideoProgressSlider extends StatelessWidget {
  const _VideoProgressSlider(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SliderTheme(
        data: SliderThemeData(
          trackHeight: controller.isDraggingProgressBar.value ? 8 : 4,
          //Rounded
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: controller.isDraggingProgressBar.value ? 8 : 4,
          ),
          overlayShape: const RoundSliderOverlayShape(
            overlayRadius: 8,
          ),
          valueIndicatorTextStyle:
              Get.textTheme.labelSmall?.copyWith(color: Colors.black),
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
      );
    });
  }
}

class _VideoDurationText extends StatelessWidget {
  const _VideoDurationText(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.videoPosition.value?.toHHmmss() ?? '',
            style: Get.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            controller.videoDuration.value?.toHHmmss() ?? '',
            style: Get.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerControl extends StatelessWidget {
  const _VideoPlayerControl(
    this.controller, {
    Key? key,
  }) : super(key: key);

  final EmbedVideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 24,
                color: Colors.white,
                onPressed: controller.toggleMute,
                icon: Icon(controller.isMuted.value
                    ? Icons.volume_off_rounded
                    : Icons.volume_up),
              ),
            ),
          ),
          Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 28,
                    color: Colors.white,
                    onPressed: controller.rewindVideo,
                    icon: const Icon(
                      Icons.replay_10_outlined,
                    ),
                  ),
                  kGapW12,
                  IconButton(
                    iconSize: 38,
                    color: Colors.white,
                    tooltip: controller.isVideoPlaying.value
                        ? 'Pause video'
                        : 'Play video',
                    onPressed: controller.togglePlayPause,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 210),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: controller.isVideoPlaying.value
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                  ),
                  kGapW12,
                  IconButton(
                    iconSize: 28,
                    color: Colors.white,
                    onPressed: controller.forwardVideo,
                    icon: const Icon(
                      Icons.forward_10_outlined,
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                iconSize: 24,
                color: Colors.white,
                onPressed: controller.toggleFullScreen,
                icon: const Icon(Icons.fullscreen_exit_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
