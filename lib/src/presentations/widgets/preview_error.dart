import 'package:flutter/material.dart';

class PreviewError extends StatelessWidget {
  const PreviewError({
    super.key,
    this.color,
    this.backgroundColor,
    this.size,
    this.message,
    this.height = 150,
    this.width = 150,
  });

  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final String? message;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150, minWidth: 150),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'Lỗi hiển thị nội dung',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
