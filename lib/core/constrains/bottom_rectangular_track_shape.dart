import 'package:flutter/material.dart';

class BottomRectangularSliderTrackShape extends RectangularSliderTrackShape {
  BottomRectangularSliderTrackShape({
    this.trackHeight = 8,
  });
  final double trackHeight;
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? this.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = parentBox.size.height - trackHeight;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
