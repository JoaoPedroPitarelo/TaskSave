import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/animated_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url, BuildContext context) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(AnimatedSnackBar(content: Text('Não foi possível abrir o link.'), backgroundColor: Colors.red) as SnackBar);
    }
  }
}

void showCustomAboutDialog(BuildContext context) {
  final appColors = AppGlobalColors.of(context);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        title: Column(
          children: [
            SizedBox(
              width: 200,
              height: 100,
              child: Image.asset("assets/images/tasksave_logo_light.png")
            ),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.copyright, size: 16, color: Colors.white),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.license, style: TextStyle(fontSize: 15, color: Colors.white)),
              ],
            ),
          ]
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              spacing: 40,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        launchURL("https://github.com/JoaoPedroPitarelo/TaskSave", context);
                      },
                      icon: FaIcon(FontAwesomeIcons.github, size: 30, color: Colors.white)
                    ),
                    IconButton(
                      onPressed: () {
                        launchURL("http://www.linkedin.com/in/joão-pedro-salmazo-pitarelo-b12b71264", context);
                      },
                      icon: FaIcon(FontAwesomeIcons.linkedin, size: 30, color: Colors.white)
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
                      "V 1.0",
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context)!.credits,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                  Text("João Pedro Salmazo Pitarelo",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                    ),
                  ),
                  Text(
                    "Prof. Dr. Luiz Ricardo Begosso",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                    ),
                  ),
                ],
              )
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              showLicensePage(
                context: context,
                applicationVersion: "${AppLocalizations.of(context)!.version} 1.0",
                applicationIcon: Image.asset(appColors.taskSaveLogo!),
                applicationLegalese: "${AppLocalizations.of(context)!.allTheRightReserved} © João Pedro Salmazo Pitarelo ${AppLocalizations.of(context)!.and} Luiz Ricardo Begosso",
              );
            },
            child: Text(AppLocalizations.of(context)!.moreLicenses, style: TextStyle(color: Colors.white, fontSize: 14))
          ),
        ],
      );
    },
  );
}
