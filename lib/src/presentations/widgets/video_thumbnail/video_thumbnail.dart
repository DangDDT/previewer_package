import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/presentations/widgets/default_loading_indicator.dart';
import 'package:vif_previewer/src/presentations/widgets/preview_error.dart';
import 'package:vif_previewer/src/presentations/widgets/video_thumbnail/video_thumbnail_controller.dart';

class VideoThumbnailPreview extends StatelessWidget {
  VideoThumbnailPreview({
    super.key,
    this.color,
    required this.previewData,
    this.stateBuilder,
    this.boxFit = BoxFit.contain,
    this.height,
    this.width,
  }) : assert(previewData.type.isVideo, 'Preview data must be video');

  /// The color of text, progress indicator and icon.
  final Color? color;

  /// The data of the preview.
  ///
  /// This data will be used to generate the preview.
  final MediaPreviewData previewData;

  /// This function will be called when the state of the preview changes.
  ///
  /// If this function is null, the default state builder will be used.
  ///
  /// IF return null default state builder will be used.
  final Widget? Function(VideoThumbnailState state)? stateBuilder;

  final BoxFit boxFit;

  /// The height of the preview.
  final double? height;

  /// The width of the preview.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final tag = previewData.hashCode.toString();
    Get.put(VideoThumbnailController(previewData: previewData), tag: tag);
    return GetBuilder<VideoThumbnailController>(
      tag: tag,
      builder: (controller) {
        return Obx(() {
          if (controller.loadingStatus.value == LoadingStatus.loading) {
            final loadingWidget = stateBuilder?.call(
              const VideoThumbnailState(
                loadingStatus: LoadingStatus.loading,
                videoThumbnail: null,
              ),
            );
            return loadingWidget ?? const DefaultLoadingIndicator();
          }
          if (controller.loadingStatus.value == LoadingStatus.error ||
              controller.videoThumbnail.value == null) {
            final errorWidget = stateBuilder?.call(
              const VideoThumbnailState(
                loadingStatus: LoadingStatus.error,
                videoThumbnail: null,
              ),
            );
            return FittedBox(
              child: errorWidget ??
                  PreviewError(
                    color: color,
                    height: height ?? 150,
                    width: width ?? 150,
                  ),
            );
          }

          final thumbnailWidget = stateBuilder?.call(
            const VideoThumbnailState(
              loadingStatus: LoadingStatus.success,
              videoThumbnail: null,
            ),
          );

          return thumbnailWidget ??
              ExtendedImage.memory(
                controller.videoThumbnail.value!,
                fit: boxFit,
                height: height,
                width: width,
              );
        });
      },
    );
  }
}

class VideoThumbnailState {
  const VideoThumbnailState({
    this.loadingStatus = LoadingStatus.loading,
    this.videoThumbnail,
  });

  final LoadingStatus loadingStatus;
  final Uint8List? videoThumbnail;
}
