import '../../../../../app_ui.dart';



class CustomCircleBackButton extends StatelessWidget {
  const CustomCircleBackButton({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      h: 32.r,
      w: 32.r,
      onTap: () {
        // todo uncomment
        // getIt<AppRouter>().pop<dynamic>();
      },
      // border: Border.all(color: color??AppColors.hex2824),
      padding: const EdgeInsets.all(8),
      color: color ?? AppColors.transparent,
      boxShape: BoxShape.circle,
      child: SvgPicture.asset(
        AssetIcons.icBack,
        colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
        height: 32.r,
        width: 32.r,
      ),
    );
  }
}