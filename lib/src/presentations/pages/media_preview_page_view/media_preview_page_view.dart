import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:vif_previewer/core/utils/extensions/media_preview_data_ext.dart';
import 'package:vif_previewer/previewer.dart';
import 'package:vif_previewer/src/presentations/widgets/default_loading_indicator.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';

class MediaPreviewPageView extends StatelessWidget {
  ///Default [MediaPreviewPageView]
  ///
  ///This widget is used to display a list of images and videos
  const MediaPreviewPageView({
    required this.controller,
    this.emptyBuilder,
    this.foregroundColor,
    this.physics = const BouncingScrollPhysics(),
    this.touchAction = TouchMediaAction.none,
    super.key,
  });

  ///Controller for [MediaPreviewPageView]
  ///
  ///This controller is used to control the data of [MediaPreviewPageView]
  final MediaPreviewController controller;

  ///Builder for empty data
  ///
  ///Default is [Text('Empty')]
  final Widget Function(BuildContext context)? emptyBuilder;

  ///Color of text and error icon
  ///
  ///This should be the inverse color of the background color
  final Color? foregroundColor;

  ///Scroll physics of [MediaPreviewPageView]
  ///
  ///Default is [BouncingScrollPhysics]
  final ScrollPhysics physics;

  /// Define the action when touching the media
  ///
  /// Default is [TouchMediaAction.none]
  final TouchMediaAction touchAction;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (mediaController) => Obx(
        () => controller.mediaList.isEmpty
            ? emptyBuilder?.call(context) ?? const Text('Empty')
            : MediaView(
                controller: controller,
                physics: physics,
                touchAction: touchAction,
              ),
      ),
    );
  }
}

class MediaView extends StatelessWidget {
  const MediaView({
    super.key,
    required this.controller,
    required this.physics,
    required this.touchAction,
    this.foregroundColor,
    this.onSlidePageHandler,
  });

  final MediaPreviewController controller;
  final Color? foregroundColor;
  final ScrollPhysics physics;
  final TouchMediaAction touchAction;
  final Color Function(Offset offset, Size pageSize)? onSlidePageHandler;

  void onMediaTapHandler() {
    switch (touchAction) {
      case TouchMediaAction.playPause:
        controller.playPauseVideo();
        break;
      case TouchMediaAction.muteUnMute:
        controller.muteUnMute();
        break;
      case TouchMediaAction.toggleHideOverlayUI:
        controller.toggleShowOverlayUI();
        break;
      case TouchMediaAction.toggleHideStatusBarAndOverlayUI:
        controller.toggleShowOverlayUI(isToggleStatusBar: true);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: foregroundColor),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: Obx(
          () {
            final child = GestureDetector(
              onTap: touchAction == TouchMediaAction.none
                  ? null
                  : onMediaTapHandler,
              child: ExtendedImageGesturePageView.builder(
                physics: physics,
                controller: controller.pageController,
                itemCount: controller.mediaList.length,
                preloadPagesCount: 4,
                onPageChanged: (index) => controller.onItemPageChanged(index),
                itemBuilder: (BuildContext context, int index) {
                  final data = controller.mediaList[index];
                  late final Widget media;

                  if (data.type.isVideo) {
                    media = _VideoPreviewItem(
                      index: index,
                      previewData: data,
                      controller: controller,
                    );
                  } else {
                    media = _ImagePreviewItem(
                      previewData: data,
                      controller: controller,
                    );
                  }
                  return Obx(
                    () => ExtendedImageSlidePageHandler(
                      heroBuilderForSlidingPage:
                          controller.currentItemIndex.value == index &&
                                  data.heroTag != null
                              ? (widget) =>
                                  Hero(tag: data.heroTag, child: widget)
                              : null,
                      child: media,
                    ),
                  );
                },
              ),
            );

            if (controller.mediaList
                .any((element) => element.heroTag != null)) {
              return ExtendedImageSlidePage(
                slideAxis: SlideAxis.vertical,
                slideType: SlideType.onlyImage,
                // onSlidingPage: controller.onSlidingPage,
                slidePageBackgroundHandler:
                    (onSlidePageHandler != null) ? onSlidePageHandler! : null,
                child: child,
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}

class _ImagePreviewItem extends StatelessWidget {
  _ImagePreviewItem({required this.previewData, required this.controller})
      : assert(previewData.type.isImage, 'Preview data must be image');

  final MediaPreviewData previewData;
  final MediaPreviewController controller;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      fit: BoxFit.contain,
      image: previewData.getImageProvider(),
      handleLoadingProgress: true,
      mode: ExtendedImageMode.gesture,
      enableSlideOutPage: true,
      onDoubleTap: controller.onImageDoubleTapHandler,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.completed) {
          return null;
        }
        if (state.extendedImageLoadState == LoadState.failed) {
          return const PreviewError();
        }
        return const DefaultLoadingIndicator();
      },
      initGestureConfigHandler: (state) => controller.defaultGestureConfig,
    );
  }
}

class _VideoPreviewItem extends StatelessWidget {
  _VideoPreviewItem({
    required this.index,
    required this.previewData,
    required this.controller,
  }) : assert(previewData.type.isVideo, 'Preview data must be video');

  final int index;
  final MediaPreviewData previewData;
  final MediaPreviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: VideoThumbnailPreview(
                previewData: previewData,
                stateBuilder: (state) {
                  if (state.loadingStatus.isError &&
                      controller.videoInitializeState.value.isError) {
                    return const SizedBox.shrink();
                  }
                  return null;
                },
              ),
            ),
            if (controller.videoInitializeState.value.isLoading &&
                controller.videoIndex.value == index)
              const DefaultLoadingIndicator()
            else if (controller.videoInitializeState.value.isError &&
                controller.videoIndex.value == index)
              const PreviewError(message: 'Có lỗi xảy ra khi phát video')
            else if (controller.videoInitializeState.value.isSuccess &&
                controller.videoIndex.value == index &&
                controller.videoPlayerController != null)
              Center(
                child: AspectRatio(
                  aspectRatio:
                      controller.videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(
                    controller.videoPlayerController!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
