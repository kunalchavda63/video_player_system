import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../core/models/src/video_model/video_model.dart';
import '../../../../core/utilities/src/extensions/logger/logger.dart';

final videoListProvider = FutureProvider<List<VideoModel>>((ref) async {
  logger.d("VideoListProvider called");

  // ✅ Direct permission request
  final permission = await PhotoManager.requestPermissionExtend();
  logger.d("Permission in provider: ${permission.isAuth}");

  if (!permission.isAuth && !permission.isLimited) {
    logger.d("No permission, returning empty");
    return [];
  }

  // ✅ Get videos
  final albums = await PhotoManager.getAssetPathList(
    type: RequestType.video,
  );

  logger.d("Albums found: ${albums.length}");

  List<VideoModel> videos = [];
  Set<String> uniqueIds = {};

  for (final album in albums) {
    final assets = await album.getAssetListRange(
      start: 0,
      end: 1000,
    );

    for (final asset in assets) {
      if (!uniqueIds.contains(asset.id)) {
        uniqueIds.add(asset.id);
        final file = await asset.file;
        if (file != null) {
          videos.add(VideoModel(
            id: asset.id,
            title: file.path.split('/').last,
            filePath: file.path,
            duration: asset.duration ?? 0,
            size: await file.length(),
            modifiedDate: asset.modifiedDateTime
          ));
        }
      }
    }
  }

  videos.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
  logger.d("Total videos: ${videos.length}");

  return videos;
});