// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vif_previewer/previewer.dart';
import 'package:vif_previewer/src/presentations/widgets/image_preview_item.dart';

class MediaBottomThumbnail extends StatefulWidget {
  const MediaBottomThumbnail({
    super.key,
    required this.controller,
    this.itemHeight,
    this.itemMinHeight = 60,
    this.itemMaxHeight = 100,
  });

  final MediaPreviewController controller;

  /// The height of the item in the carousel.
  ///
  /// If null, the height will be calculated based on the width of the screen * 0.2
  final double? itemHeight;

  final double itemMinHeight;

  final double itemMaxHeight;

  @override
  State<MediaBottomThumbnail> createState() => _MediaBottomThumbnailState();
}

class _MediaBottomThumbnailState extends State<MediaBottomThumbnail> {
  late final CarouselController _carouselController;

  late double _itemHeight;
  int _currentIndex = 0;

  StreamSubscription? _indexChangeSubscription;

  void calculateItemSize() {
    _itemHeight = (widget.itemHeight ?? Get.width * .2).clamp(
      widget.itemMinHeight,
      widget.itemMaxHeight,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    calculateItemSize();
    _carouselController = CarouselController();
    _indexChangeSubscription =
        widget.controller.currentItemIndex.listen((newIndex) {
      if (newIndex == _currentIndex) return;
      _carouselController.animateToPage(newIndex);
      _currentIndex = newIndex;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(MediaBottomThumbnail oldWidget) {
    if (oldWidget.itemHeight != widget.itemHeight ||
        oldWidget.itemMinHeight != widget.itemMinHeight ||
        oldWidget.itemMaxHeight != widget.itemMaxHeight) {
      calculateItemSize();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _indexChangeSubscription?.cancel();
    super.dispose();
  }

  void _onCarouselPageChanged(int index, CarouselPageChangedReason reason) {
    if (reason == CarouselPageChangedReason.controller) return;
    _currentIndex = index;
    widget.controller.onItemPageChanged(
      index,
      fromMainPage: false,
    );
  }

  void _onItemTap(int index) {
    _currentIndex = index;
    _carouselController.animateToPage(index);
    widget.controller.onItemPageChanged(
      index,
      fromMainPage: false,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      widget.controller.toggleIsScrolling(true);
    } else if (notification is ScrollEndNotification) {
      widget.controller.toggleIsScrolling(false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight,
      child: Obx(
        () => NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: widget.controller.mediaList.length,
            options: CarouselOptions(
              initialPage: widget.controller.currentItemIndex.value,
              height: _itemHeight,
              viewportFraction: 0.12,
              enableInfiniteScroll: false,
              onPageChanged: _onCarouselPageChanged,
            ),
            itemBuilder: (context, index, realIndex) {
              return Obx(
                () => _MediaThumbnail(
                  controller: widget.controller,
                  index: index,
                  isSelected: widget.controller.currentItemIndex.value == index,
                  onTap: () => _onItemTap(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({
    Key? key,
    required this.controller,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final MediaPreviewController controller;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewData = controller.mediaList[index];

    late final Widget thumbnail;
    if (previewData.type.isImage) {
      thumbnail = ImagePreviewItem(
        previewData: previewData,
        controller: controller,
        inPageView: false,
        useGesture: false,
        fit: BoxFit.cover,
      );
    } else {
      thumbnail = VideoThumbnailPreview(
        previewData: previewData,
        boxFit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 1,
          ),
        ),
        // padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: thumbnail,
        ),
      ),
    );
  }
}
