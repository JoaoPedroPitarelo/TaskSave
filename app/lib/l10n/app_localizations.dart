import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @welcomeText.
  ///
  /// In pt, this message translates to:
  /// **'Salvando seus afazeres e compromissos do esquecimento...'**
  String get welcomeText;

  /// No description provided for @addYourTask.
  ///
  /// In pt, this message translates to:
  /// **'Adicione suas tarefas!'**
  String get addYourTask;

  /// No description provided for @makeCakeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comprar ingredientes bolo'**
  String get makeCakeTitle;

  /// No description provided for @makeCakeDescription.
  ///
  /// In pt, this message translates to:
  /// **'1kg de farinha de trigo, 1L de óleo, 1 fermento biológico'**
  String get makeCakeDescription;

  /// No description provided for @walkWithMyDogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Caminhar com meu cachorro'**
  String get walkWithMyDogTitle;

  /// No description provided for @walkWithMyDogDescription.
  ///
  /// In pt, this message translates to:
  /// **'Caminhar com meu cachorro Tom hoje'**
  String get walkWithMyDogDescription;

  /// No description provided for @finishMathWorkTile.
  ///
  /// In pt, this message translates to:
  /// **'Terminar trabalho de matemática'**
  String get finishMathWorkTile;

  /// No description provided for @finishMathWorkDescription.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar como fazer raíz quadrada e fazer os exercícios da apostila de matematica do professor'**
  String get finishMathWorkDescription;

  /// No description provided for @createYourCategories.
  ///
  /// In pt, this message translates to:
  /// **'Crie suas categorias!'**
  String get createYourCategories;

  /// No description provided for @university.
  ///
  /// In pt, this message translates to:
  /// **'Faculdade'**
  String get university;

  /// No description provided for @personal.
  ///
  /// In pt, this message translates to:
  /// **'Pessoal'**
  String get personal;

  /// No description provided for @job.
  ///
  /// In pt, this message translates to:
  /// **'Trabalho'**
  String get job;

  /// No description provided for @lobby.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get lobby;

  /// No description provided for @notified.
  ///
  /// In pt, this message translates to:
  /// **'Seja Notificado!'**
  String get notified;

  /// No description provided for @titleTask.
  ///
  /// In pt, this message translates to:
  /// **'Eai, bora começar?'**
  String get titleTask;

  /// No description provided for @descriptionTask.
  ///
  /// In pt, this message translates to:
  /// **'Organizar suas tarefas nunca foi tão fácil!'**
  String get descriptionTask;

  /// No description provided for @taskCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Completar tarefa...'**
  String get taskCompleted;

  /// No description provided for @enterEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get enterEmail;

  /// No description provided for @enterEmailExample.
  ///
  /// In pt, this message translates to:
  /// **'fulano@email.com'**
  String get enterEmailExample;

  /// No description provided for @enterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha:'**
  String get enterPassword;

  /// No description provided for @confirmPassoword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassoword;

  /// No description provided for @forgetPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu sua senha?'**
  String get forgetPassword;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem uma conta? '**
  String get dontHaveAccount;

  /// No description provided for @createNow.
  ///
  /// In pt, this message translates to:
  /// **'Crie agora!'**
  String get createNow;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro'**
  String get register;

  /// No description provided for @registerButton.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar-se'**
  String get registerButton;

  /// No description provided for @emailIsObrigatoryValue.
  ///
  /// In pt, this message translates to:
  /// **'Email é um campo obrigatório'**
  String get emailIsObrigatoryValue;

  /// No description provided for @passwordIsObrigatoryValue.
  ///
  /// In pt, this message translates to:
  /// **'Senha é um campo obrigatório'**
  String get passwordIsObrigatoryValue;

  /// No description provided for @minimumLengthPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 8 caracteres'**
  String get minimumLengthPassword;

  /// No description provided for @minimumEspecialCaractere.
  ///
  /// In pt, this message translates to:
  /// **'Mínino de 1 caractere especial'**
  String get minimumEspecialCaractere;

  /// No description provided for @minimumCapitalLetter.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 1 caractere maiúsculo'**
  String get minimumCapitalLetter;

  /// No description provided for @minimumDigit.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 1 número'**
  String get minimumDigit;

  /// No description provided for @duplicatedUser.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um usuário com esse e-mail!'**
  String get duplicatedUser;

  /// No description provided for @unknownError.
  ///
  /// In pt, this message translates to:
  /// **'Erro desconhecido :('**
  String get unknownError;

  /// No description provided for @userNotVerified.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não verificado! Por favor veja sua caixa de e-mail'**
  String get userNotVerified;

  /// No description provided for @good.
  ///
  /// In pt, this message translates to:
  /// **'Boa!'**
  String get good;

  /// No description provided for @loginSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Login realizado com sucesso!'**
  String get loginSuccess;

  /// No description provided for @confirmEmail.
  ///
  /// In pt, this message translates to:
  /// **'Agora confirme seu E-mail!'**
  String get confirmEmail;

  /// No description provided for @passwordAreNotTheSame.
  ///
  /// In pt, this message translates to:
  /// **'As senha não são iguais!'**
  String get passwordAreNotTheSame;

  /// No description provided for @invalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos!'**
  String get invalidCredentials;

  /// No description provided for @invalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get invalidEmail;

  /// No description provided for @connectionServerError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão com o servidor'**
  String get connectionServerError;

  /// No description provided for @generalServerError.
  ///
  /// In pt, this message translates to:
  /// **'Erro interno do servidor'**
  String get generalServerError;

  /// No description provided for @generalUnexpectedError.
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado'**
  String get generalUnexpectedError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
