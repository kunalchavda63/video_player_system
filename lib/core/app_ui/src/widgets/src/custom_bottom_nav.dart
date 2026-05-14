
import '../../../app_ui.dart';

class CustomBottomNav extends StatelessWidget {
  final List<BottomNavModel> bottomNavList;
  final int currentIndex;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNav({
    super.key,
    required this.bottomNavList,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / bottomNavList.length;

        return CustomContainer(
          h: 80,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              /// 🔥 Floating Circle Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (currentIndex * itemWidth) + (itemWidth / 2) - 25,
                top: 15,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: selectedItemColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              /// 🔥 Icons Row
              Row(
                children: List.generate(bottomNavList.length, (index) {
                  final isSelected = index == currentIndex;

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: isSelected ? 1.2 : 1.0,
                          child: SvgPicture.asset(
                            bottomNavList[index].icon,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              isSelected
                                  ? AppColors.white
                                  : unselectedItemColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}