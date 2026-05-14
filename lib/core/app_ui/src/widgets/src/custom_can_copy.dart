import '../../../app_ui.dart';
import '../../../../utilities/utils.dart';

class CustomBottomNav extends StatelessWidget {

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.bottomNavList,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });
  final int currentIndex;
  final void Function(int) onTap;
  final List<BottomNavModel> bottomNavList;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? Colors.grey[900] : AppColors.white),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOAlpha(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedItemColor ?? (isDark ? Colors.blue.shade300 : AppColors.yellow),
        unselectedItemColor: unselectedItemColor ?? (isDark ? Colors.grey[500] : Colors.grey),
        selectedLabelStyle: TextStyle(
          color: isDark ? Colors.white : AppColors.black,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey,
        ),
        items: bottomNavList.map((item) {
          return BottomNavigationBarItem(
            icon: CustomCircleSvgIcon(
              path: item.icon,
              iconH: 20,
              iconW: 20,
              iconColor: item.iconColor ?? (isDark ? Colors.grey[500] : Colors.grey),
            ),
            activeIcon: CustomCircleSvgIcon(
              path: item.icon,
              iconH: 20,
              iconColor: selectedItemColor ?? (isDark ? Colors.blue.shade300 : AppColors.yellow),
              iconW: 20,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}