import '../../../core/app_ui/app_ui.dart';


class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

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
              title: CustomText(data: "B R O W S E",style: BaseStyle.s11w700.c(AppColors.white).family(FontFamily.poppins),)
          ),
        ],
      ),


    );
  }
}
