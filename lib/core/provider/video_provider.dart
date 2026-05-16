import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/src/video_model/video_model.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository();
});

final videoListProvider = FutureProvider<List<VideoModel>>((ref) async {
  final repository = ref.read(videoRepositoryProvider);
  final hasPerm = await repository.hasPermission();

  // ✅ Agar permission nahi hai toh empty list return karo
  if (!hasPerm) {
    return [];
  }

  return await repository.getAllVideos();
});

final hasPermissionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(videoRepositoryProvider);
  return await repository.hasPermission();
});

class VideoRepository {
  Future<bool> hasPermission() async {
    // ✅ Check current permission status
    final status = await Permission.photos.status;

    print('📱 Current permission status: $status');

    if (status.isGranted) {
      print('✅ Permission already granted');
      return true;
    }

    if (status.isDenied) {
      print('⚠️ Permission denied, requesting...');
      final result = await Permission.photos.request();
      print('📱 Request result: $result');

      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        print('❌ Permission permanently denied');
        return false;
      } else {
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      print('❌ Permission permanently denied, open app settings');
      return false;
    }

    return false;
  }

  Future<List<VideoModel>> getAllVideos() async {
    try {
      print('🎬 Getting all videos...');

      // Check permission again
      final hasPerm = await hasPermission();
      if (!hasPerm) {
        print('❌ No permission, returning empty list');
        return [];
      }

      // Get all video assets
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      print('📁 Albums found: ${albums.length}');

      if (albums.isEmpty) {
        print('⚠️ No albums found');
        return [];
      }

      List<VideoModel> videos = [];
      Set<String> uniqueIds = {};

      for (final album in albums) {
        final assets = await album.getAssetListRange(
          start: 0,
          end: 10000,
        );

        print('🎬 Assets in album: ${assets.length}');

        for (final asset in assets) {
          if (!uniqueIds.contains(asset.id)) {
            uniqueIds.add(asset.id);

            final file = await asset.file;
            if (file != null && await file.exists()) {
              videos.add(VideoModel(
                id: asset.id,
                title: file.path.split('/').last,
                filePath: file.path,
                duration: asset.duration ?? 0,
                size: await file.length(),
                modifiedDate: asset.modifiedDateTime,
              ));
            }
          }
        }
      }

      videos.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
      print('✅ Total unique videos: ${videos.length}');

      return videos;
    } catch (e) {
      print('❌ Error in getAllVideos: $e');
      return [];
    }
  }
}