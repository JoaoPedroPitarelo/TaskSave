import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/presentation/screens/welcome/fourth_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ThirdWelcomeScreen extends StatelessWidget {
  const ThirdWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppGlobalColors.of(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 170,
            child: Image.asset(
              appColors.taskSaveLogo!, 
              height: 250, 
              width: 250
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    color: appColors.welcomeScreenCardColor
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 200,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                          AppLocalizations.of(context)!.createYourCategories,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium
                      ),
                    ),
                    Stack(
                        alignment: AlignmentDirectional(0.0, -4.15),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: Offset(0, 8))
                                ],
                                color: Color.fromARGB(255, 61, 66, 254),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                    )
                                  ]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!.lobby,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                inherit: false
                                          )
                                        ),
                                        Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black54
                                    ),
                                    width: 300,
                                    height: 40,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Icon(Icons.search_outlined, color: Colors.white),
                                        ),
                                      ]
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 170,
                            width: 270,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 61, 66, 254),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(0, 8)
                                  )
                                ],
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    style: BorderStyle.solid,
                                                    width: 1.2),
                                                borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 55),
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            AppLocalizations.of(context)!.university,
                                            style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 20,
                                                textStyle: TextStyle(inherit: false)
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                  Container(
                                      color: Colors.white,
                                      width: 200,
                                      height: 1.2
                                  ),
                                  Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            border: Border.all(
                                                color: Colors.black,
                                                style: BorderStyle.solid,
                                                width: 1.2
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 55),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        AppLocalizations.of(context)!.job,
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20,
                                            textStyle: TextStyle(inherit: false)
                                        ),
                                      ),
                                    ),
                                  ]
                                  ),
                                  Container(
                                      color: Colors.white,
                                      width: 200,
                                      height: 1.2
                                  ),
                                  Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.lightGreen,
                                            border: Border.all(
                                                color: Colors.black,
                                                style: BorderStyle.solid,
                                                width: 1.2
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 55),
                                      child: Text(
                                        textAlign: TextAlign.start,
                                        AppLocalizations.of(context)!.personal,
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20,
                                            textStyle:
                                                TextStyle(inherit: false)
                                        ),
                                      ),
                                    ),
                                  ]
                                )
                              ]
                            ),
                        )
                      ]
                    )
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
                      size: 40,
                      weight: 200.0,
                    ),
                    onPressed: () => Navigator.of(context).pop()
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 40,
                      weight: 200.0,
                    ),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FourthWelcomeScreen())
                  )
                ),
              ),
          ])
        ],
      ),
    );
  }
}
