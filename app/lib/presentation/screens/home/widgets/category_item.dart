import 'package:app/domain/models/category_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/screens/category_form/category_form_screen.dart';
import 'package:app/presentation/screens/home/category_viewmodel.dart';
import 'package:app/presentation/screens/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatelessWidget {
  final CategoryVo category;
  final VoidCallback onTap;
  final int index;

  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onTap,
      onLongPress: () {
        if (!category.isDefault) {
          showDialog(
            context: context,
            builder: (context) => _CategoryDetailsDialog(category: category)
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 20.0, right: 22),
        child: Row(
          children: [
            Icon(
              category.isDefault
                ? Icons.close_rounded
                : Icons.dashboard_customize_outlined,
              color: hexToColor(category.color),
              size: 25,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.description == "Default"
                  ? AppLocalizations.of(context)!.withoutCategory
                  : category.description,
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (!category.isDefault)
              ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_handle_rounded,
                  size: 25,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ));
  }
}

class _CategoryDetailsDialog extends StatelessWidget {
  final CategoryVo category;

  const _CategoryDetailsDialog({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      title: Row(
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            color: hexToColor(category.color),
            size: 30,
            shadows: const [Shadow(blurRadius: 5, offset: Offset(-1, 2.5))],
          ),
          const SizedBox(width: 14),
          Text(
            category.description,
            style: GoogleFonts.roboto(fontSize: 24, color: Colors.white),
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  CategoryFormScreen(category: category)));
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 24, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.edit,
                      style: GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
                ],
              )
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                if (!category.isDefault) {
                  Navigator.of(context).pop();
                    showDialog(context: context, builder: (context) => _DeleteCategoryDialog(category: category),
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_forever_outlined, size: 24, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.delete,
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

  const _DeleteCategoryDialog({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryViewmodel = Provider.of<CategoryViewmodel>(context, listen: false);

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 40),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.wantToDelete,
                style: GoogleFonts.roboto(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.warningDeleteCategory,
            style: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
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
                  children: [
                    const Icon(Icons.close, size: 24, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(AppLocalizations.of(context)!.no,
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                  ],
                )),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                categoryViewmodel.prepareCategoryForDeletion(category);
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  const Icon(Icons.check, size: 24, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.yes,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.red,
                    ))
                ],
              ))
          ],
        ),
      ],
    );
  }
}