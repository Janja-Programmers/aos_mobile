import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/features/auth/data/auth_remote_datasource.dart';
import 'package:africaonlinestores/features/auth/data/auth_repository_impl.dart';
import 'package:africaonlinestores/features/auth/domain/auth_repository.dart';
import 'package:africaonlinestores/features/auth/domain/get_current_user_usecase.dart';
import 'package:africaonlinestores/features/auth/domain/login_usecase.dart';
import 'package:africaonlinestores/features/auth/domain/logout_usecase.dart';
import 'package:africaonlinestores/features/auth/domain/register_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dependency Injection setup for Auth feature
/// Provides all auth-related dependencies using Riverpod

// ─────────────────────────────────────────────────────────
// DATA LAYER
// ─────────────────────────────────────────────────────────

/// Provides the remote datasource
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDatasourceImpl(apiClient);
});

// ─────────────────────────────────────────────────────────
// DOMAIN LAYER - REPOSITORY
// ─────────────────────────────────────────────────────────

/// Provides the auth repository implementation
/// This is the gateway between domain and data layers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDatasource);
});

// ─────────────────────────────────────────────────────────
// DOMAIN LAYER - USE CASES
// ─────────────────────────────────────────────────────────

/// Provides the login use case
final loginUsecaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provides the register use case
final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Provides the logout use case
final logoutUsecaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Provides the get current user use case
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});
