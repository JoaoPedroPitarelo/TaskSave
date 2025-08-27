import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/domain/models/category_vo.dart';
import 'package:task_save/domain/enums/priority_enum.dart';
import 'package:task_save/domain/models/task_vo.dart';
import 'package:task_save/presentation/common/task_widget.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class FinalWelcomeScreen extends StatefulWidget {
  const FinalWelcomeScreen({super.key});

  @override
  State<FinalWelcomeScreen> createState() => _FinalWelcomeScreenState();
}

class _FinalWelcomeScreenState extends State<FinalWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: false);

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(-0.5, 0.0),
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.decelerate,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 450,
            child: Image.asset(
              appColors.taskSaveLogo!,
              height: 250,
              width: 250,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TaskWidget(
                  task: TaskVo(
                    id: "0",
                    title: AppLocalizations.of(context)!.titleTask,
                    description: AppLocalizations.of(context)!.descriptionTask,
                    subtaskList: [],
                    attachmentList: [],
                    deadline: DateTime.now(),
                    priority: PriorityEnum.low,
                    category: CategoryVo(
                        id: 0,
                        description: "None",
                        isDefault: false,
                        color: theme.brightness != Brightness.dark
                            ? "3B3B3B"
                            : "#CCCCCC",
                        activate: true,
                        position: -1),
                    completed: false,
                  ),
                  rightDismissedCallback: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen())),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity:
                        _controller.drive(CurveTween(curve: Curves.decelerate)),
                    child: const Icon(
                      Icons.double_arrow_outlined,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ],
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
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 40,
                            weight: 200.0,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
