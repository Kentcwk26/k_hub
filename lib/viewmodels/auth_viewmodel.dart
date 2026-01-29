import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../screens/adminstrators/adminstrator.dart';
import '../screens/home.dart';
import '../screens/login.dart';
import '../repositories/auth_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref);
});

class AuthState {
  final bool loading;
  final AppUsers? user;

  const AuthState({this.loading = false, this.user});

  AuthState copyWith({bool? loading, AppUsers? user}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final Ref ref;
  late final StreamSubscription<User?> _authSub;

  final authRepositoryProvider = Provider<AuthRepository>((ref) {
    return AuthRepository();
  });

  AuthViewModel(this.ref)
      : super(const AuthState(loading: true)) {
    _listen();
  }

  void _listen() {
    final repo = ref.read(authRepositoryProvider);

    _authSub = repo.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthState(user: null, loading: false);
        return;
      }

      final doc = await repo.getUserDoc(firebaseUser.uid);
      final data = doc.data()!;

      final appUser = AppUsers.fromMap(data, firebaseUser.uid);

      state = AuthState(
        user: appUser,
        loading: false,
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loading: true);
    await ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}