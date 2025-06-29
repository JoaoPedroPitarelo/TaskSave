import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/presentation/common/task_widget.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/screens/login/login_screen.dart';
import 'package:app/presentation/screens/login/login_viewmodel.dart';
import 'package:app/repositories/auth_repository.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinalWelcomeScreen extends StatelessWidget {
  const FinalWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 450,
            child: Image.asset(
              appColors.taskSaveLogo!,
              height: 250, width: 250
            ),
          ),
          TaskWidget(
            id: "0",
            title: AppLocalizations.of(context)!.titleTask,
            description: AppLocalizations.of(context)!.descriptionTask,
            deadline: DateTime.now(),
            priority: PriorityEnum.low,
            category: CategoryVo(id: 0, description: "None", color: "None", activate: true),
            completed: false,
            onDismissedCallback: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
               builder: (context) => ChangeNotifierProvider(
                   create: (ctx) => LoginViewModel(
                       Provider.of<AuthService>(ctx, listen: false),
                       Provider.of<AuthRepository>(ctx, listen: false),
                       Provider.of<AuthProvider>(ctx, listen: false),
                       (failure) => mapFailureToLocalizationMessage(ctx, failure)
                  ),
                 child: const LoginScreen(),
                )
               )
            )
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_outlined,
                            size: 40,
                            weight: 200.0,
                          ),
                          onPressed: () => Navigator.of(context).pop()
                      ),
                    ),
                  ]
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
