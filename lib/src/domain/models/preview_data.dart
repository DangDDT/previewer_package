// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:vif_previewer/core/enums/public_enum.dart';

abstract class MediaPreviewData<T> {
  /// Media data to preview
  ///
  /// Don't use this property directly, use factory methods instead
  ///
  /// Example:
  /// ```dart
  /// final previewData = MediaPreviewData.fromAsset(
  ///   assetName: 'assets/images/image.jpg',
  ///   type: MediaType.image,
  /// );
  /// ```
  const MediaPreviewData({
    required this.data,
    required this.type,
    this.heroTag,
  });

  static MediaPreviewData<String> fromAsset({
    required String assetName,
    required MediaType type,
    dynamic heroTag,
  }) {
    return AssetMediaPreviewData(
      data: assetName,
      type: type,
      heroTag: heroTag,
    );
  }

  static MediaPreviewData<String> fromNetwork({
    required String url,
    required MediaType type,
    dynamic heroTag,
  }) {
    return NetworkMediaPreviewData(
      data: url,
      type: type,
      heroTag: heroTag,
    );
  }

  static MediaPreviewData<File> fromFile({
    required File file,
    required MediaType type,
    dynamic heroTag,
  }) {
    return FileMediaPreviewData(
      data: file,
      type: type,
      heroTag: heroTag,
    );
  }

  static MediaPreviewData<Uint8List> fromBytes({
    required Uint8List bytes,
    required MediaType type,
    dynamic heroTag,
  }) {
    return MemoryMediaPreviewData(
      data: bytes,
      type: type,
      heroTag: heroTag,
    );
  }

  final T data;
  final MediaType type;
  final dynamic heroTag;

  @override
  bool operator ==(covariant MediaPreviewData other) {
    if (identical(this, other)) return true;
    return other.data == data && other.type == type && other.heroTag == heroTag;
  }

  @override
  int get hashCode => data.hashCode ^ type.hashCode ^ heroTag.hashCode;
}

class AssetMediaPreviewData extends MediaPreviewData<String> {
  const AssetMediaPreviewData({
    required String data,
    required MediaType type,
    dynamic heroTag,
  }) : super(
          data: data,
          type: type,
          heroTag: heroTag,
        );
}

class NetworkMediaPreviewData extends MediaPreviewData<String> {
  const NetworkMediaPreviewData({
    required String data,
    required MediaType type,
    dynamic heroTag,
  }) : super(
          data: data,
          type: type,
          heroTag: heroTag,
        );
}

class FileMediaPreviewData extends MediaPreviewData<File> {
  const FileMediaPreviewData({
    required File data,
    required MediaType type,
    dynamic heroTag,
  }) : super(
          data: data,
          type: type,
          heroTag: heroTag,
        );
}

class MemoryMediaPreviewData extends MediaPreviewData<Uint8List> {
  const MemoryMediaPreviewData({
    required Uint8List data,
    required MediaType type,
    dynamic heroTag,
  }) : super(
          data: data,
          type: type,
          heroTag: heroTag,
        );
}
