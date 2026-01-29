import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../utils/snackbar_helper.dart';

final wallpaperProvider = StateNotifierProvider<WallpaperViewModel, WallpaperState>(
  (ref) => WallpaperViewModel(),
);

class WallpaperState {
  final File? imageFile;
  final bool exporting;

  const WallpaperState({this.imageFile, this.exporting = false});

  WallpaperState copyWith({File? imageFile, bool? exporting}) {
    return WallpaperState(
      imageFile: imageFile ?? this.imageFile,
      exporting: exporting ?? this.exporting,
    );
  }
}

class WallpaperViewModel extends StateNotifier<WallpaperState> {
  WallpaperViewModel() : super(const WallpaperState());

  final _picker = ImagePicker();
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _uploadToFirebase(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final storageRef = FirebaseStorage.instance
      .ref()
      .child('wallpapers')
      .child(user.uid)
      .child('wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');

    await storageRef.putFile(file);

    final downloadUrl = await storageRef.getDownloadURL();
    print('✅ Wallpaper uploaded: $downloadUrl');

    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('wallpapers')
      .add({
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    state = state.copyWith(imageFile: File(picked.path));
  }

  Future<void> exportToHomeWidget(BuildContext context) async {
    if (state.imageFile == null) return;

    state = state.copyWith(exporting: true);

    try {

      final Uint8List? imageBytes = await screenshotController.capture(pixelRatio: 2.5);
      if (imageBytes == null) {
        SnackBarHelper.showError(context, "Error: Failed to capture wallpaper.");
        return;
      }

      final int? widgetId = await HomeWidget.getWidgetData<int>('widgetId');
      if (widgetId == null) {
        debugPrint('❌ widgetId is null — app not launched from widget');
        SnackBarHelper.showError(context, "Error: Unable to get widget ID.");
        return;
      }

      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        SnackBarHelper.showError(context, "Error: Unable to access storage directory.");
        return;
      }

      final file = File(
        '${dir.path}/idol_widget_${widgetId}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      try {
        await file.writeAsBytes(imageBytes);
      } catch (e) {
        SnackBarHelper.showError(context, "Error saving wallpaper: $e");
        return;
      }

      await HomeWidget.saveWidgetData<String>(
        'wallpaper_image_path_$widgetId',
        file.path,
      );

      await HomeWidget.updateWidget(
        name: 'IdolHomeWidget',
        androidName: 'IdolHomeWidget',
      );

      await _uploadToFirebase(file);
      SnackBarHelper.showSuccess(context, "Wallpaper exported to widget!");

    } finally {
      state = state.copyWith(exporting: false);
    }
  }
}

class WallpaperCreator extends ConsumerWidget {
  const WallpaperCreator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wallpaperProvider);
    final vm = ref.read(wallpaperProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallpaper Creator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => vm.pickImage(),
                  child: Screenshot(
                    controller: vm.screenshotController,
                    child: _PreviewArea(imageFile: state.imageFile),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: state.exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            state.imageFile == null
                                ? Icons.image_outlined
                                : Icons.widgets_outlined,
                          ),
                    label: Text(
                      state.imageFile == null ? 'Select Image' : 'Export Widget',
                    ),
                    onPressed: state.exporting
                        ? null
                        : state.imageFile == null
                            ? () async {
                                await vm.pickImage();
                              }
                            : () async {
                                await vm.exportToHomeWidget(context);
                              },
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final File? imageFile;

  const _PreviewArea({this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageFile == null
          ? const Center(
              child: Text(
                'Select your favourite idol image',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Image.file(imageFile!, fit: BoxFit.cover),
    );
  }
}