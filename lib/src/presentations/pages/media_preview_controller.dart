import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vif_previewer/core/enums/private_enum.dart';
import 'package:vif_previewer/core/typedef.dart';
import 'package:vif_previewer/core/utils/extensions/media_preview_data_ext.dart';
import 'package:vif_previewer/core/utils/helpers/debounce_helper.dart';
import 'package:vif_previewer/src/domain/models/paging_config.dart';
import 'package:vif_previewer/src/domain/models/preview_data.dart';
import 'package:vif_previewer/src/domain/models/video_play_config.dart';
import 'package:video_player/video_player.dart';
import 'package:vif_previewer/src/presentations/pages/media_preview_page/sliding_controller.dart';

class MediaPreviewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MediaPreviewController({
    required List<MediaPreviewData> data,
    int initialIndex = 0,
    this.videoPlayConfig = VideoPlayConfig.defaultConfig,
    this.onScrollToItem,
  }) : _pagingConfig = null {
    currentItemIndex.value = initialIndex;
    pageController = ExtendedPageController(
      initialPage: initialIndex,
      keepPage: true,
      pageSpacing: 8,
    );
    isMuted.value = videoPlayConfig.muteOnStart;
    isVideoPlaying.value = videoPlayConfig.autoPlay;

    if (data.isNotEmpty) {
      mediaList.addAll(data);
      _checkAndSetupVideoController();
    }
  }

  MediaPreviewController.paging({
    required List<MediaPreviewData> initialMediaList,
    required MediaPagingConfig pagingConfig,
    int initialIndex = 0,
    this.onScrollToItem,
    this.videoPlayConfig = VideoPlayConfig.defaultConfig,
  }) : _pagingConfig = pagingConfig {
    currentItemIndex.value = initialIndex;
    pageController = ExtendedPageController(
      initialPage: initialIndex,
      keepPage: true,
      pageSpacing: 8,
    );

    isMuted.value = videoPlayConfig.muteOnStart;
    isVideoPlaying.value = videoPlayConfig.autoPlay;

    final lastPageLength = initialMediaList.length %
        _pagingConfig!.pageSize; // 0 if last page is full

    _isLastPage = lastPageLength != 0;

    _currentPageKey = (currentItemIndex / _pagingConfig!.pageSize).floor() +
        _pagingConfig!.firstPageIndex;
    if (!_isLastPage) {
      _nextPageKey = _currentPageKey + 1;
    }

    if (initialMediaList.isNotEmpty) {
      mediaList.addAll(initialMediaList);
      _checkAndSetupVideoController();
      _requestNewPage();
    }
  }

  //View handlers
  final OnScrollToItem<MediaPreviewData>? onScrollToItem;

  //Image zoom animation variables
  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  static const mediaMinScale = 1.0;
  static const mediaMaxScale = 4.0;
  final GestureConfig defaultGestureConfig = GestureConfig(
    minScale: mediaMinScale,
    maxScale: mediaMaxScale,
    speed: 1.0,
    initialScale: mediaMinScale,
    inertialSpeed: 100.0,
    inPageView: true,
    initialAlignment: InitialAlignment.center,
  );

  //Video variables
  final videoIndex = RxnInt();
  double _updateProgressInterval = 0.0;
  final VideoPlayConfig videoPlayConfig;
  VideoPlayerController? videoPlayerController;
  final videoInitializeState = Rx<LoadingStatus>(LoadingStatus.loading);
  final isVideoPlaying = false.obs;
  final videoPosition = Rxn<Duration>();
  final videoDuration = Rxn<Duration>();
  final videoProgress = 0.0.obs;
  final isDraggingProgressBar = false.obs;
  final isMuted = true.obs;

  //Paging variables
  final _fetchPageStatus = Rx<LoadingStatus>(LoadingStatus.idle);
  bool _isLastPage = false;
  int? _nextPageKey;
  int _currentPageKey = 0;

  /// Config for paging media items. If null, paging will be disabled
  final MediaPagingConfig? _pagingConfig;

  late ExtendedPageController pageController;

  late final SlidingController _slidingController;

  RxBool get isShowOverlayUI => _slidingController.isShowOverlayUI;

  /// Current item index
  final RxInt currentItemIndex = 0.obs;

  /// List of media items
  final RxList<MediaPreviewData> mediaList = <MediaPreviewData>[].obs;

  ///This value use to stop init video controller when user is scrolling
  bool _isScrolling = false;

  ///DO NOT call this method directly in your code
  ///
  ///This is a helper method for Bottom Thumbnails
  void toggleIsScrolling(bool value) {
    _isScrolling = value;
    if (value && videoPlayerController != null) {
      videoInitializeState.value = LoadingStatus.idle;
      videoPlayerController?.pause();
      videoPlayerController?.removeListener(_onVideoControllerUpdate);
      videoPlayerController = null;
    }
  }

  @override
  void onInit() {
    _slidingController = Get.put(SlidingController(
      mediaPreviewController: this,
    ));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initZoomAnimationValues();
    super.onInit();
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    super.onClose();
  }

  void _initZoomAnimationValues() {
    _doubleClickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  void toggleShowOverlayUI({bool? isShow, bool isToggleStatusBar = false}) =>
      _slidingController.toggleShowOverlayUI(
        isShow: isShow,
        isToggleStatusBar: isToggleStatusBar,
      );

  /// This method will be call when item page changed
  ///
  /// DO NOT call this method directly
  ///
  /// - [index] is the index of the new item
  /// - [fromMainPage] is true if the page is changed from the main page (Page view).
  /// If this value is false, the main page will not be updated based on the new index.
  void onItemPageChanged(int index, {bool fromMainPage = true}) {
    currentItemIndex.value = index;
    final currentItem = mediaList[currentItemIndex.value];

    if (_pagingConfig != null) _requestNewPage();
    onScrollToItem?.call(index, currentItem);

    Future.delayed(const Duration(milliseconds: 100), () {
      DebounceHelpers.waitUntil(
        () async => !_isScrolling && currentItemIndex.value == index,
        () => _checkAndSetupVideoController(),
        stopWhen: () async => currentItemIndex.value != index,
      );
    });

    if (!fromMainPage) {
      pageController.jumpToPage(index);
    }
  }

  Future<void> _requestNewPage() async {
    if (_isLastPage ||
        _nextPageKey == null ||
        _fetchPageStatus.value.isLoading) {
      return;
    }

    final numOfRemainingItems = mediaList.length - (currentItemIndex.value + 1);

    if (numOfRemainingItems > _pagingConfig!.nextPageThreshold) return;

    try {
      _fetchPageStatus.value = LoadingStatus.loading;

      final items = await _pagingConfig!.fetchPage(_nextPageKey!);

      final isLastPage = items.length < _pagingConfig!.pageSize;
      if (_nextPageKey != null) _currentPageKey = _nextPageKey!;

      if (isLastPage) {
        _appendLastPage(items);
      } else {
        final nextPageKey = _currentPageKey + 1;
        _appendNextPage(items, nextPageKey);
      }
      _fetchPageStatus.value = LoadingStatus.success;
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      _fetchPageStatus.value = LoadingStatus.error;
    }
  }

  void _appendNextPage(List<MediaPreviewData> items, int nextPageKey) {
    mediaList.addAll(items);
    _isLastPage = false;
    _nextPageKey = nextPageKey;
  }

  void _appendLastPage(List<MediaPreviewData> items) {
    mediaList.addAll(items);
    _isLastPage = true;
    _nextPageKey = null;
  }

  Future<void> _checkAndSetupVideoController() async {
    isVideoPlaying.value = false;
    videoInitializeState.value = LoadingStatus.idle;
    videoDuration.value = null;
    videoPosition.value = null;

    final oldController = videoPlayerController;

    videoPlayerController?.removeListener(_onVideoControllerUpdate);
    videoPlayerController?.pause();

    final media = mediaList[currentItemIndex.value];

    if (media.type.isImage) {
      videoPlayerController = null;
      return;
    }

    videoPlayerController = null;

    videoInitializeState.value = LoadingStatus.loading;
    late final VideoPlayerController newController;

    if (media is AssetMediaPreviewData) {
      newController = VideoPlayerController.asset(media.data);
    } else if (media is NetworkMediaPreviewData) {
      newController = VideoPlayerController.networkUrl(Uri.parse(media.data));
    } else if (media is FileMediaPreviewData) {
      newController = VideoPlayerController.file(media.data);
    } else if (media is MemoryMediaPreviewData) {
      final file = await media.getFile();
      newController = VideoPlayerController.file(file);
    } else {
      throw Exception('Media type not supported');
    }

    videoPlayerController = newController;
    videoIndex.value = currentItemIndex.value;
    oldController?.dispose();

    videoPlayerController
        ?.initialize()
        .then((_) => _onVideoControllerInitialized())
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
      videoInitializeState.value = LoadingStatus.error;
    });
  }

  void _onVideoControllerInitialized() {
    if (currentItemIndex.value != videoIndex.value) return;

    videoDuration.value = null;
    videoPosition.value = null;
    videoInitializeState.value = LoadingStatus.success;

    videoPlayerController?.addListener(_onVideoControllerUpdate);
    if (isMuted.value && videoPlayConfig.muteOnStart) {
      videoPlayerController?.setVolume(0);
    }
    if (videoPlayConfig.autoPlay) {
      videoPlayerController?.play();
      isVideoPlaying.value = true;
    }
  }

  void _onVideoControllerUpdate() async {
    if (isClosed || videoPlayerController == null) return;

    if (!videoPlayerController!.value.isInitialized) return;
    // Update video progress every 200ms
    // This is to prevent too many updates to the progress bar
    if (Platform.isAndroid) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_updateProgressInterval > now) {
        return;
      }
      _updateProgressInterval = now + 200.0;
    }

    videoDuration.value ??= videoPlayerController!.value.duration;

    var duration = videoDuration.value;

    var position = await videoPlayerController!.position;

    if (duration == null || position == null) return;

    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inMilliseconds + 500 >= duration.inMilliseconds;

    videoPosition.value = position;
    videoProgress.value = position.inMilliseconds.ceilToDouble() /
        duration.inMilliseconds.ceilToDouble();

    if (isEndOfClip) {
      isVideoPlaying.value = false;
      if (videoPlayConfig.looping) {
        videoPlayerController!.seekTo(Duration.zero);
        videoPlayerController!.play();
        isVideoPlaying.value = true;
      }
    }
  }

  /// Call this method when user tap on the screen
  void onSeekStart(double value) {
    videoPlayerController?.pause();
    isDraggingProgressBar.value = true;
  }

  /// Call this method when user stop dragging progress bar
  void onSeekEnd(double value) {
    isDraggingProgressBar.value = false;
    if (isVideoPlaying.value) videoPlayerController?.play();
  }

  /// Call this method when user drag progress bar
  void onVideoProgressChange(double value) {
    if (videoPlayerController == null) return;

    final duration = videoPlayerController!.value.duration;

    videoProgress.value = value * 0.01;
    var newValue = max(0, min(value, 99)) * 0.01;
    var milliseconds = (duration.inMilliseconds * newValue).toInt();

    videoPlayerController!.seekTo(Duration(milliseconds: milliseconds));
  }

  /// Rewind for a given duration
  ///
  /// If [duration] is not provided, it will rewind 10 seconds
  void rewindVideo({Duration? duration}) {
    if (videoPlayerController == null) return;

    final videoPosition = videoPlayerController!.value.position;

    final newPosition =
        videoPosition - (duration ?? const Duration(seconds: 10));

    if (newPosition < Duration.zero) {
      videoPlayerController!.seekTo(Duration.zero);
    } else {
      videoPlayerController!.seekTo(newPosition);
    }
  }

  void muteUnMute() {
    if (videoPlayerController == null) return;

    final videoMuted = videoPlayerController!.value.volume == 0;

    if (videoMuted) {
      videoPlayerController!.setVolume(1);
    } else {
      videoPlayerController!.setVolume(0);
    }

    isMuted.value = !isMuted.value;
  }

  /// Seek forward for a given duration.
  ///
  /// If [duration] is not provided, it will seek forward 10 seconds
  void forwardVideo({Duration? duration}) {
    if (videoPlayerController == null) return;

    final videoDuration = videoPlayerController!.value.duration;
    final videoPosition = videoPlayerController!.value.position;

    final newPosition =
        videoPosition + (duration ?? const Duration(seconds: 10));

    if (newPosition > videoDuration) {
      videoPlayerController!.seekTo(videoDuration);
    } else {
      videoPlayerController!.seekTo(newPosition);
    }
  }

  /// Toggle play/pause video player
  void playPauseVideo({bool? play}) {
    if (isVideoPlaying.value) {
      videoPlayerController?.pause();
      isVideoPlaying.value = false;
    } else {
      videoPlayerController?.play();
      isVideoPlaying.value = true;
    }
  }

  //DO NOT call this method directly
  void onImageDoubleTapHandler(ExtendedImageGestureState state) {
    final Offset? pointerDownPosition = state.pointerDownPosition;
    final double? begin = state.gestureDetails!.totalScale;
    double end;

    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

    _doubleClickAnimationController.stop();

    _doubleClickAnimationController.reset();

    if (begin == mediaMinScale) {
      end = mediaMaxScale;
    } else {
      end = mediaMinScale;
    }
    _doubleClickAnimationListener = () {
      state.handleDoubleTap(
        scale: _doubleClickAnimation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };
    _doubleClickAnimation = _doubleClickAnimationController
        .drive(Tween<double>(begin: begin, end: end))
      ..drive(CurveTween(curve: Curves.decelerate));

    _doubleClickAnimation!.addListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.forward();
  }
}
