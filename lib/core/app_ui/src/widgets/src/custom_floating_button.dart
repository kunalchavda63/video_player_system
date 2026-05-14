import '../../../app_ui.dart';

class CustomFloatingButton extends StatelessWidget {

  const CustomFloatingButton({
    super.key,
    this.label,
    this.onTap,
    this.backgroundColor,
    this.toolTip,
    this.child,
    this.type = FabType.normal,
  });
  final String? label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final String? toolTip;
  final Widget? child;
  final FabType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FabType.extended:
        return FloatingActionButton.extended(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          tooltip: toolTip,
          icon: child,
          label: Text(label ?? ''),
        );
      case FabType.small:
        return FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          tooltip: toolTip,
          child: child,
        );
      case FabType.large:
        return FloatingActionButton.large(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          tooltip: toolTip,
          child: child,
        );
      case FabType.normal:
        return FloatingActionButton(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          tooltip: toolTip,
          shape: const CircleBorder(),
          child: child,
        );
    }
  }
}