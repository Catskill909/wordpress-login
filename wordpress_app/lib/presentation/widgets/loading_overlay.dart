import 'package:flutter/material.dart';

/// A widget that displays a loading overlay on top of its child.
class LoadingOverlay extends StatelessWidget {
  /// Whether the loading overlay is visible.
  final bool isLoading;

  /// The child widget to display.
  final Widget child;

  /// The color of the loading overlay.
  final Color? color;

  /// The opacity of the loading overlay.
  final double opacity;

  /// The progress indicator to display.
  final Widget? progressIndicator;

  /// Creates a loading overlay.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
    this.opacity = 0.5,
    this.progressIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: _buildLoadingOverlay(context),
          ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: color ?? Colors.black.withAlpha((opacity * 255).round()),
      child: Center(
        child: progressIndicator ??
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
      ),
    );
  }
}
