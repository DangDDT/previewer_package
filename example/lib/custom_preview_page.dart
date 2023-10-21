import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:vif_previewer/previewer.dart';

class CustomPreviewPage extends StatelessWidget {
  const CustomPreviewPage({super.key});

  Future<List<MediaPreviewData>> _onFetchPage(int pageIndex) {
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        print('TEST: fetch page $pageIndex');
        //Check is last page
        if (pageIndex * 5 >= testMedias.length) {
          return [];
        }
        final list = testMedias.skip(pageIndex * 5).take(5).toList();

        return list;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = MediaPreviewController.paging(
      initialMediaList: testMedias.take(5).toList(),
      videoPlayConfig: const VideoPlayConfig(
        autoPlay: false,
      ),
      pagingConfig: MediaPagingConfig(
        pageSize: 5,
        nextPageThreshold: 3,
        fetchPage: _onFetchPage,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Preview Page'),
      ),
      body: Column(
        children: [
          const Text('This is a custom preview page'),
          ColoredBox(
            color: Colors.green,
            child: SizedBox(
              height: 400,
              child: MediaPreviewPageView(
                controller: controller,
              ),
            ),
          ),
          ColoredBox(
            color: Colors.green,
            child: VideoControlUI(
              controller: controller,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
