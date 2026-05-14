import '../../../../app_ui/app_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCircleSvgIcon extends StatelessWidget {
  const CustomCircleSvgIcon({
    super.key,
    this.h,
    this.w,
    this.iconColor,
    this.border,
    this.bgColor,
    this.onTap, this.iconH, this.iconW,this.padding, this.path, this.fit, this.boxShadow,
  });
  final double? h;
  final double? w;
  final double? iconH;
  final double? iconW;
  final Border? border;
  final Color? bgColor;
  final String? path;
  final Color? iconColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final BoxFit? fit;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      boxShadow: boxShadow,
      onTap: onTap,
      h: h,
      w: w,
      padding: padding??const EdgeInsets.all(8),
      boxShape: BoxShape.circle,
      border: border,
      color: bgColor,
      child: SvgPicture.asset(path??AssetIcons.icEdit,height: iconH,width: iconW,colorFilter: ColorFilter.mode(iconColor??AppColors.black, BlendMode.srcIn),fit: fit??BoxFit.contain,),
    );
  }
}