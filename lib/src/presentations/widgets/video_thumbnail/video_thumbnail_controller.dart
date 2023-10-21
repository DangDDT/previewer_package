// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/core/utils/extensions/media_preview_data_ext.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';

class VideoThumbnailController extends GetxController {
  VideoThumbnailController({
    required this.previewData,
  });

  final MediaPreviewData previewData;

  final Rxn<Uint8List> videoThumbnail = Rxn();
  final Rx<LoadingStatus> loadingStatus = LoadingStatus.loading.obs;

  Future<void> loadThumbnail() async {
    try {
      videoThumbnail.value = await previewData.getVideoThumbnail();
      loadingStatus.value = LoadingStatus.success;
    } catch (e) {
      loadingStatus.value = LoadingStatus.error;
    }
  }

  @override
  void onInit() {
    loadThumbnail();
    super.onInit();
  }
}
