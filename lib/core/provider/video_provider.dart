import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/src/video_model/video_model.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository();
});

final videoListProvider = FutureProvider<List<VideoModel>>((ref) async {
  final repository = ref.read(videoRepositoryProvider);
  return await repository.getAllVideos();
});

final hasPermissionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(videoRepositoryProvider);
  return await repository.hasPermission();
});

class VideoRepository {
  Future<bool> hasPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return permission.isAuth;
  }
  Future<List<VideoModel>> getAllVideos() async {
    print('Getting all videos...'); // Debug print

    // Request permission first
    final permission = await PhotoManager.requestPermissionExtend();
    print('Permission in getAllVideos: $permission');

    if (!permission.isAuth) {
      print('No permission, returning empty list');
      return [];
    }

    // Get all video assets
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );
    Set<String> uniqueVideoIds =  {};

    print('Albums found: ${albums.length}'); // Kitne albums mile

    List<VideoModel> videos = [];

    for (final album in albums) {
      print('Album name: ${album.name}');
      final assets = await album.getAssetListRange(
        start: 0,
        end: 10000,
      );

      print('Assets in album: ${assets.length}');

      for (final asset in assets) {
        if(!uniqueVideoIds.contains(asset.id)) {
          uniqueVideoIds.add(asset.id);
          final file = await asset.file;
          if (file != null) {
            print('Video found: ${file.path}');
            videos.add(VideoModel(
              id: asset.id,
              title: file.path
                  .split('/')
                  .last,
              filePath: file.path,
              duration: asset.duration ?? 0,
              size: await file.length(),
              modifiedDate: asset.modifiedDateTime,
            ));
          }
        }
      }
    }

    print('Total videos found: ${videos.length}');
    videos.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

    return videos;
  }
  }
