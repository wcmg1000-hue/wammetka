import 'auth_models.dart';

/// Client-side mirror of RLS. Server trigger is the source of truth.
abstract final class AuthPolicy {
  static const AppRole publicRegisterRole = AppRole.cliente;

  static bool canSelfRegisterAs(AppRole role) => role == AppRole.cliente;

  static bool canCreatePedido(AppRole role) => role == AppRole.cliente;

  static bool canAcceptPedido(AppRole role) =>
      role == AppRole.comercio || role == AppRole.admin;

  static bool canChangeOwnRole(AppRole actor) => actor == AppRole.admin;

  static bool canReadForeignPedidos(AppRole role) =>
      role == AppRole.admin || role == AppRole.operacion;

  static bool canAcceptServicio(AppRole role) => role == AppRole.repartidor;

  static bool canMarkEntregado(AppRole role) => role == AppRole.repartidor;

  static bool canSeeComisionWammetka(AppRole role) =>
      role == AppRole.admin ||
      role == AppRole.finanzas ||
      role == AppRole.operacion;
}
