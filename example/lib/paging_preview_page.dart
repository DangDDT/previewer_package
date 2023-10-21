import 'package:flutter/material.dart';
import 'package:vif_previewer/previewer.dart';

class PagingPreviewPage extends StatefulWidget {
  const PagingPreviewPage({
    super.key,
    required this.testMedias,
  });

  final List<MediaPreviewData> testMedias;

  @override
  State<PagingPreviewPage> createState() => _PagingPreviewPageState();
}

class _PagingPreviewPageState extends State<PagingPreviewPage> {
  final _listData = <MediaPreviewData>[];
  int requestCount = 0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    if (mounted) {
      setState(() {
        _listData.addAll(widget.testMedias.take(5));
      });
    }
    super.initState();
  }

  void onTap(int index) {
    VIFPreviewer.previewMedias(
      mediaList: _listData,
      initialIndex: index,
      onScrollToItem: _onScrollToItem,
      pagingConfig: MediaPagingConfig(
        pageSize: 5,
        nextPageThreshold: 3,
        fetchPage: _onFetchPage,
      ),
    );
  }

  Future<List<MediaPreviewData>> _onFetchPage(int pageIndex) {
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        //Check is last page
        if (pageIndex * 5 >= widget.testMedias.length) {
          return [];
        }
        final list = widget.testMedias.skip(pageIndex * 5).take(5).toList();
        setState(() {
          _listData.addAll(list);
        });
        return list;
      },
    );
  }

  void _onScrollToItem(int index, MediaPreviewData item) {
    _scrollController.animateTo(
      index * 250,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Preview Page'),
      ),
      body: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: _listData.length,
        itemBuilder: (context, index) {
          late final Widget child;
          final media = _listData[index];
          if (media.type.isVideo) {
            child = Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: VideoThumbnailPreview(
                    previewData: media,
                    boxFit: BoxFit.cover,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            );
          } else {
            child = Image.network(media.data, fit: BoxFit.contain);
          }
          return GestureDetector(
            onTap: () => onTap(index),
            child: media.heroTag != null
                ? Hero(
                    tag: media.heroTag,
                    child: SizedBox(
                      child: child,
                    ),
                  )
                : child,
          );
        },
      ),
    );
  }
}
