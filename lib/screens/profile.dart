import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/date_formatter.dart';
import '../utils/image_responsive.dart';
import '../widgets/app_drawer.dart';

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(UserRepository());
});

class ProfileState {
  final bool loading;
  final AppUsers? user;

  const ProfileState({this.loading = true, this.user});

  ProfileState copyWith({bool? loading, AppUsers? user}) {
    return ProfileState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel(this._repo) : super(const ProfileState()) {
    load();
  }

  final UserRepository _repo;

  Future<void> load() async {
    final user = await _repo.getCurrentUser();
    state = state.copyWith(loading: false, user: user);
  }

  Future<void> updateProfile(AppUsers updated) async {
    await _repo.updateUser(updated);
    state = state.copyWith(user: updated);
  }

  Future<String> uploadPhoto(File file, String userId) async {
    final ref = FirebaseStorage.instance.ref().child(
      'profile/profile_$userId${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final snap = await ref.putFile(file);
    return snap.ref.getDownloadURL();
  }
}

class ProfileScreen extends ConsumerWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final vm = ref.read(profileViewModelProvider.notifier);

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = state.user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SafeAvatar(url: user.photoUrl, size: 120),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );
                    if (updated == true) vm.load();
                  },
                )
              ],
            ),

            _tile("Email", user.email, Icons.email),
            _tile("Contact", user.contact, Icons.phone),
            _tile("Gender", user.gender, Icons.person),
            _tile(
              "Created",
              DateFormatter.fullDateTime(user.creationDateTime),
              Icons.calendar_month,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  final AppUsers user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late String name;
  late String contact;
  late String gender;
  late String photoUrl;
  bool saving = false;
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    name = widget.user.name;
    contact = widget.user.contact;
    gender = widget.user.gender;
    photoUrl = widget.user.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(profileViewModelProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        if (!isDirty || saving) return true;

        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Discard changes?"),
            content: const Text(
              "You have unsaved changes. If you leave now, they will be lost.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Discard",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
              floatingLabelStyle: const TextStyle(color: Colors.red),
              prefixIconColor: Colors.red,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 10.0,
              children: [
                Stack(
                  children: [
                    SafeAvatar(url: photoUrl, size: 150),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.black87,
                          iconSize: 20,
                          onPressed: saving
                              ? null
                              : () async {
                                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (picked == null) return;

                                  setState(() => saving = true);

                                  final uploadedUrl = await vm.uploadPhoto(
                                    File(picked.path),
                                    widget.user.userId,
                                  );

                                  setState(() {
                                    photoUrl = uploadedUrl;
                                    saving = false;
                                    isDirty = true;
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                ),

                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: name,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          onChanged: (v) {
                            name = v;
                            isDirty = true;
                          },
                        ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Email cannot be changed. Contact support if needed."),
                              ),
                            );
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              initialValue: widget.user.email,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: contact,
                          decoration: const InputDecoration(
                            labelText: "Contact Number",
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          onChanged: (v) {
                            contact = v;
                            isDirty = true;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: ['Male', 'Female'].contains(gender) ? gender : 'Male',
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            prefixIcon: Icon(Icons.wc_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: "Male", child: Text("Male")),
                            DropdownMenuItem(value: "Female", child: Text("Female")),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                gender = v;
                                isDirty = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);

                            await vm.updateProfile(
                              widget.user.copyWith(
                                name: name.trim(),
                                contact: contact.trim(),
                                gender: gender,
                                photoUrl: photoUrl,
                              ),
                            );

                            if (mounted) Navigator.pop(context, true);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}