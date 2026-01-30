import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../utils/snackbar_helper.dart';

class ClockWidgetCreator {
  static Future<void> saveUserIdolImage(String originalPath) async {
    try {
      if (originalPath.isEmpty) {
        await HomeWidget.saveWidgetData<String>('clock_image', '');
        await HomeWidget.updateWidget(
          androidName: 'ClockWidgetProvider',
          name: 'ClockWidgetProvider',
        );
        debugPrint('🗑️ Idol image removed');
        return;
      }

      final originalFile = File(originalPath);
      if (!originalFile.existsSync()) {
        throw Exception('Original image does not exist');
      }

      final bytes = await originalFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      const int maxSize = 160;
      final resizedImage = img.copyResize(
        decodedImage,
        width: maxSize,
        height: maxSize,
        interpolation: img.Interpolation.average,
      );

      final directory = await getApplicationSupportDirectory();
      final resizedFile = File('${directory.path}/clock_idol.png');

      await resizedFile.writeAsBytes(img.encodePng(resizedImage, level: 6));

      await HomeWidget.saveWidgetData<String>('clock_image', resizedFile.path);
      await HomeWidget.updateWidget(
        androidName: 'ClockWidgetProvider',
        name: 'ClockWidgetProvider',
      );

      debugPrint('🖼️ Idol image saved: ${resizedFile.path}');
    } catch (e) {
      debugPrint('❌ Failed to save idol image: $e');
    }
  }
}

class ClockWidgetCreatorButton extends StatefulWidget {
  const ClockWidgetCreatorButton({super.key});

  @override
  State<ClockWidgetCreatorButton> createState() => _ClockWidgetCreatorButtonState();
}

class _ClockWidgetCreatorButtonState extends State<ClockWidgetCreatorButton> {
  String _time = "--:--:--";
  String _date = "----";
  File? _idolImage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    _updateClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();

    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      _time =
          '${hour12.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')} $amPm';

      _date =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year} '
          '(${["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][now.weekday % 7]})';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final pickedFile = File(pickedImage.path);

      setState(() {
        _idolImage = pickedFile;
      });

      await ClockWidgetCreator.saveUserIdolImage(pickedFile.path);

      await HomeWidget.updateWidget(
        androidName: 'ClockWidgetProvider',
        name: 'ClockWidgetProvider',
      );

      SnackBarHelper.showSuccess(context, 'Idol image updated!');
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _idolImage = null;
    });

    await ClockWidgetCreator.saveUserIdolImage('');

    await HomeWidget.updateWidget(
      androidName: 'ClockWidgetProvider',
      name: 'ClockWidgetProvider',
    );

    SnackBarHelper.showError(context, 'Idol image removed!');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clock Widget Preview")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[800],
                          image: _idolImage != null
                              ? DecorationImage(
                                  image: FileImage(_idolImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _idolImage == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),

                      if (_idolImage != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text("Pick Idol Image"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
