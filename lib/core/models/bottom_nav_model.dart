import '../../../core/app_ui/app_ui.dart';


class BottomNavModel {
  BottomNavModel({
    required this.icon,
    required this.label,
    this.iconColor,
    this.activeIconColor,
  });
  final String icon;
  final String label;
  final Color? iconColor;
  final Color? activeIconColor;

}