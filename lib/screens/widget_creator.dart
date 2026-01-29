import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../utils/snackbar_helper.dart';

/// ---------------------------------------------------------------------------
/// WIDGET TYPE
/// ---------------------------------------------------------------------------

enum KWidgetType { clock, note }

/// ---------------------------------------------------------------------------
/// STATE
/// ---------------------------------------------------------------------------

class WidgetCreatorState {
  final bool exporting;
  final KWidgetType? selectedType;
  final File? imageFile;
  final String noteText;

  const WidgetCreatorState({
    this.exporting = false,
    this.selectedType,
    this.imageFile,
    this.noteText = '',
  });

  WidgetCreatorState copyWith({
    bool? exporting,
    KWidgetType? selectedType,
    File? imageFile,
    String? noteText,
  }) {
    return WidgetCreatorState(
      exporting: exporting ?? this.exporting,
      selectedType: selectedType ?? this.selectedType,
      imageFile: imageFile ?? this.imageFile,
      noteText: noteText ?? this.noteText,
    );
  }
}

/// ---------------------------------------------------------------------------
/// PROVIDER
/// ---------------------------------------------------------------------------

final widgetCreatorProvider = StateNotifierProvider<WidgetCreatorScreen, WidgetCreatorState>(
  (ref) => WidgetCreatorScreen(),
);

/// ---------------------------------------------------------------------------
/// VIEWMODEL
/// ---------------------------------------------------------------------------

class WidgetCreatorScreen extends StateNotifier<WidgetCreatorState> {
  WidgetCreatorScreen() : super(const WidgetCreatorState());

  final ScreenshotController screenshotController = ScreenshotController();
  final ImagePicker _picker = ImagePicker();

  void setWidgetType(KWidgetType type) {
    state = state.copyWith(selectedType: type);
  }

  void setNoteText(String text) {
    state = state.copyWith(noteText: text);
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    state = state.copyWith(imageFile: File(picked.path));
  }

  Future<void> exportSelectedWidget(BuildContext context) async {
    final type = state.selectedType;
    if (type == null) return;

    state = state.copyWith(exporting: true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Use a single widget ID for consistent HomeWidget data keys
      final widgetDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('widgets')
          .doc();

      final widgetId = widgetDoc.id;

      // Capture screenshot if needed
      final Uint8List? bytes = await screenshotController.capture(pixelRatio: 2.5);

      if (bytes == null) {
        SnackBarHelper.showError(context, 'Failed to capture widget');
        return;
      }

      // Save image locally
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;

      final file = File('${dir.path}/${type.name}_widget_$widgetId.png');
      await file.writeAsBytes(bytes);

      // Save widget info in Firestore
      await widgetDoc.set({
        'id': widgetId,
        'userId': user.uid,
        'type': type.name,
        'name': '${type.name} widget',
        'style': _resolveStyle(type),
        'data': _resolveData(type),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Save data for HomeWidget
      await HomeWidget.saveWidgetData('widget_image_$widgetId', file.path);

      // Save note text if this is a note widget
      if (type == KWidgetType.note) {
        final docId = widgetDoc.id;
        await HomeWidget.saveWidgetData('note_text_$docId', state.noteText);
        await HomeWidget.saveWidgetData('widget_mapping_$docId', docId);
      }

      // Trigger the widget update
      await HomeWidget.updateWidget(
        name: _androidWidgetName(type),
        androidName: _androidWidgetName(type),
      );

      SnackBarHelper.showSuccess(context, 'Widget created successfully!');
    } finally {
      state = state.copyWith(exporting: false);
    }
  }

  String _androidWidgetName(KWidgetType type) {
    switch (type) {
      case KWidgetType.clock:
        return 'ClockHomeWidget';
      case KWidgetType.note:
        return 'NoteHomeWidget';
    }
  }

  Map<String, dynamic> _resolveStyle(KWidgetType type) {
    switch (type) {
      case KWidgetType.clock:
        return {
          'backgroundColor': '#000000',
          'textColor': '#FFFFFF',
          'fontSize': 40,
        };
      case KWidgetType.note:
        return {
          'backgroundColor': '#FFF3B0',
          'textColor': '#000000',
        };
    }
  }

  Map<String, dynamic> _resolveData(KWidgetType type) {
    switch (type) {
      case KWidgetType.clock:
        return {'format': '24h'};
      case KWidgetType.note:
        return {'text': state.noteText};
    }
  }

}

/// ---------------------------------------------------------------------------
/// UI (COMBINED INSIDE SAME FILE)
/// ---------------------------------------------------------------------------

class WidgetCreator extends ConsumerWidget {
  const WidgetCreator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(widgetCreatorProvider);
    final creator = ref.read(widgetCreatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Widget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Widget Type Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: KWidgetType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: state.selectedType == type,
                  onSelected: (_) => creator.setWidgetType(type),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            /// Note input field (only for note widget)
            if (state.selectedType == KWidgetType.note) ...[
              TextField(
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your note here',
                ),
                onChanged: (value) => creator.setNoteText(value),
              ),
              const SizedBox(height: 16),
            ],

            /// Preview
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Screenshot(
                  controller: creator.screenshotController,
                  child: _buildPreview(state),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: state.exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.widgets),
                label: const Text('Create Widget'),
                onPressed: state.exporting
                    ? null
                    : () => creator.exportSelectedWidget(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(WidgetCreatorState state) {
    switch (state.selectedType) {
      case KWidgetType.clock:
        return ClockPreview(
          style: const {
            'backgroundColor': '#000000',
            'textColor': '#FFFFFF',
            'fontSize': 40,
          },
          data: const {'format': '24h'},
        );

      case KWidgetType.note:
        return NotePreview(
          style: const {
            'backgroundColor': '#FFF3B0',
            'textColor': '#000000',
          },
          data: {'text': state.noteText.isEmpty ? 'Your note displays here' : state.noteText},
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class ClockPreview extends StatelessWidget {
  final Map<String, dynamic> style;
  final Map<String, dynamic> data;

  const ClockPreview({
    super.key,
    required this.style,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = _resolveTime();
    final String format = data['format'] ?? 'HH:mm';
    final bool showSeconds = data['showSeconds'] ?? false;

    final Color backgroundColor =
        _parseColor(style['backgroundColor'], Colors.black);
    final Color textColor =
        _parseColor(style['textColor'], Colors.white);

    final double fontSize =
        (style['fontSize'] ?? 36).toDouble();
    final FontWeight fontWeight =
        _parseFontWeight(style['fontWeight']);

    final BorderRadius radius =
        BorderRadius.circular((style['borderRadius'] ?? 16).toDouble());

    final String timeText = _formatTime(
      now,
      format,
      showSeconds,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Text(
        timeText,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  DateTime _resolveTime() {
    final String timezone = data['timezone'] ?? 'local';
    if (timezone == 'utc') {
      return DateTime.now().toUtc();
    }
    return DateTime.now();
  }

  String _formatTime(
    DateTime time,
    String format,
    bool showSeconds,
  ) {
    String two(int n) => n.toString().padLeft(2, '0');

    if (format == '12h') {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final suffix = time.hour >= 12 ? 'PM' : 'AM';
      final seconds = showSeconds ? ':${two(time.second)}' : '';
      return '$hour:${two(time.minute)}$seconds $suffix';
    }

    final seconds = showSeconds ? ':${two(time.second)}' : '';
    return '${two(time.hour)}:${two(time.minute)}$seconds';
  }

  Color _parseColor(dynamic value, Color fallback) {
    if (value is String && value.startsWith('#')) {
      return Color(
        int.parse(value.replaceFirst('#', '0xff')),
      );
    }
    return fallback;
  }

  FontWeight _parseFontWeight(dynamic value) {
    switch (value) {
      case 'bold':
        return FontWeight.bold;
      case 'w600':
        return FontWeight.w600;
      case 'w300':
        return FontWeight.w300;
      default:
        return FontWeight.normal;
    }
  }
}

class NotePreview extends StatelessWidget {
  final Map<String, dynamic> style;
  final Map<String, dynamic> data;

  const NotePreview({
    super.key,
    required this.style,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final String text = data['text'] ?? '';
    final String align = style['textAlign'] ?? 'left';

    final Color backgroundColor =
        _parseColor(style['backgroundColor'], Colors.yellow.shade200);
    final Color textColor =
        _parseColor(style['textColor'], Colors.black);

    final double fontSize =
        (style['fontSize'] ?? 16).toDouble();

    final FontWeight fontWeight =
        _parseFontWeight(style['fontWeight']);

    final BorderRadius radius =
        BorderRadius.circular((style['borderRadius'] ?? 16).toDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      alignment: _parseAlignment(align),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        textAlign: _parseTextAlign(align),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _parseColor(dynamic value, Color fallback) {
    if (value is String && value.startsWith('#')) {
      return Color(
        int.parse(value.replaceFirst('#', '0xff')),
      );
    }
    return fallback;
  }

  FontWeight _parseFontWeight(dynamic value) {
    switch (value) {
      case 'bold':
        return FontWeight.bold;
      case 'w600':
        return FontWeight.w600;
      case 'w300':
        return FontWeight.w300;
      default:
        return FontWeight.normal;
    }
  }

  Alignment _parseAlignment(String align) {
    switch (align) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  TextAlign _parseTextAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }
}
