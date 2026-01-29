import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/snackbar_helper.dart';

/// --------------------
/// STATE
/// --------------------
@immutable
class NoteWidgetState {
  final String text;
  final String? imagePath;

  const NoteWidgetState({
    required this.text,
    required this.imagePath,
  });

  factory NoteWidgetState.initial() {
    return const NoteWidgetState(
      text: '',
      imagePath: null,
    );
  }

  NoteWidgetState copyWith({
    String? text,
    String? imagePath,
  }) {
    return NoteWidgetState(
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// --------------------
/// PROVIDER
/// --------------------
final noteWidgetProvider = StateNotifierProvider<NoteWidgetVM, NoteWidgetState>((ref) {
  return NoteWidgetVM();
});

/// --------------------
/// VIEW MODEL
/// --------------------
class NoteWidgetVM extends StateNotifier<NoteWidgetState> {
  NoteWidgetVM() : super(NoteWidgetState.initial());

  void setText(String value) {
    state = state.copyWith(text: value);
  }

  void setImagePath(String path) {
    state = state.copyWith(imagePath: path);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setImagePath(image.path);
    }
  }

  Future<void> saveToFirestore({required String imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final widgetId = await HomeWidget.getWidgetData<int>('current_widget_id');
    if (widgetId == null) throw Exception('Widget ID not found');

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('widgets')
        .doc(widgetId.toString());

    await docRef.set(
      {
        'widgetId': widgetId.toString(),
        'type': 'note',
        'data': {
          'text': state.text,
          'imageUrl': imageUrl,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveToWidget(BuildContext context) async {
    final widgetId = await HomeWidget.getWidgetData<int>('current_widget_id');
    if (widgetId == null) {
      SnackBarHelper.showError(context, 'Widget ID not found');
      return;
    }

    if (state.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Please enter a note before exporting');
      return;
    }

    if (state.imagePath == null) {
      SnackBarHelper.showError(context, 'Please select an image before exporting');
      return;
    }

    final directory = await getApplicationSupportDirectory();
    final filePath = '${directory.path}/note_image_$widgetId.png';
    final file = await File(state.imagePath!).copy(filePath);

    await HomeWidget.saveWidgetData('note_text_$widgetId', state.text);
    await HomeWidget.saveWidgetData('note_image_$widgetId', 'note_image_$widgetId.png');

    await HomeWidget.updateWidget(
      androidName: 'NoteHomeWidget',
      name: 'NoteHomeWidget',
    );

    final user = FirebaseAuth.instance.currentUser!;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/widgets/note_image_$widgetId.png');

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    await saveToFirestore(imageUrl: downloadUrl);

    debugPrint('🧩 Widget ID: $widgetId');
    debugPrint('📝 Text: ${state.text}');
    debugPrint('🖼 Original image path: ${state.imagePath}');
    debugPrint('📂 Saved image path: $filePath');
    debugPrint('📄 File exists: ${file.existsSync()}');
    debugPrint('📏 File size: ${file.lengthSync()} bytes');

    SnackBarHelper.showSuccess(context, 'Note widget exported successfully');
  }
}

/// --------------------
/// UI
/// --------------------
class NoteWidgetCreator extends ConsumerWidget {
  const NoteWidgetCreator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noteWidgetProvider);
    final vm = ref.read(noteWidgetProvider.notifier);

    final canSave =
        state.text.trim().isNotEmpty && state.imagePath != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Note Widget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Enter note text',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setText,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: state.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(state.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: vm.pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select Idol Image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave ? () => vm.saveToWidget(context) : null,
                child: const Text('Save to Widget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}