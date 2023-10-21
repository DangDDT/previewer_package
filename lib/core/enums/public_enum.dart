enum MediaType {
  image,
  video;

  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;
}

enum DismissType {
  /// Item only
  ///
  /// Only dismiss the dismissible item where wrap with [DismissPageItemHandler]
  item,

  /// Whole page can be dismiss
  ///
  /// Every [DismissPageItemHandler] will be ignore
  wholePage,
}

enum DismissAxis {
  /// The [Dismissible] can be dismissed by dragging in any direction.
  all,

  /// The [Dismissible] can be dismissed by dragging either up or down.
  vertical,

  /// The [Dismissible] can be dismissed by dragging either left or right.
  horizontal,

  /// The [Dismissible] can be dismissed by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// The [Dismissible] can be dismissed by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// The [Dismissible] can be dismissed by dragging up only.
  up,

  /// The [Dismissible] can be dismissed by dragging down only.
  down,

  /// The [Dismissible] cannot be dismissed by dragging.
  none
}

enum TouchMediaAction {
  /// Do nothing
  none,

  /// Play/Pause video
  playPause,

  /// Mute/Un mute video
  muteUnMute,

  /// Toggle hide/show overlay UI
  toggleHideOverlayUI,

  /// Toggle hide/show status bar and overlay UI
  toggleHideStatusBarAndOverlayUI;
}
