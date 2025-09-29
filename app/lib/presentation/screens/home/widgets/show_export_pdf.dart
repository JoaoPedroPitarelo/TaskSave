import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/common/hex_to_color.dart';
import 'package:task_save/presentation/screens/home/category_viewmodel.dart';
import 'package:task_save/presentation/screens/home/task_viewmodel.dart';

void showExportTasksDialog(BuildContext context) {
  final categoryViewmodel = context.read<CategoryViewmodel>();
  final taskViewmodel = context.read<TaskViewmodel>();
  String? selectedCategoryId;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, size: 35, color: Colors.white),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.exportToPdf, style: TextStyle(color: Colors.white)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categoryViewmodel.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryViewmodel.categories[index];
                  return RadioListTile<String?>(
                    title: Text(
                      category.isDefault ? AppLocalizations.of(context)!.allTasks : category.description,
                      style: TextStyle(color: Colors.white),
                    ),
                    value: category!.id.toString(),
                    groupValue: selectedCategoryId,
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                    fillColor: WidgetStatePropertyAll(Colors.white),
                    activeColor: Color.fromARGB(255, 12, 43, 170),
                    secondary: Icon(Icons.dashboard_rounded, color: hexToColor(category.color)),
                  );
                },
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.close, size: 28, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.roboto(
                            fontSize: 16  ,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      taskViewmodel.exportToPDF(selectedCategoryId);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.file_download_rounded, size: 28, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.export,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
