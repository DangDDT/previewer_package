import 'package:vif_previewer/src/domain/models/preview_data.dart';

class MediaPagingConfig {
  /// Creates a new [MediaPagingConfig] instance to be used with [vif_previewer.previewMedias]
  ///
  /// Config for paging media items
  MediaPagingConfig({
    this.pageSize = 10,
    this.firstPageIndex = 0,
    this.nextPageThreshold = 4,
    required this.fetchPage,
  })  : assert(pageSize > 0, 'pageSize must be greater than 0'),
        assert(
            firstPageIndex >= 0, 'initialPage must be greater than or equal 0'),
        assert(
            nextPageThreshold > 0, 'nextPageThreshold must be greater than 0'),
        assert(nextPageThreshold < pageSize,
            'nextPageThreshold must be less than pageSize');

  /// The number of items to request per page
  final int pageSize;

  /// The initial page to request
  final int firstPageIndex;

  /// The number of items left in the list before the end of the list is reached
  final int nextPageThreshold;

  /// A function that fetches a page of items, receiving the page index and page size as parameters
  final Future<List<MediaPreviewData>> Function(int index) fetchPage;
}
