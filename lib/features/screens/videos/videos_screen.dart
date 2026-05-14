import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/models/src/video_model/video_model.dart';
import '../../../core/provider/video_provider.dart';
import 'help/video_card.dart';
import 'help/video_player_screen.dart';

class VideoGalleryScreen extends ConsumerStatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  ConsumerState<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends ConsumerState<VideoGalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger video loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(videoListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(hasPermissionProvider);
    final videosAsync = ref.watch(videoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Videos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(videoListProvider);
            },
          ),
        ],
      ),
      body: permissionAsync.when(
        data: (hasPermission) {
          if (!hasPermission) {
            return buildNoPermissionView();
          }
          return videosAsync.when(
            data: (videos) => buildVideoGridView(videos),
            error: (error, stack) => buildErrorView(error),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stack) => buildErrorView(error),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildNoPermissionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Permission Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This app needs permission to access your videos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // ignore: unused_result
              ref.refresh(hasPermissionProvider);
              // ignore: unused_result

              ref.refresh(videoListProvider);
            },
            icon: const Icon(Icons.settings),
            label: const Text('Request Permission'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoGridView(List<VideoModel> videos) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No Videos Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'No videos found on your device',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          video: videos[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  video: videos[index],
                  allVideos: videos,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildErrorView(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Error Loading Videos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ref.refresh(hasPermissionProvider);
              ref.refresh(videoListProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}