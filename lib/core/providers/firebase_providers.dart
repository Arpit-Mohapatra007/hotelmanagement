import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authStateProvider = StreamProvider<User?>((ref){
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref){
  final currentUser = ref.watch(authStateProvider).value;
  return currentUser;
});

