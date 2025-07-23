import 'package:app/core/errors/failure_keys.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

String translateFailureKey(BuildContext context, FailureKey key) {
  final l10n = AppLocalizations.of(context)!;

  return switch (key) {
    FailureKey.subtaskNotFound        => l10n.subTaskNotFound,
    FailureKey.attachmentError        => l10n.attachmentError,
    FailureKey.taskNotFound           => l10n.taskNotFound,
    FailureKey.categoryNotFound       => l10n.categoryNotFound,
    FailureKey.duplicatedUser         => l10n.duplicatedUser,
    FailureKey.invalidCredentials     => l10n.invalidCredentials,
    FailureKey.invalidToken           => l10n.invalidToken,
    FailureKey.userNotVerified        => l10n.userNotVerified,
    FailureKey.userNotFound           => l10n.userNotFound,
    FailureKey.connectionServerError  => l10n.connectionServerError,
    FailureKey.generalServerError     => l10n.generalServerError,
    FailureKey.passwordAreNotTheSame  => l10n.passwordAreNotTheSame,
    FailureKey.generalUnexpectedError => l10n.generalUnexpectedError,
  };
}
