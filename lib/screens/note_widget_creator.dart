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
import 'clock_widget_creator.dart';

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
    bool removeImage = false,
  }) {
    return NoteWidgetState(
      text: text ?? this.text,
      imagePath: removeImage ? null : imagePath ?? this.imagePath,
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

  void removeImage() {
    state = state.copyWith(removeImage: true);
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
      appBar: AppBar(
        title: const Text('Create Widgets'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                      child: Text(
                        '1. Select Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Stack(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: vm.pickImage,
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade100,
                            ),
                            child: state.imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(state.imagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap to select idol image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        if (state.imagePath != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: vm.removeImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 14),
                      child: Text(
                        '2. Enter Text',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    TextField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Write your note here…',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: vm.setText,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// =========================
            /// PREVIEW TITLE
            /// =========================
            const Text(
              'Widget Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            /// =========================
            /// PREVIEW CARD (UNCHANGED)
            /// =========================
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    /// PREVIEW IMAGE
                    Container(
                      width: 80,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: state.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(state.imagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                    ),

                    const SizedBox(width: 12),

                    /// PREVIEW TEXT
                    Expanded(
                      child: Text(
                        state.text.isEmpty
                            ? 'Your note will appear here'
                            : state.text,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: state.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// =========================
            /// SAVE BUTTON
            /// =========================
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canSave ? () => vm.saveToWidget(context) : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save to Widget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => const ClockWidgetCreatorButton(),
                )),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Click me to create Clock Widget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'This preview matches how the widget will appear on your home screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}