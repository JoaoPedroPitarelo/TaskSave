import 'package:app/domain/models/category_vo.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/task_widget.dart';


class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final imagePath = theme.brightness == Brightness.dark ? "assets/images/tasksave_logo_light.png"
                                                          : "assets/images/tasksave_logo_dark.png";

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 170,
            child: Image.asset(
              imagePath,
              height: 250,
              width: 250,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  color: theme.brightness == Brightness.light ? Color.fromARGB(255, 196, 196, 196)
                                                              : Color.fromARGB(255, 52, 52, 52)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 80, right: 80),
                      child: Text(
                        AppLocalizations.of(context)!.addYourTask,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge
                      ),
                    ),
                    TaskWidget(
                      id: "0",
                      title: AppLocalizations.of(context)!.makeCakeTitle, 
                      description: AppLocalizations.of(context)!.makeCakeDescription,
                      deadline: DateTime(2025, 10, 10),
                      priority: PriorityEnum.neutral,
                      category: CategoryVo(id: 0, description: '', color: '', activate: true),
                      completed: false,),
                    TaskWidget(
                      id: "00",
                      title: AppLocalizations.of(context)!.walkWithMyDogTitle, 
                      description: AppLocalizations.of(context)!.walkWithMyDogDescription,
                      deadline: DateTime(2025, 10, 06),
                      priority: PriorityEnum.low,
                      category: CategoryVo(id: 0, description: '', color: '', activate: true),
                      completed: false),
                    TaskWidget(
                      id: "000",
                      title: AppLocalizations.of(context)!.finishMathWorkTile, 
                      description: AppLocalizations.of(context)!.finishMathWorkDescription,
                      deadline: DateTime(2025, 05, 02),
                      priority: PriorityEnum.high,
                      category: CategoryVo(id: 0, description: '', color: '', activate: true),
                      completed: false),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                      size: 40,
                      weight: 200.0,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/welcomeScreen1')),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined, 
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                      size: 40, 
                      weight: 200.0
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/welcomeScreen3')
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
