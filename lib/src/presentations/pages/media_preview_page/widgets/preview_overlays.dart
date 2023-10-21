import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/previewer.dart';

class PreviewPageOverlay extends GetView<MediaPreviewController> {
  const PreviewPageOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _Header(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _Bottom(
            controller,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // const Padding(
          //   padding: EdgeInsets.only(right: 12),
          //   child: Text(
          //     'I\'am center',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
          // const Spacer(),
        ],
      )),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom(this.controller);

  final MediaPreviewController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(.5),
            Colors.black.withOpacity(.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          VideoControlUI(
            controller: controller,
          ),
          MediaBottomThumbnail(
            controller: controller,
          ),
        ],
      ),
    );
  }
}

// class _VideoControllerUI extends GetView<MediaPreviewController> {
//   const _VideoControllerUI();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => AnimatedSwitcher(
//         duration: const Duration(milliseconds: 210),
//         child: Visibility(
//           key: controller.videoInitializeState.value.isSuccess
//               ? const Key('video_footer')
//               : const Key('image_footer'),
//           visible: controller.videoInitializeState.value.isSuccess,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(.2),
//                   Colors.black.withOpacity(.4),
//                   Colors.black.withOpacity(.8),
//                 ],
//               ),
//             ),
//             child: const SafeArea(
//                 child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _VideoProgressSlider(),
//                   kGapH4,
//                   _VideoDurationText(),
//                   _VideoPlayerControl(),
//                 ],
//               ),
//             )),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _VideoProgressSlider extends GetView<MediaPreviewController> {
//   const _VideoProgressSlider();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return SliderTheme(
//         data: SliderThemeData(
//           trackHeight: controller.isDraggingProgressBar.value ? 8 : 4,
//           //Rounded
//           thumbShape: RoundSliderThumbShape(
//             enabledThumbRadius: controller.isDraggingProgressBar.value ? 8 : 4,
//           ),
//           overlayShape: const RoundSliderOverlayShape(
//             overlayRadius: 8,
//           ),
//           valueIndicatorTextStyle:
//               Get.textTheme.labelSmall?.copyWith(color: Colors.black),
//           valueIndicatorColor: Colors.white.withOpacity(.4),
//         ),
//         child: Slider(
//           activeColor: Colors.white,
//           inactiveColor: Colors.white.withOpacity(.5),
//           value: max(0, min(controller.videoProgress.value * 100, 100)),
//           min: 0,
//           max: 100,
//           onChangeStart: controller.onSeekStart,
//           onChangeEnd: controller.onSeekEnd,
//           onChanged: controller.onVideoProgressChange,
//         ),
//       );
//     });
//   }
// }

// class _VideoDurationText extends GetView<MediaPreviewController> {
//   const _VideoDurationText();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             controller.videoPosition.value?.toHHmmss() ?? '',
//             style: Get.textTheme.labelMedium?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           Text(
//             controller.videoDuration.value?.toHHmmss() ?? '',
//             style: Get.textTheme.labelMedium?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _VideoPlayerControl extends GetView<MediaPreviewController> {
//   const _VideoPlayerControl();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             flex: 1,
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: IconButton(
//                 iconSize: 28,
//                 color: Colors.white70,
//                 onPressed: controller.muteUnMute,
//                 icon: Icon(controller.isMuted.value
//                     ? Icons.volume_off_rounded
//                     : Icons.volume_up),
//               ),
//             ),
//           ),
//           Expanded(
//               flex: 4,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     iconSize: 28,
//                     color: Colors.white70,
//                     onPressed: controller.rewindVideo,
//                     icon: const Icon(
//                       Icons.replay_10_outlined,
//                     ),
//                   ),
//                   kGapW12,
//                   IconButton(
//                     iconSize: 38,
//                     color: Colors.white,
//                     tooltip: controller.isVideoPlaying.value
//                         ? 'Pause video'
//                         : 'Play video',
//                     onPressed: () => controller.playPauseVideo(),
//                     icon: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 210),
//                       transitionBuilder: (child, animation) => FadeTransition(
//                         opacity: animation,
//                         child: child,
//                       ),
//                       child: controller.isVideoPlaying.value
//                           ? const Icon(Icons.pause)
//                           : const Icon(Icons.play_arrow),
//                     ),
//                   ),
//                   kGapW12,
//                   IconButton(
//                     iconSize: 28,
//                     color: Colors.white70,
//                     onPressed: controller.forwardVideo,
//                     icon: const Icon(
//                       Icons.forward_10_outlined,
//                     ),
//                   ),
//                 ],
//               )),
//           const Expanded(
//             flex: 1,
//             child: SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }
