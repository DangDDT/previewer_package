// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vif_previewer/core/constrains/style_constrains.dart';
import 'package:vif_previewer/core/utils/extensions/duration_ext.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_controller.dart';

class VideoControlUI extends StatelessWidget {
  /// Default video control UI for [MediaPreviewPageView]
  ///
  /// Add same [MediaPreviewController] of [MediaPreviewPageView] to this widget
  /// If the current media is not a video, this widget will not be displayed
  ///
  /// This widget is used to control video playback, including:
  /// - Play/Pause video
  /// - Mute/Un-mute video
  /// - Rewind/Forward video
  /// - Seek video
  const VideoControlUI({
    super.key,
    required this.controller,
    this.foregroundColor,
  });

  /// [MediaPreviewController] of [MediaPreviewPageView] to control video playback
  final MediaPreviewController controller;

  /// Color of video control UI
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: foregroundColor),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 210),
            child: controller.videoInitializeState.value.isSuccess &&
                    controller.isShowOverlayUI.value
                ? SafeArea(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _VideoProgressSlider(
                          controller: controller,
                          foregroundColor: foregroundColor,
                        ),
                        kGapH4,
                        _VideoDurationText(
                          controller: controller,
                          color: foregroundColor,
                        ),
                        _VideoPlayerControl(
                          controller: controller,
                          color: foregroundColor,
                        ),
                      ],
                    ),
                  ))
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _VideoProgressSlider extends StatelessWidget {
  const _VideoProgressSlider({
    Key? key,
    required this.controller,
    required this.foregroundColor,
  }) : super(key: key);

  final MediaPreviewController controller;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          //Rounded
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: controller.isDraggingProgressBar.value ? 8 : 4,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
        ),
        child: Slider(
          activeColor: foregroundColor,
          inactiveColor:
              foregroundColor?.withOpacity(.5) ?? Colors.white.withOpacity(.5),
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
  const _VideoDurationText({
    Key? key,
    required this.controller,
    required this.color,
  }) : super(key: key);

  final MediaPreviewController controller;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.videoPosition.value?.toHHmmss() ?? '',
            style: Get.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            controller.videoDuration.value?.toHHmmss() ?? '',
            style: Get.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerControl extends StatelessWidget {
  const _VideoPlayerControl({
    Key? key,
    required this.controller,
    this.color,
  }) : super(key: key);

  final MediaPreviewController controller;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const iconSize = 24.0;
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: iconSize,
                color: color,
                onPressed: controller.muteUnMute,
                icon: Icon(
                  controller.isMuted.value
                      ? Icons.volume_off_rounded
                      : Icons.volume_up,
                ),
              ),
            ),
          ),
          Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: iconSize,
                    color: color,
                    onPressed: controller.rewindVideo,
                    icon: const Icon(
                      Icons.replay_10_outlined,
                    ),
                  ),
                  kGapW12,
                  IconButton(
                    iconSize: iconSize,
                    color: color,
                    tooltip: controller.isVideoPlaying.value
                        ? 'Pause video'
                        : 'Play video',
                    onPressed: () => controller.playPauseVideo(),
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
                    iconSize: iconSize,
                    color: color,
                    onPressed: controller.forwardVideo,
                    icon: const Icon(
                      Icons.forward_10_outlined,
                    ),
                  ),
                ],
              )),
          const Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
