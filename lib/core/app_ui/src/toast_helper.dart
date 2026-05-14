import '../app_ui.dart';
import 'package:windows_toast/windows_toast.dart';

void showSuccessToast(String message,BuildContext context) {
  WindowsToast.show(
    message,
    context,
    20,
    textStyle:BaseStyle.s14w500.c(AppColors.white),
    toastColor: Colors.green,
  );
}

void showErrorToast(String message,BuildContext context) {
  WindowsToast.show(
    message,
    context,
    20,
    textStyle:BaseStyle.s14w500.c(AppColors.white),
    toastColor: Colors.red,
  );

}
