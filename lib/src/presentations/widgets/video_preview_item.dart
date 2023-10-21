import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_controller.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';
import 'package:vif_previewer/src/presentations/widgets/video_thumbnail/video_thumbnail.dart';

class VideoPreviewItem extends StatelessWidget {
  VideoPreviewItem({
    super.key,
    required this.index,
    required this.previewData,
    required this.controller,
    this.fit = BoxFit.contain,
  }) : assert(previewData.type.isVideo, 'Preview data must be video');

  final int index;
  final MediaPreviewData previewData;
  final MediaPreviewController controller;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: VideoThumbnailPreview(
                boxFit: fit,
                previewData: previewData,
                color: Colors.white,
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
              const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
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
              )
            else if (controller.videoInitializeState.value.isError &&
                controller.videoIndex.value == index)
              const PreviewError(
                color: Colors.white,
                message: 'Có lỗi xảy ra khi phát video',
              ),
          ],
        );
      },
    );
  }
}
