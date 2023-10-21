import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:vif_previewer/core/utils/extensions/media_preview_data_ext.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_controller.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';

class ImagePreviewItem extends StatelessWidget {
  ImagePreviewItem({
    super.key,
    required this.previewData,
    required this.controller,
    this.inPageView = true,
    this.useGesture = true,
    this.fit = BoxFit.contain,
  }) : assert(previewData.type.isImage, 'Preview data must be image');

  final MediaPreviewData previewData;
  final MediaPreviewController controller;
  final bool inPageView;
  final bool useGesture;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      fit: fit,
      image: previewData.getImageProvider(),
      handleLoadingProgress: true,
      mode: useGesture ? ExtendedImageMode.gesture : ExtendedImageMode.none,
      enableSlideOutPage: inPageView,
      onDoubleTap: useGesture ? controller.onImageDoubleTapHandler : null,
      initGestureConfigHandler:
          useGesture ? (state) => controller.defaultGestureConfig : null,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.completed) {
          return null;
        }
        if (state.extendedImageLoadState == LoadState.failed) {
          return const PreviewError(
            color: Colors.white,
          );
        }
        return const Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      },
    );
  }
}
