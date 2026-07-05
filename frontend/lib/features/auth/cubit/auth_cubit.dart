import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_services.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());
      print('Get User Data Started');
      final userModel = await authRemoteRepository.getUserData();
      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);

        print('Get User Data Sync Success');
        emit(AuthLoggedIn(userModel));
      } else {
        print('Get User Data Initial');
        emit(AuthInitial());
      }
    } catch (e) {
      print('Get User Data Error $e');
      emit(AuthInitial());
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      print('Sign Up Start');
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      print('Sign Up End -- Successfully');
      emit(AuthSignUp());
    } catch (e) {
      print('Sign Up Error');
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      print('Login Start');
      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }
      print('Login End -- Insert User');
      await authLocalRepository.insertUser(userModel);
      emit(AuthLoggedIn(userModel));
      print('Login End -- Successfully');
    } catch (e) {
      print('Login Error');
      emit(AuthError(e.toString()));
    }
  }
}
