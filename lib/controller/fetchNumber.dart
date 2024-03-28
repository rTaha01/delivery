import 'package:firebase_auth/firebase_auth.dart';

String? currentUserPhoneNumber() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.phoneNumber;
}
