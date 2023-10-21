import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/core/utils/get_view_2.dart';
import 'package:vif_previewer/previewer.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_page/sliding_controller.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_page/widgets/preview_overlays.dart';
import 'package:vif_previewer/src/presentations/widgets/image_preview_item.dart';
import 'package:vif_previewer/src/presentations/widgets/video_preview_item.dart';

class MediaPreviewPage
    extends GetView2<MediaPreviewController, SlidingController> {
  const MediaPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ExtendedImageSlidePage(
        onSlidingPage: controller2.onSlidingPage,
        slidePageBackgroundHandler: controller2.slidePageBackgroundHandler,
        slideOffsetHandler: controller2.onSlideOffsetHandler,
        slideScaleHandler: controller2.onSlideScaleHandler,
        slideAxis: SlideAxis.vertical,
        // dismissAxis: DismissAxis.down,
        // dismissType: DismissType.item,
        child: Obx(
          () => Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: _MediaView(),
              ),
              Positioned.fill(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.decelerate,
                  switchOutCurve: Curves.decelerate,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  duration: const Duration(milliseconds: 310),
                  child: (controller2.isShowOverlayUI.value)
                      ? const PreviewPageOverlay()
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaView extends GetView2<MediaPreviewController, SlidingController> {
  const _MediaView();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller2.toggleShowOverlayUI,
        child: ExtendedImageGesturePageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: controller1.pageController,
          itemCount: controller1.mediaList.length,
          preloadPagesCount: 4,
          onPageChanged: (index) => controller1.onItemPageChanged(index),
          itemBuilder: (BuildContext context, int index) {
            final data = controller1.mediaList[index];
            late final Widget media;

            if (data.type.isVideo) {
              media = ExtendedImageSlidePageHandler(
                child: VideoPreviewItem(
                  index: index,
                  previewData: data,
                  controller: controller1,
                ),
              );
            } else {
              media = ImagePreviewItem(
                previewData: data,
                controller: controller1,
              );
            }

            return Obx(
              () => controller1.currentItemIndex.value == index &&
                      data.heroTag != null
                  ? Hero(tag: data.heroTag, child: media)
                  : media,
            );
          },
        ),
      ),
    );
  }
}
