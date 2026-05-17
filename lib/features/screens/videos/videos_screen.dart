import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/app_ui/app_ui.dart';
import '../../../core/utilities/utils.dart';
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
  // ✅ Future ko ek variable mein store kiya taaki build() mein baar-baar call na ho
  Future<PermissionState>? _permissionFuture;

  @override
  void initState() {
    super.initState();
    _checkPermissionInitially();
  }

  void _checkPermissionInitially() {
    setState(() {
      _permissionFuture = PhotoManager.requestPermissionExtend();
    });

    _permissionFuture?.then((permission) {
      if (permission.isAuth || permission.isLimited) {
        ref.refresh(videoListProvider);
      }
    });
  }

  Future<void> _requestDirectPermission() async {
    logger.d("Requesting permission manually...");
    final permission = await PhotoManager.requestPermissionExtend();

    // ✅ State update karo
    setState(() {
      _permissionFuture = Future.value(permission);
    });

    if (permission.isAuth || permission.isLimited) {
      ref.refresh(videoListProvider);
    } else {
      logger.d("Permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videoListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      // ✅ Pull to refresh functionality
      body: RefreshIndicator(
        color: Colors.deepPurpleAccent,
        backgroundColor: Colors.grey.shade900,
        onRefresh: () async {
          await _requestDirectPermission();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ✅ Beautiful Collapsing App Bar
          SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: 90.0, // Thoda bada kiya taaki gradient acche se dikhe
          backgroundColor: const Color(0xFF2E6B7A), // Teal/Blueish color matching image
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: CustomText(
              data: "V I D E O S",
              style: BaseStyle.s16w500.c(AppColors.white).family(FontFamily.poppins).copyWith(letterSpacing: 2.0),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E6B7A), // Screenshot wala top teal color
                    Color(0xFF1F4C5A), // Bottom dark teal
                  ],
                ),
              ),
            ),
          ),),

            // ✅ Permission Future Builder wrapped in Slivers
            FutureBuilder<PermissionState>(
              future: _permissionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingView("Checking permissions..."),
                  );
                }

                if (!snapshot.hasData || (!snapshot.data!.isAuth && !snapshot.data!.isLimited)) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: buildPermissionDeniedView(),
                  );
                }

                // ✅ Provider mapping into Slivers
                return videosAsync.when(
                  data: (videos) {
                    if (videos.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: buildNoVideosView(),
                      );
                    }
                    return buildSliverVideoGrid(videos);
                  },
                  error: (error, stack) {
                    logger.e("Error: $error");
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: buildErrorView(error),
                    );
                  },
                  loading: () => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingView("Loading videos..."),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- SLIVER WIDGETS ---

  Widget buildSliverVideoGrid(List<VideoModel> videos) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Adjust based on your VideoCard UI
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: VideoCard(
                video: videos[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        allVideos: videos,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          childCount: videos.length,
        ),
      ),
    );
  }

  // --- STATE VIEWS ---

  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.deepPurpleAccent),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 60, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 24),
            const Text(
              'Access Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'We need access to your gallery to show your videos here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _requestDirectPermission,
              icon: const Icon(Icons.folder_shared, color: Colors.white),
              label: const Text(
                'Grant Permission',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                elevation: 4,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoVideosView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.videocam_off_outlined, size: 64, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Videos Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your device doesn\'t have any videos yet.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: _requestDirectPermission,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurpleAccent),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}