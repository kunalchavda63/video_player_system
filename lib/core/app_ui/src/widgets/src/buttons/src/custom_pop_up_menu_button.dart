import '../../../../../app_ui.dart';

class CustomPopupMenuButton extends StatelessWidget {

  const CustomPopupMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon = const Icon(Icons.more_vert), this.animationStyle, this.boxColor, this.offset, this.eachChild, this.popupMenuPosition, this.shapeBorder,
  });
  final List<String> items;
  final AnimationStyle? animationStyle;
  final Color? boxColor;
  final Offset? offset;
  final Widget? eachChild;
  final ShapeBorder? shapeBorder;
  final PopupMenuPosition? popupMenuPosition;

  final void Function(String value) onSelected;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      shape: shapeBorder??RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      popUpAnimationStyle:animationStyle?? const AnimationStyle(curve: Curves.ease,duration: Duration(milliseconds: 800)),
      onSelected: onSelected,
      position: popupMenuPosition??PopupMenuPosition.over,
      // color:boxColor?? AppColors.hex2824,
      offset:offset?? const Offset(-20,40),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem<String>(

        value: item,
        child: eachChild??CustomText(data: item,style: BaseStyle.s17w400),
      ),)
          .toList(),
      icon: icon,
    );
  }
}