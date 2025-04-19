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
                color: Color.fromARGB(255, 82, 82, 82),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 80, right: 80),
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
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 96, 96, 96),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    width: 320,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                          Container(
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 62, 62, 62),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Comprar ingredientes bolo',
                                          style: TextStyle(
                                              fontSize: 20,
                                              inherit: false,
                                              color: Colors.white),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: 120,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            color:Color.fromARGB(255, 44, 44, 44)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 6.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.date_range, color: Colors.white, size: 16),
                                                Text("|", style: TextStyle(fontSize: 10, color: Colors.white, inherit: false)),
                                                Text("05/11/2024", style: TextStyle(fontSize: 10, color: Colors.white, inherit: false))    
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 42, 42, 42),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    '1kg de farinha de trigo, 1L de óleo, 1 fermento biológico',
                                    style: TextStyle(color: Colors.white, fontSize: 15, inherit: false),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
