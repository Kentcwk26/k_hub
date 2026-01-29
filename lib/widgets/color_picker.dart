import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorPickerDialog extends ConsumerWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Color> presetColors = [
      const Color(0xFFf0d87f), // Default Gold
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      Colors.black,
      Colors.white,
    ];

    return AlertDialog(
      title: const Text('Choose a Color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preset Colors
            const Text('Preset Colors', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetColors.map((color) {
                return GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color == currentColor ? Colors.black : Colors.grey,
                        width: color == currentColor ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Custom Color Picker
            const Text('Custom Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ColorPicker(
              color: currentColor,
              onColorChanged: onColorSelected,
              pickerColor: currentColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final Color pickerColor;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    required this.pickerColor,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        Slider(
          value: _currentColor.red.toDouble(),
          min: 0,
          max: 255,
          onChanged: (value) {
            setState(() {
              _currentColor = _currentColor.withRed(value.toInt());
            });
            widget.onColorChanged(_currentColor);
          },
        ),
        Slider(
          value: _currentColor.green.toDouble(),
          min: 0,
          max: 255,
          onChanged: (value) {
            setState(() {
              _currentColor = _currentColor.withGreen(value.toInt());
            });
            widget.onColorChanged(_currentColor);
          },
        ),
        Slider(
          value: _currentColor.blue.toDouble(),
          min: 0,
          max: 255,
          onChanged: (value) {
            setState(() {
              _currentColor = _currentColor.withBlue(value.toInt());
            });
            widget.onColorChanged(_currentColor);
          },
        ),
      ],
    );
  }
}