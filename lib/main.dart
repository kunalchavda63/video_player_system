import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player_system/core/utilities/utils.dart';

import 'core/app_ui/app_ui.dart';
import 'features/screens/home_screen.dart';
Future<bool> hasPermission() async {
  // Permission status check
  PermissionState permission = await PhotoManager.requestPermissionExtend();

  logger.i('Permission status: $permission'); // Debug ke liye

  if (permission == PermissionState.authorized) {
    return true;
  } else if (permission == PermissionState.limited) {
    // Android 14+ limited access
    return true;
  } else {
    // Permission denied
    return false;
  }
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Permission.photos.request();
  await Permission.videos.request();

   var status = await Permission.videos.status;
  logger.i("Initial video permission status: $status");

  if (!status.isGranted) {
    status = await Permission.videos.request();
    logger.i("After request: $status");
  }
  var pmStatus = await PhotoManager.requestPermissionExtend();
  logger.i("PhotoManager status: ${pmStatus.isAuth}");


  final permission = await PhotoManager.requestPermissionExtend();
  logger.d("Initial Permission Status : ${permission.isAuth}");

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
