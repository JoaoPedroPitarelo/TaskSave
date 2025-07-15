
import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/providers/app_preferences_provider.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/screens/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {


  @override
  Widget build(BuildContext context) {
    final preferencesProvider = context.watch<AppPreferencesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final appColors = AppGlobalColors.of(context);

    final userEmail = authProvider.user?.login ?? "";

    Map<String, String> keyToLanguage = {
      'en': AppLocalizations.of(context)!.english,
      'pt': AppLocalizations.of(context)!.portuguese,
      'es': AppLocalizations.of(context)!.espanish
    };

    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 12, 43, 170),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
            )
          ),
          title: Text(
            AppLocalizations.of(context)!.config,
            style: GoogleFonts.sansitaSwashed(
              color: Colors.white,
              fontSize: 30
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          spacing: 30,
          children: [
            Container(
              decoration: BoxDecoration(
                color: appColors.welcomeScreenCardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 3),blurRadius: 3)]
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.account,
                          style: GoogleFonts.roboto(
                            fontSize: 25,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        Icon(Icons.account_circle_outlined, size: 35)
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userEmail,
                          style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _logoutConfirmDialog()
                          );
                        },
                        icon: Icon(
                          Icons.login_rounded,
                          size: 34,
                        )
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: appColors.welcomeScreenCardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 3),blurRadius: 3)]
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.language,
                          style: GoogleFonts.roboto(
                            fontSize: 25,
                            fontWeight: FontWeight.w400
                         ),
                        ),
                        Icon(Icons.language_outlined, size: 35),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 15,
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.language}:",
                              style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            Text(
                              keyToLanguage[preferencesProvider.appLanguage.languageCode]!,
                              style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                        DropdownButton(
                          elevation: 2,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          alignment: Alignment.center,
                          dropdownColor: const Color.fromARGB(255, 12, 43, 170),
                          borderRadius: BorderRadius.circular(20),
                          items: AppLocalizations.supportedLocales.map((Locale locale) {
                            return DropdownMenuItem<Locale>(
                              value: locale,
                              child: Text(keyToLanguage[locale.languageCode]!),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            await preferencesProvider.setAppLanguage(value!);
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: appColors.welcomeScreenCardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 3),blurRadius: 3)]
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.theme,
                          style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                        Icon(Icons.color_lens_outlined, size: 35),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.darkMode,
                          style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                        Switch(
                          value: preferencesProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) async {
                            await preferencesProvider.toggleTheme(isDark: value);
                          },
                        )
                      ]
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: appColors.welcomeScreenCardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(0, 3),blurRadius: 3)]
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 200,
                                child: Image.asset(appColors.taskSaveLogo!)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 40,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _launchURL("https://github.com/JoaoPedroPitarelo/TaskSave");
                                },
                                icon: FaIcon(FontAwesomeIcons.github, size: 35)
                            ),
                            IconButton(
                                onPressed: () {
                                  _launchURL("http://www.linkedin.com/in/joão-pedro-salmazo-pitarelo-b12b71264");
                                },
                                icon: FaIcon(FontAwesomeIcons.linkedin, size: 35)
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 12, 43, 170),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "V 0.0",
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.credits,
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            Text("João Pedro Salmazo Pitarelo"),
                            Text("Luiz Ricardo Begosso"),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ),
          ]
        ),
      ),
    );
  }
}

class _logoutConfirmDialog extends StatelessWidget {

  const _logoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final homeViewmodel = Provider.of<HomeViewmodel>(context, listen: false);

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.wantToLogout,
                style: GoogleFonts.roboto(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  const Icon(Icons.close, size: 24, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.no,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.green,
                      fontWeight: FontWeight.bold)),
                ],
              )),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                authProvider.logout();
                homeViewmodel.clearUserData();
              },
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 24, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.yes,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.red,
                    )
                  )
                ],
              ))
          ],
        ),
      ],
    );
  }
}
