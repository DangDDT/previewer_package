import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/previewer.dart';

class SlidingController extends GetxController {
  SlidingController({
    MediaPreviewController? mediaPreviewController,
  }) : _mediaPreviewController = mediaPreviewController ?? Get.find();

  final MediaPreviewController _mediaPreviewController;

  Timer? _autoHideOverlayDebounce;

  //Media page variables
  /// Overlay / background opacity
  ///
  /// This value changes when user slides the page up/down
  final RxDouble opacity = 1.0.obs;

  /// Show/Hide overlay
  ///
  /// This value changes when user taps on the screen
  final RxBool isShowOverlayUI = true.obs;

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  void _showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _autoHideOverlayUI() {
    if (!_mediaPreviewController.videoPlayConfig.autoHide) return;

    _autoHideOverlayDebounce?.cancel();
    _autoHideOverlayDebounce =
        Timer(_mediaPreviewController.videoPlayConfig.autoHideDuration, () {
      if (!isShowOverlayUI.value ||
          !_mediaPreviewController.isVideoPlaying.value) return;
      isShowOverlayUI.value = false;
    });
  }

  Offset? onSlideOffsetHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
  }) {
    if (offset.dy < 0) {
      return Offset.zero;
    }
    return offset;
  }

  double? onSlideScaleHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
  }) {
    double scale = 1.0;
    if (state == null) return scale;
    scale = offset.dy.abs() / (state.pageSize.height / 2.0);

    return max(1.0 - scale, 0.8);
  }

  /// Toggle show/hide overlay UI
  ///
  /// If [isShow] is not provided, it will toggle the current value
  void toggleShowOverlayUI({bool? isShow, bool isToggleStatusBar = false}) {
    isShowOverlayUI.value = isShow ?? !isShowOverlayUI.value;

    if (isToggleStatusBar) {
      if (isShowOverlayUI.value) {
        _showStatusBar();
      } else {
        _hideStatusBar();
      }
    }

    if (isShowOverlayUI.value && _mediaPreviewController.isVideoPlaying.value) {
      _autoHideOverlayUI();
    }
  }

  ///DO NOT call this method directly
  void onSlidingPage(ExtendedImageSlidePageState state) {
    if (state.isSliding) {
      isShowOverlayUI.value = false;
    } else {
      isShowOverlayUI.value = true;
    }
  }

  ///DO NOT call this method directly
  Color slidePageBackgroundHandler(Offset offset, Size pageSize) {
    const backGroundColor = Colors.black;
    double dyOffset = offset.dy;
    if (dyOffset != 0) {
      opacity.value = 1 - (dyOffset.abs() / pageSize.height);
      return backGroundColor.withOpacity(opacity.value);
    }
    return backGroundColor;
  }
}
