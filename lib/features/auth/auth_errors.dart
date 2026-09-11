import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_models.dart';

/// Generic copy: never reveal whether the email exists.
const kAuthFailedMessage = 'Correo o contraseña incorrectos';
const kAuthOfflineMessage =
    'No hay red. Revisa la conexión e intenta de nuevo.';
const kAuthDisabledMessage = 'Cuenta no habilitada';
const kAuthMissingConfigMessage =
    'Falta configuración del servidor. Compila con SUPABASE_ANON_KEY.';
const kAuthOrphanProfileMessage =
    'Tu cuenta no tiene perfil. Contacta a un administrador.';

String mapAuthFailure(Object error) {
  if (error is AuthAppException) {
    return error.message;
  }
  if (error is AuthException) {
    return kAuthFailedMessage;
  }
  return kAuthOfflineMessage;
}
