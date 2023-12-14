import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';

final authApiProvider = Provider(
  (ref) {
    final account = ref.watch(appwriteAccountProvider);
    return AuthAPI(
      account: account,
    );
  },
);

abstract class IAuthAPI {
  FutureEither<User> signUp({required String email, required String password});
  FutureEither<Session> login(
      {required String email, required String password});
  Future<User?> currentUserAccount();
}

class AuthAPI implements IAuthAPI {
  final Account _account;

  AuthAPI({required Account account}) : _account = account;

  @override
  FutureEither<User> signUp(
      {required String email, required String password}) async {
    try {
      final User account = await _account.create(
          userId: ID.unique(), email: email, password: password);
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      print(e.message);
      return left(
          Failure(e.message ?? "Some unexpected error occoured", stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<Session> login(
      {required String email, required String password}) async {
    try {
      final session =
          await _account.createEmailSession(email: email, password: password);
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? "Some unexpected error occurred", stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<User?> currentUserAccount() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (e) {
      print("AppwriteException occurred: ${e.message}");
      return null;
    } catch (e, stackTrace) {
      print("Unexpected error occurred: $e");
      print(stackTrace);
      return null;
    }
  }
}
