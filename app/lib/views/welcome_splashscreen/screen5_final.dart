import 'package:app/models/category_vo.dart';
import 'package:app/models/enums/priority_enum.dart';
import 'package:app/views/common/task_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Screen5Final extends StatelessWidget {
  const Screen5Final({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 450,
          child: Image.asset("assets/images/tasksave_logo.png",
              height: 250, width: 250),
        ),
        TaskWidget(
          id: "0",
          title: AppLocalizations.of(context)!.titleTask,
          description: AppLocalizations.of(context)!.descriptionTask,
          deadline: DateTime.now(),
          priority: PriorityEnum.low,
          category: CategoryVo(id: 0, description: "None", color: "None", activate: true),
          completed: false,
          onDismissedCallback: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
          },
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Colors.white,
                        size: 40,
                        weight: 200.0,
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/welcomeScreen4')),
                ),

                ]
              )
            ],
          ),
        )
      ],
    );
  }
}
