import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';

extension AssetPreviewDataX on AssetMediaPreviewData {
  Future<File> getFile() async {
    final byteData = await rootBundle.load(data);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File("${tempDir.path}/$data")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return tempFile;
  }
}
