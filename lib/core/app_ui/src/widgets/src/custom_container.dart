import '../../../app_ui.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {



  const CustomContainer({
    super.key,
    this.h,
    this.w,
    this.child,
    this.padding,
    this.borderRadius,
    this.border,
    this.onTap,
    this.color,
    this.boxShadow,
    this.alignment,
    this.boxShape,
    this.blendMode,
    this.clipBehaviour,
    this.path,
    this.constraints,
    this.margin,
    this.gradient,
    this.foregroundDecoration, this.imageOpacity, this.imageFit, this.imageH, this.imageW,
  });
  final double? h;
  final double? w;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxConstraints? constraints;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Alignment? alignment;
  final BoxShape? boxShape;
  final BlendMode? blendMode;
  final Clip? clipBehaviour;
  final String? path;
  final Gradient? gradient;
  final BoxDecoration? foregroundDecoration;
  final double? imageOpacity;
  final BoxFit? imageFit;
  final double? imageH;
  final double? imageW;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        foregroundDecoration: foregroundDecoration,
        height: h,
        width: w,
        alignment: alignment,
        padding: padding,
        margin: margin,
        constraints: constraints,
        decoration: BoxDecoration(
          gradient: gradient,


          backgroundBlendMode: blendMode,
          image:
          path != null
              ? DecorationImage(
            opacity: imageOpacity ?? 1,

            fit:imageFit ??  BoxFit.cover,
            image: AssetImage(path ?? ''),
          )
              : null,
          border: border,
          borderRadius: borderRadius,
          color: color,
          boxShadow: boxShadow,
          shape: boxShape ?? BoxShape.rectangle,
        ),
        clipBehavior: clipBehaviour ?? Clip.none,
        child: child,
      ),
    );
  }
}