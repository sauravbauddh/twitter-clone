import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/auth/view/signup_view.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';
import 'package:twitter_clone/models/user_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) {
    return AuthController(
      authAPI: ref.watch(authApiProvider),
      userAPI: ref.watch(userAPIProvider),
    );
  },
);

final currentUserDetailsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(currentUserAccountProvider).when(
        data: (data) {
          if (data != null) {
            final currentUserId = data.$id;
            final userDetails = ref.watch(
              userDetailsProvider(currentUserId),
            );
            return userDetails.value;
          } else {
            ref.invalidate(currentUserAccountProvider);
          }
          return null;
        },
        error: (error, st) => null,
        loading: () => null,
      );
});

final currentUserAccountProvider = FutureProvider.autoDispose((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  final res = authController.currentUser();
  res.asStream().listen((account) {
    debugPrint('LoggedInAccount:-  $account');
  });
  return res;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return await authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
      : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  //state = isLoading

  Future<User?> currentUser() => _authAPI.currentUserAccount();

  void signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    state = true;
    final response = await _authAPI.signUp(email: email, password: password);
    state = false;
    response.fold((l) => showSnackBar(context, l.message), (r) async {
      UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: "",
          bannerPic: "",
          uid: r.$id,
          bio: "",
          isTwitterBlue: false);
      final res = await _userAPI.saveUserData(userModel);
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Account created! Please login");
        Navigator.push(
          context,
          LoginView.route(),
        );
      });
    });
  }

  void login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    state = true;
    final response = await _authAPI.login(email: email, password: password);
    state = false;
    response.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        Navigator.push(context, HomeView.route());
      },
    );
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final updatedUser = UserModel.fromMap(document.data);
    return updatedUser;
  }

  Future<void> logout(BuildContext context) async {
    final res = await _authAPI.logout();
    res.fold(
      (l) => null,
      (r) => Navigator.pushAndRemoveUntil(
          context, SignUpView.route(), (route) => false),
    );
  }
}
