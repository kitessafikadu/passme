import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/profile_model.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_datasource.dart';

/// -------------------------
/// Profile Events
/// -------------------------
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateUsername extends ProfileEvent {
  final String newUsername;

  UpdateUsername(this.newUsername);
}

class UpdatePassword extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  UpdatePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

/// -------------------------
/// Profile States
/// -------------------------
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class UsernameUpdated extends ProfileState {}

class PasswordUpdated extends ProfileState {}

/// -------------------------
/// Profile Bloc
/// -------------------------
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRemoteDataSource dataSource;

  ProfileBloc(this.dataSource) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdatePassword>(_onUpdatePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await dataSource.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile'));
    }
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await dataSource.updateUsername(event.newUsername);
      emit(UsernameUpdated());
      add(LoadProfile());
    } catch (e) {
      emit(ProfileError('Failed to update username'));
    }
  }

  Future<void> _onUpdatePassword(
    UpdatePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await dataSource.updatePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(PasswordUpdated());
    } catch (e) {
      emit(ProfileError('Failed to update password'));
    }
  }
}
