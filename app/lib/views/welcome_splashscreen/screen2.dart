import 'package:app/models/category_vo.dart';
import 'package:app/models/enums/priority_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/views/common/task_widget.dart';



class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Image.asset(
            "assets/images/tasksave_logo.png",
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
                color: Color.fromARGB(255, 82, 82, 82),
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
                      style: GoogleFonts.sansitaSwashed(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 32,
                          textStyle: TextStyle(
                            inherit: false,
                          )),
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
                    color: Colors.white,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/welcomeScreen1')),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                  icon: Icon( Icons.arrow_forward_ios_outlined, color: Colors.white, size: 40, weight: 200.0),
                  onPressed: () => Navigator.of(context).pushNamed('/welcomeScreen3')),
            ),
          ],
        )
      ],
    );
  }
}
