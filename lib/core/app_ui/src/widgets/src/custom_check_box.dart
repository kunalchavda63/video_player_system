import '../../../app_ui.dart';
import '../../../../utilities/utils.dart';

class CustomCanCopy extends StatelessWidget {

  const CustomCanCopy({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white.withAlpha(200),
      borderRadius: BorderRadius.circular(20),
      h: 40,
      w: MediaQuery.of(context).size.width,
      onTap: () {
        copyToClipboard(text);
      },
      border: Border.all(color: AppColors.white),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CustomText(
        data: text,
        textAlign: TextAlign.center,
        // style: BaseStyle.s10w700.c(AppColors.hex3234),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}