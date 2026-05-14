import 'package:photo_manager/photo_manager.dart';
import 'package:video_player_system/core/utilities/utils.dart';

Future<List<AssetEntity>> fetchVideos() async {
  try {
    logger.d("Starting to fetch videos...");

    // Request permission
    final permission = await PhotoManager.requestPermissionExtend();
    logger.d("Permission status: ${permission.isAuth}");

    if (!permission.isAuth) {
      logger.e("Permission denied");
      return [];
    }

    // Get albums with videos
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    logger.d("Found ${albums.length} albums with videos");

    if (albums.isEmpty) {
      logger.d("No albums found");
      return [];
    }

    final recentAlbum = albums.first;
    logger.d("Recent album: ${recentAlbum.name}");

    // Get videos
    final videos = await recentAlbum.getAssetListPaged(
      page: 0,
      size: 100,
    );

    logger.d("Total Videos loaded: ${videos.length}");
    return videos;

  } catch (e, stacktrace) {
    logger.e("Error in fetchVideos: $e\n$stacktrace");
    return [];
  }
}