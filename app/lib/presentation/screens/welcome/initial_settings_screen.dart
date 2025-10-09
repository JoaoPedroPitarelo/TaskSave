import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/global_providers/app_preferences_provider.dart';
import 'package:task_save/presentation/screens/welcome/first_welcome_screen.dart';


class InitialSettingsScreen extends StatelessWidget {
  const InitialSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = Provider.of<AppPreferencesProvider>(context);
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    Map<String, String> keyToLanguage = {
      'en': AppLocalizations.of(context)!.english,
      'pt': AppLocalizations.of(context)!.portuguese,
      'es': AppLocalizations.of(context)!.espanish
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 53),
            SizedBox(
              height: 110,
              child: Image.asset(
                appColors.taskSaveLogo!,
                height: 50,
                width: 50,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.initialConfig,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium
            ),
            const SizedBox(height: 50),
            Text(
              AppLocalizations.of(context)!.customYourExperience,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              AppLocalizations.of(context)!.youCanChangeItLater,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.theme,
              style: Theme.of(context).textTheme.bodyLarge
            ),
            const SizedBox(height: 13),
            SegmentedButton<ThemeMode>(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                elevation: WidgetStateProperty.all<double>(10),
                textStyle: WidgetStatePropertyAll(theme.textTheme.titleMedium),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 13.0, vertical: 11.0),
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return appColors.taskCardColor;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return theme.colorScheme.onPrimary;
                  }
                  return theme.colorScheme.onSurface;
                }),
                enableFeedback: true,
                overlayColor: WidgetStateProperty.all(appColors.taskCardColor),
              ),
              selectedIcon: Icon(Icons.check_rounded, size: 25),
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 25),
                  label: Text(AppLocalizations.of(context)!.light),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 25),
                  label: Text(AppLocalizations.of(context)!.dark),
                ),
              ],
              selected: {preferencesProvider.themeMode},
              onSelectionChanged: (newSelection) {
                final isDark = newSelection.contains(ThemeMode.dark);
                preferencesProvider.toggleTheme(isDark: isDark);
              },
            ),
            const SizedBox(height: 42),
            Row(
              spacing: 15,
              children: [
                Text(
                  AppLocalizations.of(context)!.language,
                  style: Theme.of(context).textTheme.bodyLarge
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  keyToLanguage[preferencesProvider.appLanguage.languageCode]!,
                  style: theme.textTheme.titleMedium
                ),
                DropdownButton(
                  elevation: 2,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  alignment: Alignment.center,
                  dropdownColor: theme.appBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
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
            const Spacer(flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FirstWelcomeScreen())
                  )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

