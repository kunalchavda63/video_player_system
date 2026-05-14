
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../app_ui.dart';

class CustomImageView extends StatelessWidget {

  const CustomImageView({
    super.key,
    required this.path,
    this.sourceType = ImageType.asset,
    this.height,
    this.width,
    this.fit,
  });
  final String path;
  final ImageType sourceType;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    switch (sourceType) {
      case ImageType.asset:
        return Image.asset(path, height: height, width: width, fit: fit);

      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: path,
          height: height,
          width: width,
          fit: fit,
          placeholderFadeInDuration: const Duration(milliseconds: 500),
          progressIndicatorBuilder: (context, url, downloadProgress) {
            final double progressValue = downloadProgress.progress ?? 0.0;

            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation(AppColors.white),
                ),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return _AnimatedImageWrapper(
              image: Image(
                image: imageProvider,
                height: height,
                width: width,
                fit: fit,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return CustomImageView(
              path: path,
              height: height,
              width: width,
              fit: BoxFit.cover,
            );
          },
        );

      case ImageType.file:
        return Image.file(File(path), height: height, width: width, fit: fit);
    }
  }
}

class _AnimatedImageWrapper extends StatefulWidget {

  const _AnimatedImageWrapper({required this.image});
  final Widget image;

  @override
  State<_AnimatedImageWrapper> createState() => _AnimatedImageWrapperState();
}

class _AnimatedImageWrapperState extends State<_AnimatedImageWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.96,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.image),
    );
  }
}