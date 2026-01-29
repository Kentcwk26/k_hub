import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:home_widget/home_widget.dart';

import '../utils/snackbar_helper.dart';

final noteWidgetProvider = StateNotifierProvider<NoteWidgetVM, String>((ref) {
  return NoteWidgetVM();
});

class NoteWidgetVM extends StateNotifier<String> {
  NoteWidgetVM() : super('');

  void setText(String value) {
    state = value;
  }

  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final widgetId = await HomeWidget.getWidgetData<int>('current_widget_id');

    if (widgetId == null) {
      throw Exception('Widget ID not found');
    }

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
          'text': state,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Widget ID not found')),
      );
      return;
    }

    await HomeWidget.saveWidgetData(
      'note_text_$widgetId',
      state,
    );

    await HomeWidget.updateWidget(
      androidName: 'NoteHomeWidget',
      name: 'NoteHomeWidget',
    );

    await saveToFirestore();
    SnackBarHelper.showSuccess(context, 'Note widget updated');

  }
}

class NoteWidgetCreator extends ConsumerWidget {
  const NoteWidgetCreator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteWidgetProvider);
    final vm = ref.read(noteWidgetProvider.notifier);

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => vm.saveToWidget(context),
                child: const Text('Save to Widget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}