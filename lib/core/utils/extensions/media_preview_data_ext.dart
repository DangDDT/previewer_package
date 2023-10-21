import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vif_previewer/core/constrains/constrains.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

extension MediaPreviewDataX on MediaPreviewData {
  bool get isFromAsset => this is AssetMediaPreviewData;
  bool get isFromNetwork => this is NetworkMediaPreviewData;
  bool get isFromMemory => this is MemoryMediaPreviewData;
  bool get isFromFilePath => this is FileMediaPreviewData;

  ///Only for image
  ///
  ///Return [ImageProvider] from [MediaPreviewData]
  ///
  ///If [MediaPreviewData] is video, throw [UnsupportedError]
  ImageProvider getImageProvider() {
    if (type.isVideo) throw UnsupportedError('This method is only for image');

    switch (runtimeType) {
      case AssetMediaPreviewData:
        return AssetImage((this as AssetMediaPreviewData).data);

      case NetworkMediaPreviewData:
        return NetworkImage((this as NetworkMediaPreviewData).data);

      case MemoryMediaPreviewData:
        return MemoryImage((this as MemoryMediaPreviewData).data);

      case FileMediaPreviewData:
        return FileImage((this as FileMediaPreviewData).data);
    }
    throw UnsupportedError('MediaPreviewData type is not supported');
  }

  ///Only for video, get video thumbnail
  Future<Uint8List?> getVideoThumbnail() async {
    Uint8List? thumbnail;
    switch (runtimeType) {
      case AssetMediaPreviewData:
        final asset = (this as AssetMediaPreviewData);
        final tempVideo = await asset.getFile();
        thumbnail = await VideoThumbnail.thumbnailData(
          video: tempVideo.path,
          imageFormat: ImageFormat.PNG,
          quality: 10,
          timeMs: kVideoThumbMs,
        );
        break;

      case NetworkMediaPreviewData:
        thumbnail = await VideoThumbnail.thumbnailData(
          video: (this as NetworkMediaPreviewData).data,
          imageFormat: ImageFormat.PNG,
          quality: 10,
          timeMs: kVideoThumbMs,
        );
        break;

      case MemoryMediaPreviewData:
        final file = await (this as MemoryMediaPreviewData).getFile();
        thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          quality: 10,
          timeMs: kVideoThumbMs,
        );
        break;

      case FileMediaPreviewData:
        thumbnail = await VideoThumbnail.thumbnailData(
          video: (this as FileMediaPreviewData).data.path,
          imageFormat: ImageFormat.PNG,
          quality: 10,
        );
        break;
    }

    return thumbnail;
  }

  Future<File> getFile() async {
    final String ext = type.isImage ? 'png' : 'mp4';
    String randomVideoName = DateTime.now().millisecondsSinceEpoch.toString();
    Directory tempDir = await getTemporaryDirectory();
    File tempVideo = File("${tempDir.path}/video/video_$randomVideoName.$ext");
    await tempVideo.create(recursive: true);
    return tempVideo.writeAsBytes(data);
  }
}
