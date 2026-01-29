import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../screens/notification.dart';
import '../widgets/app_drawer.dart';
import 'note_widget_creator.dart';
import 'wallpaper_creator.dart';
import 'comingsoon.dart';
import 'widget_creator.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("appTitle".tr()),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "welcome".tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "welcomeSubtitle".tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87, 
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(10),
            children: [
              _buildActionCard(
                "createWallpaper".tr(),
                Icons.wallpaper,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WallpaperCreator()),
                ),
              ),
              _buildActionCard(
                "createWidget".tr(),
                Icons.widgets,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NoteWidgetCreator()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class WidgetCreator extends StatelessWidget {
//   const WidgetCreator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: IconTextWidget(
//           icon: Icons.on_device_training,
//           text: 'Coming Soon !',
//           iconColor: Colors.grey,
//           textColor: Colors.grey,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           mainAxisAlignment: MainAxisAlignment.center,
//           padding: const EdgeInsets.all(16),
//         )
//       ),
//     );
//   }
// }