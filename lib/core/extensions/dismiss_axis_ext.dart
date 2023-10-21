import 'package:vif_previewer/core/enums/public_enum.dart';

extension DismissAxisX on DismissAxis {
  /// Returns `true` if the axis is horizontal only
  ///
  /// This is `false` if the axis is all or vertical.
  bool get isXAxis {
    return this == DismissAxis.endToStart ||
        this == DismissAxis.startToEnd ||
        this == DismissAxis.horizontal;
  }

  /// Returns `true` if the axis is vertical only
  ///
  /// This is `false` if the axis is all or horizontal.
  bool get isYAxis {
    return this == DismissAxis.up ||
        this == DismissAxis.down ||
        this == DismissAxis.vertical;
  }
}
