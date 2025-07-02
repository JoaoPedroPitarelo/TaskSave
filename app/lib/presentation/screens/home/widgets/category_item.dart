import 'package:app/core/utils/failure_localizations_mapper.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/screens/categoryForm/category_form_screen.dart';
import 'package:app/presentation/screens/categoryForm/category_form_viewmodel.dart';
import 'package:app/presentation/screens/home/home_viewmodel.dart';
import 'package:app/repositories/category_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class CategoryItem extends StatelessWidget {
  final CategoryVo category;
  final VoidCallback onTap;


  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
        onPressed: onTap,
        onLongPress: () {
          if (!category.isDefault) {
            showDialog(context: context, builder: (context) => _CategoryDetailsDialog(category: category));
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 20.0, right: 22),
          child: Row(
              spacing: 14,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  category.isDefault ? Icons.close_rounded : Icons.dashboard_customize_outlined,
                  color: hexToColor(category.color),
                  size: 23,
                ),
                Text(
                  category.description == "Default" ? "Sem categoria" : category.description,
                  style: theme.textTheme.bodySmall,
                )
              ]
          ),
        )
    );
  }
}

class _CategoryDetailsDialog extends StatelessWidget {
  final CategoryVo category;

  const _CategoryDetailsDialog({
    super.key,
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      title: Row(
        spacing: 14,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            color: hexToColor(category.color),
            size: 30,
            shadows: [Shadow(blurRadius: 5, offset: Offset(-1, 2.5))],
          ),
          Text(
            category.description,
            style: GoogleFonts.roboto(
                fontSize: 24,
                color: Colors.white
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!category.isDefault) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (ctx) => CategoryFormViewmodel(
                        (failure) => mapFailureToLocalizationMessage(ctx, failure),
                        CategoryRepository(Provider.of<Dio>(ctx, listen: false))
                        ),
                      child: CategoryFormScreen(category: category),
                      )
                    )
                  );
                }
              },
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.edit, size: 24, color: Colors.blue),
                  Text(
                    AppLocalizations.of(context)!.edit,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white
                    )
                  ),
                ],
              )
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                if (!category.isDefault) {
                  Navigator.of(context).pop();
                  showDialog(context: context, builder: (context) => _DeleteCategoryDialog(category: category));
                }
              },
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.delete_forever_outlined, size: 24, color: Colors.red),
                  Text(
                    AppLocalizations.of(context)!.delete,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white
                    )
                  )
                ],
              )
            )
          ],
        ),
      ],
    );
  }
}

class _DeleteCategoryDialog extends StatelessWidget {
  final CategoryVo category;

  const _DeleteCategoryDialog({
    super.key,
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    final homeViewmodel = context.read<HomeViewmodel>();

    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      title: Column(
        spacing: 14,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
              Text(
                AppLocalizations.of(context)!.wantToDelete,
                style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Colors.white
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.warningDeleteCategory,
            style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.white
            ),
          ),
        ],
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
                spacing: 10,
                children: [
                  Icon(Icons.close, size: 24, color: Colors.green),
                  Text(
                    AppLocalizations.of(context)!.no,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              )
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                homeViewmodel.prepareCategoryForDeletion(category);
                Navigator.of(context).pop();
              },
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.check, size: 24, color: Colors.red),
                  Text(
                    AppLocalizations.of(context)!.yes,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.red,
                    )
                  )
                ],
              )
            )
          ],
        ),

      ],
    );
  }
}
