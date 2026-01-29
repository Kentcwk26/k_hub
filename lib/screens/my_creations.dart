import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:k_hub/utils/snackbar_helper.dart';

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

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wallpapers')
        .doc(docId)
        .delete();

    // Delete from Storage
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();

    SnackBarHelper.showSuccess(context, 'Wallpaper deleted successfully');
  }
}

class _WallpaperTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDelete;

  const _WallpaperTile({
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
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
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
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
                type: data['type'] as String,
                name: data['name'] as String,
                createdAt: DateTime.parse(data['createdAt']),
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
  final DateTime createdAt;

  const _WidgetTile({
    required this.type,
    required this.name,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
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