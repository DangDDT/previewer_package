import 'package:get/get.dart';
import 'package:vif_previewer/core/router/arguments/media_preview_page_arguments.dart';
import 'package:vif_previewer/core/typedef.dart';
import 'package:vif_previewer/src/domain/models/paging_config.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/domain/models/video_play_config.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_page/media_preview_page.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_controller.dart';

class VIFPreviewer {
  /// Preview a list of media items
  ///
  /// - [mediaList] list of media items to preview
  /// - [initialIndex] initial index of the media list
  /// - [videoPlayConfig] config for video player
  /// - [pagingConfig] config for paging media items. If null, paging will be disabled
  static Future<void> previewMedias({
    required List<MediaPreviewData> mediaList,
    int initialIndex = 0,
    OnScrollToItem<MediaPreviewData>? onScrollToItem,
    VideoPlayConfig videoPlayConfig = VideoPlayConfig.defaultConfig,
    MediaPagingConfig? pagingConfig,
  }) async {
    Get.to(
      () => const MediaPreviewPage(),
      arguments: <String, dynamic>{
        MediaPreviewPageArguments.medias: mediaList,
        MediaPreviewPageArguments.initialIndex: initialIndex,
        MediaPreviewPageArguments.videoPlayConfig: videoPlayConfig,
      },
      binding: BindingsBuilder(() {
        final controller = pagingConfig != null
            ? MediaPreviewController.paging(
                initialMediaList: mediaList,
                onScrollToItem: onScrollToItem,
                pagingConfig: pagingConfig,
                initialIndex: initialIndex,
                videoPlayConfig: videoPlayConfig,
              )
            : MediaPreviewController(
                data: mediaList,
                onScrollToItem: onScrollToItem,
                initialIndex: initialIndex,
                videoPlayConfig: videoPlayConfig,
              );
        Get.put(controller);
      }),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 210),
      opaque: false,
    );
  }
}
