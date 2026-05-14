
import '../../../app_ui.dart';

/// Types of animations you can apply.

/// Reusable animated wrapper for any widget.
class CustomAnimationWrapper extends StatefulWidget {

  const CustomAnimationWrapper({
    super.key,
    required this.child,
    this.animationType = AnimationTypes.fade,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });
  final Widget child;
  final AnimationTypes animationType;
  final Duration duration;
  final Curve curve;

  @override
  State<CustomAnimationWrapper> createState() => _CustomAnimationWrapperState();
}

class _CustomAnimationWrapperState extends State<CustomAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(
      begin: _getOffset(widget.animationType),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  Offset _getOffset(AnimationTypes type) {
    switch (type) {
      case AnimationTypes.slideFromTop:
        return const Offset(0, -0.9);
      case AnimationTypes.slideFromBottom:
        return const Offset(-0.0, -0.8);
      case AnimationTypes.slideFromLeft:
        return const Offset(-0.8, 0);
      case AnimationTypes.slideFromRight:
        return const Offset(0.8, 0);
      default:
        return Offset.zero;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation() {
    switch (widget.animationType) {
      case AnimationTypes.fade:
        return FadeTransition(opacity: _fadeAnimation, child: widget.child);
      case AnimationTypes.scale:
        return ScaleTransition(scale: _scaleAnimation, child: widget.child);
      case AnimationTypes.fadeScale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
        );
      case AnimationTypes.slideFromTop:
      case AnimationTypes.slideFromBottom:
      case AnimationTypes.slideFromLeft:
      case AnimationTypes.slideFromRight:
        return SlideTransition(position: _slideAnimation, child: widget.child);
      case AnimationTypes.none:
        return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAnimation();
  }
}