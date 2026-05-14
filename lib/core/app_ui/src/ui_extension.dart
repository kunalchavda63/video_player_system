
// Extension on FontFamily for shorthand styling

import '../app_ui.dart';

import '../../../core/services/navigation/src/app_router.dart';

import '../../services/repositories/service_locator.dart';
extension FontFamilyExtension on FontFamily {

  String get name {
    switch (this) {
      case FontFamily.poppins:
        return 'poppins';
      case FontFamily.montserrat:
        return 'montserrat';

    }
  }
}

// Extension on TextStyle for shorthand styling
extension CustomTextStyle on TextStyle {
  TextStyle family(FontFamily family) => copyWith(fontFamily: family.name);

  TextStyle s(double size) => copyWith(fontSize: size);

  TextStyle w(int weight) =>
      copyWith(fontWeight: FontWeight.values[(weight ~/ 100) - 1]);

  TextStyle c(Color color) => copyWith(color: color);

  TextStyle letter(double size) => copyWith(letterSpacing: size);

  TextStyle line(double height) => copyWith(height: height);

  TextStyle style(FontStyle s) => copyWith(fontStyle: s);
}

// Extesnion on Padding for shorthand padding
extension CustomPadding on Widget {
  Padding padLeft(double left) =>
      Padding(padding: EdgeInsets.only(left: left), child: this);

  Padding padRight(double right) =>
      Padding(padding: EdgeInsets.only(right: right), child: this);

  Padding padTop(double top) =>
      Padding(padding: EdgeInsets.only(top: top), child: this);

  Padding padBottom(double bottom) =>
      Padding(padding: EdgeInsets.only(bottom: bottom), child: this);

  Padding padSymmetric({double? horizontal = 0.0, double? vertical = 0.0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal!,
          vertical: vertical!,
        ),
        child: this,
      );

  Padding padH(double horizontal) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal),
    child: this,
  );

  Padding padV(double vertical) =>
      Padding(padding: EdgeInsets.symmetric(vertical: vertical), child: this);

  Padding padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
}

// Extension on BorderRadius for shorthand border topLeft bottomLeft topRight bottomRight
extension BorderRadiusOnly on BorderRadius {
  static BorderRadius onlyShort({
    double tl = 0,
    double tr = 0,
    double bl = 0,
    double br = 0,
}) {
    return BorderRadius.only(
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomLeft: Radius.circular(bl),
      bottomRight: Radius.circular(br),
    );
  }
}

// Extension on ThemeData for shrthand themes


// Extension on CustomBottomSheet for shorthand dialogs
extension CustomBottomSheetExtension on BuildContext {
  Future<void> showCustomBottomSheet({Color? bgColor, Widget? child}) {
    return showModalBottomSheet(
      context: this,
      backgroundColor: bgColor,
      builder: (_) => child ?? const SizedBox(),
    );
  }
}
extension CustomPopUpMenu on BuildContext {
  Future<String?> showCustomPopupMenu({
    required GlobalKey anchorKey,
    required BuildContext ctx,
    required List<PopUpModel> items,
    Widget Function(PopUpModel)? itemBuilder,
    double itemHeight = 48,
    Color? color,
  }) async {
    if (anchorKey.currentContext == null) return null;

    final RenderBox renderBox =
    anchorKey.currentContext!.findRenderObject() as RenderBox;

    final Size widgetSize = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final Size screenSize = MediaQuery.of(this).size;
    final double screenHeight = screenSize.height;

    final double menuHeight = items.length * itemHeight;

    final bool showBelow =
        (offset.dy + widgetSize.height + menuHeight) < screenHeight;

    final RelativeRect position = showBelow
        ? RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + widgetSize.height,
      screenSize.width - offset.dx - widgetSize.width,
      0,
    )
        : RelativeRect.fromLTRB(
      offset.dx,
      offset.dy - menuHeight,
      screenSize.width - offset.dx - widgetSize.width,
      0,
    );

    return await showMenu<String>(
      context: ctx,
      position: position,
      color: color,
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item.id,
          child: itemBuilder != null
              ? itemBuilder(item)
              : Text(item.data),
        );
      }).toList(),
    );
  }
}
extension CustomCommonDialog on BuildContext {
  Future<T?> showCustomDialog<T>({
    required String title,
    required String message,

    String? primaryButtonText,
    VoidCallback? onPrimaryTap,

    String? secondaryButtonText,
    VoidCallback? onSecondaryTap,

    Color? titleColor,
    Color? primaryTextColor,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,

    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          alignment: Alignment.center,


          titlePadding: const EdgeInsets.all(20),
          title: CustomText(
            data: title,
            style: BaseStyle.s20w400.c(titleColor ?? AppColors.black),
            textAlign: TextAlign.start,
          ),

          contentPadding: const EdgeInsets.all(22),
          content: CustomText(
            data: message,
            style: BaseStyle.s14w500
                .c(AppColors.black)
                .family(FontFamily.montserrat),
            textAlign: TextAlign.center,
          ),

          actionsPadding: const EdgeInsets.all(20),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            if (secondaryButtonText != null)
              CustomButton(
                isSmall: true,
                h: 30,
                label: secondaryButtonText,
                color: secondaryButtonColor ?? AppColors.black10,
                onTap: () {
                  getIt<AppRouter>().pop<void>();
                  onSecondaryTap?.call();
                },
              ),

            if (primaryButtonText != null)
              CustomButton(
                isSmall: true,
                h: 30,
                label: primaryButtonText,
                textColor: primaryTextColor ?? Colors.red,
                color: primaryButtonColor ?? AppColors.transparent,
                onTap: () {
                  getIt<AppRouter>().pop<void>();
                  onPrimaryTap?.call();
                },
              ),
          ],
        );
      },
    );
  }
}

