// lib/widgets/loading_widget.dart

import 'package:flutter/material.dart';

/// A custom loading indicator consisting of three pulsating dots.
/// The dots fade in and out in a staggered sequence to convey activity.
class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  /// Controls the animation for all dots over a fixed duration.
  late final AnimationController _controller;

  /// Holds three fade animations, each staggered in time.
  late final List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    // Initialize the controller for a 1-second repeating animation cycle.
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Generate three animations with offsets of 0.0, 0.2, and 0.4 seconds.
    _dotAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.6;
      return Tween<double>(
        begin: 0.2, // start slightly faded
        end: 1.0, // fade in to full opacity
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    // Always dispose animation controllers to free resources.
    _controller.dispose();
    super.dispose();
  }

  /// Builds a single dot widget that animates its opacity.
  Widget _buildDot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Center the row of animated dots on screen.
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _dotAnimations.map(_buildDot).toList(),
      ),
    );
  }
}
