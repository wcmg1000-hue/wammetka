import 'auth_models.dart';

/// Client-side mirror of RLS. Server trigger is the source of truth.
abstract final class AuthPolicy {
  static const AppRole publicRegisterRole = AppRole.cliente;

  static bool canSelfRegisterAs(AppRole role) => role == AppRole.cliente;

  static bool canCreatePedido(AppRole role) => role == AppRole.cliente;

  static bool canAcceptPedido(AppRole role) =>
      role == AppRole.comercio || role == AppRole.admin;

  static bool canChangeOwnRole(AppRole actor) => actor == AppRole.admin;
}
