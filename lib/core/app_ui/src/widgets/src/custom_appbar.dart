import '../../../app_ui.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.bgColor,
    this.gradient, // ✅ NEW
    this.isCenterTitle = true,
    this.bottomOpacity = 1.0,
    this.elevation = 0,
    this.scrollUnderElevation = 0,
    this.autoImplyLeading = true,
    this.height,
    this.actions,
  });

  final Widget? leading;
  final Widget? title;
  final Color? bgColor;
  final Gradient? gradient; // ✅
  final bool isCenterTitle;
  final double bottomOpacity;
  final double elevation;
  final double scrollUnderElevation;
  final bool autoImplyLeading;
  final double? height;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        actions: actions,
        backgroundColor: bgColor,
        bottomOpacity: bottomOpacity,
        elevation: elevation,
        scrolledUnderElevation: scrollUnderElevation,
        centerTitle: isCenterTitle,
        leading: leading,
        title: title,
        automaticallyImplyLeading: autoImplyLeading,
        toolbarHeight: height,
        flexibleSpace: gradient != null ? CustomContainer(
          gradient: gradient,
        ): null
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 60);
}