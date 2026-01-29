import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/snackbar_helper.dart';
import '../utils/date_formatter.dart';

class MyCreations extends StatelessWidget {
  const MyCreations({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Creations'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.image), text: 'Wallpapers'),
              Tab(icon: Icon(Icons.widgets), text: 'Widgets'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyWallpapers(),
            MyWidgets(),
          ],
        ),
      ),
    );
  }
}

class MyWallpapers extends StatelessWidget {
  const MyWallpapers({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your creations')),
      );
    }

    final wallpapersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallpapers')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: wallpapersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No wallpapers yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final imageUrl = doc['imageUrl'];

              return _WallpaperTile(
                imageUrl: imageUrl,
                docId: doc.id,
                createdAt: DateFormatter.formatShortDate(doc['createdAt']),
                onDelete: () async {
                  await _deleteWallpaper(
                    context: context,
                    docId: doc.id,
                    imageUrl: imageUrl,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteWallpaper({
    required BuildContext context,
    required String docId,
    required String imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete wallpaper?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallpapers')
        .doc(docId)
        .delete();

    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();

    SnackBarHelper.showSuccess(context, 'Wallpaper deleted successfully');
  }
}

class _WallpaperTile extends StatelessWidget {
  final String imageUrl;
  final String docId;
  final String createdAt;
  final VoidCallback onDelete;

  const _WallpaperTile({
    required this.imageUrl,
    required this.docId,
    required this.createdAt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWallpaperDetails(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWallpaperDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Wallpaper Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $docId'),
            const SizedBox(height: 8),
            Text('Created: $createdAt'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save to gallery / set wallpaper
              Navigator.pop(context);
            },
            child: const Text('Extract', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class MyWidgets extends StatelessWidget {
  const MyWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your widgets')),
      );
    }

    final widgetsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('widgets')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: widgetsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No widgets created yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _WidgetTile(
                type: data['type'],
                name: data['widgetId'],
                widgetId: doc.id,
                createdAt: DateFormatter.formatShortDate(data['createdAt']),
              );
            },
          );
        },
      ),
    );
  }
}

class _WidgetTile extends StatelessWidget {
  final String type;
  final String name;
  final String widgetId;
  final String createdAt;

  const _WidgetTile({
    required this.type,
    required this.name,
    required this.widgetId,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWidgetDetails(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 12),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              type.toUpperCase(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidgetDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Widget Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name'),
            const SizedBox(height: 6),
            Text('Created: $createdAt'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              // Save the widget locally
              await prefs.setString(
                'extracted_widget_$widgetId',
                jsonEncode({
                  'id': widgetId,
                  'type': type,
                  'name': name,
                  'createdAt': createdAt,
                }),
              );

              const channel = MethodChannel('widget_extractor');
              try {
                final result = await channel.invokeMethod('extractNoteWidget');
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Widget extracted to Home screen')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to extract widget')),
                  );
                }
              } on PlatformException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Extract'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case 'clock':
        return const Icon(Icons.access_time, size: 48);
      case 'note':
        return const Icon(Icons.note, size: 48);
      case 'image':
        return const Icon(Icons.image, size: 48);
      default:
        return const Icon(Icons.widgets, size: 48);
    }
  }
}