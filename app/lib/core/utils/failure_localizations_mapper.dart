import 'package:flutter/material.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/domain/exceptions/auth_failures.dart';
import 'package:app/l10n/app_localizations.dart';

// Função que mapeia uma Failure para uma String traduzida no idioma configurado
String mapFailureToLocalizationMessage(BuildContext context, Failure failure) {
  // Idioma atual
  final l10n = AppLocalizations.of(context)!;


  // switch expression do Dart 3, ou switch statement
  // Aqui quando colocamos um InvalidCredentialsFailure() => o Dart já verifica se (failure) é desse tipo
  // e logo após destrói esse objeto para não ocupar memória.
  return switch (failure) {
    DuplicatedEmailFailure()       => l10n.duplicatedUser,
    InvalidCredentialsFailure()    => l10n.invalidCredentials,
    InvalidOrExpiredTokenFailure() => l10n.invalidToken,
    UserNotVerifiedFailure()       => l10n.userNotVerified,
    UserNotFoundFailure()          => l10n.userNotFound,
    NoConnectionFailure()          => l10n.connectionServerError,
    ServerFailure()                => l10n.generalServerError,
    PasswordsAreNotSameFailure()   => l10n.passwordAreNotTheSame,
    UnexpectedFailure()            => l10n.generalUnexpectedError,
    _                              => l10n.generalUnexpectedError,
  };
}