import 'package:firebase_core/firebase_core.dart';

class FireBaseCoreHelper {
  Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
