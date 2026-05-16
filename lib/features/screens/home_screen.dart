import '../../core/app_ui/app_ui.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_system/core/utilities/utils.dart';
import 'package:video_player_system/features/screens/browse/browse_screen.dart';
import 'package:video_player_system/features/screens/folder/folder_screen.dart';
import 'package:video_player_system/features/screens/more/more_screen.dart';
import 'package:video_player_system/features/screens/video_screen.dart';
import 'package:video_player_system/features/screens/videos/videos_screen.dart';


final bottomNavProvider = StateProvider<int>((ref) => 0);



const List<Widget> _screenList = [
  VideoGalleryScreen(),
  VideoScreen(),
  FolderScreen(),
  BrowseScreen(),
  MoreScreen()
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _screenList[currentIndex],
      bottomNavigationBar: SafeArea(
        child: CustomBottomNav(
        
            backgroundColor: AppColors.yellow.withOAlpha(0.2),
            selectedItemColor: AppColors.orange0,
            unselectedItemColor: AppColors.blackFF,
            currentIndex: currentIndex,
        
            onTap: (index){
              ref.read(bottomNavProvider.notifier).state = index;
            },
            bottomNavList: [
          BottomNavModel(icon: AssetIcons.icVideo, label: 'VIDEO'),
          BottomNavModel(icon: AssetIcons.icAudio, label: 'AUDIO'),
          BottomNavModel(icon: AssetIcons.icBrowse, label: 'BROWSE'),
          BottomNavModel(icon: AssetIcons.icPlaylist, label: 'PLAYLIST'),
          BottomNavModel(icon: AssetIcons.icMore, label: 'MORE'),
        ]
        ),
      ),

    );
  }
}

