import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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
                color: Color.fromARGB(200, 80, 80, 80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 80, right: 80),
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
                  Container(
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(color: Color.fromARGB(200, 62, 62, 62)),
                    child: Row(
                      children: [
                        Expanded(child: Container(color: Colors.blue, width: 50,)),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Color.fromARGB(200, 62, 62, 62)),
                              child: Row(
                                children: [
                                  Column(
                                    children: [Text('')],
                                  )
                                ],
                              ),
                            ),
                            Container(
                               decoration: BoxDecoration(color: Color.fromARGB(199, 31, 31, 31)),
                              child: Row(
                                children: [],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                  icon: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                    size: 40,
                    weight: 200.0,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/welcomeScreen3')),
            ),
          ],
        )
      ],
    );
  }
}
