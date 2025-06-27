import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamia/data/models/user/user_model.dart';

class AuthResult {
  final User user;
  final UserModel? userModel;
  final bool isNewUser;

  const AuthResult({
    required this.user,
    this.userModel,
    this.isNewUser = false,
  });
}