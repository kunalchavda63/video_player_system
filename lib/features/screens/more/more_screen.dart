import '../../../core/app_ui/app_ui.dart';


class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              titleSpacing: 20,
              backgroundColor: AppColors.darkPurple,
              toolbarHeight: 80,
              pinned: true,
              floating: true,
              title: CustomText(data: "M O R E",style: BaseStyle.s11w700.c(AppColors.white).family(FontFamily.poppins),)
          ),
        ],
      ),

    );
  }
}
