import '../../app_ui/app_ui.dart';
import '../navigation/src/app_router.dart';
import '../../utilities/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';


final getIt = GetIt.instance;



Future<void> requestAllPermission() async {
  await Permission.notification.request();
  if(await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
    await Permission.ignoreBatteryOptimizations.request();
  }
}




Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
  getIt.registerLazySingleton<AppStrings>(() => AppStrings());
  getIt.registerLazySingleton<AppColors>(() => AppColors());

   if(isAndroid || isIos)await requestAllPermission();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusManager.instance.primaryFocus?.unfocus();
  });
}

