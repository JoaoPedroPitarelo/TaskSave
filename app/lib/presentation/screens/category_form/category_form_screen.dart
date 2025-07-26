import 'dart:async';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/core/events/category_events.dart';
import 'package:app/domain/models/category_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:app/presentation/screens/category_form/category_form_viewmodel.dart';
import 'package:app/services/events/category_event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class CategoryFormScreen extends StatefulWidget {
  CategoryVo? category;

  CategoryFormScreen({this.category ,super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  StreamSubscription? _creationSubscription;
  final CategoryEventService _categoryEventsService = CategoryEventService();

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  Color _colorPicked = Colors.red;

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryFormViewmodel = context.read<CategoryFormViewmodel>();

    if (widget.category != null) {
      await categoryFormViewmodel.updateCategory(
        _descriptionController.text,
        _colorPicked.toHexString(toUpperCase: true, enableAlpha: false),
        widget.category!.id.toString()
      );
      return;
    }

    await categoryFormViewmodel.saveCategory(
      _descriptionController.text,
      _colorPicked.toHexString(toUpperCase: true, enableAlpha: false)
    );
  }

  void _loadCategoryForUpdate() {
    setState(() {
      _colorPicked = hexToColor(widget.category!.color);
      _descriptionController.text = widget.category!.description;
    });
  }

  void _clearFormForNewCategory() {
    setState(() {
      _colorPicked = Colors.red;
      _descriptionController.clear();
      widget.category = null;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (mounted) {
        final categoryFormViewmodel = context.read<CategoryFormViewmodel>();

        _creationSubscription = _categoryEventsService.onCategoryChanged.listen( (event) {
          if (event is CategoryCreatedEvent && event.success) {
            Navigator.of(context).pop();
          }

          if (event is CategoryCreatedEvent && !event.success) {
            _showSnackbarError(translateFailureKey(context, event.failureKey!));
          }

          if (event is CategoryUpdatingEvent && event.success) {
            _clearFormForNewCategory();
            Navigator.of(context).pop();
          }

          if (event is CategoryUpdatingEvent && !event.success) {
            _showSnackbarError(translateFailureKey(context, event.failureKey!));
          }
        });
      }

      if (widget.category != null) {
        _loadCategoryForUpdate();
      } else {
        _clearFormForNewCategory();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _creationSubscription?.cancel();
  }

  void _showSnackbarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        showCloseIcon: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryFormViewmodel = context.watch<CategoryFormViewmodel>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 12, 43, 170),
          elevation: 12,
          shadowColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            )
          ),
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 5, offset: Offset(-1, 2.1))],
                        size: 40
                      ),
                      Text(
                        widget.category != null
                            ? AppLocalizations.of(context)!.modifyCategory
                            : AppLocalizations.of(context)!.taskCategory,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w400
                        )
                      )
                    ]
                  ),
                ],
              ),
            )
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                         MediaQuery.of(context).padding.top -
                         MediaQuery.of(context).padding.bottom
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.drive_file_rename_outline),
                            fillColor: const Color.fromARGB(31, 175, 175, 175),
                            labelText: AppLocalizations.of(context)!.descriptionCategory,
                            hintText: AppLocalizations.of(context)!.descriptionCategoryPlaceholder,
                            hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14
                            )
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.descriptionCategoryIsObrigatory;
                            }
                            return null;
                          },
                          autofillHints: [AutofillHints.email],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              AppLocalizations.of(context)!.color,
                              style: GoogleFonts.roboto(
                                fontSize: 24
                              ),
                            ),
                          )
                        ]
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: ColorPicker(
                          pickerColor: _colorPicked,
                          onColorChanged: (color) {
                            setState(() {
                              _colorPicked = color;
                            });
                          },
                          labelTypes: const [],
                          enableAlpha: false,
                          portraitOnly: false,
                          hexInputBar: true,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _submitForm(context);
        },
        label: categoryFormViewmodel.isLoading
          ? CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
            widget.category != null
                ? AppLocalizations.of(context)!.modifyCategory
                : AppLocalizations.of(context)!.taskCategory,
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w400
            ),
        ),
        icon: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 35
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
