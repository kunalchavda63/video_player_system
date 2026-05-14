import '../../../core/app_ui/app_ui.dart';


class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

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
              title: CustomText(data: " F O L D E R",style: BaseStyle.s11w700.c(AppColors.white).family(FontFamily.poppins),)
          ),
        ],
      ),


    );
  }
}
