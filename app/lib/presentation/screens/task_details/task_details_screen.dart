import 'dart:async';

import 'package:app/core/events/task_events.dart';
import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/core/utils/translateFailureKey.dart';
import 'package:app/domain/enums/priority_enum.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/domain/models/task_vo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/common/error_snackbar.dart';
import 'package:app/presentation/common/hex_to_color.dart';
import 'package:app/presentation/screens/task_details/attachment_widget.dart';
import 'package:app/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:app/services/events/task_event_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskVo task;

  const TaskDetailsScreen({required this.task, super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  StreamSubscription? taskSubscription;
  final TaskEventService _taskEventService = TaskEventService();

  Color _getPriorityColor(BuildContext context, PriorityEnum priority) {
    final appColor = AppGlobalColors.of(context);
    switch (priority) {
      case PriorityEnum.neutral:
        return appColor.taskPriorityNeutralColor!;
      case PriorityEnum.low:
        return appColor.taskPriorityLowColor!;
      case PriorityEnum.medium:
        return appColor.taskPriorityMediumColor!;
      case PriorityEnum.high:
        return appColor.taskPriorityHighColor!;
    }
  }

  Future<void> _downloadAttachment(AttachmentVo attachment) async {
    final taskDetailsViewModel = context.read<TaskDetailsViewmodel>();
    await taskDetailsViewModel.downloadAttachment(attachment);
  }

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task.attachmentList.isNotEmpty) {
        for (var attachment in widget.task.attachmentList) {
          _downloadAttachment(attachment);
        }
      }

      taskSubscription = _taskEventService.onTaskChanged.listen((event) {
        if (event is TaskDownloadAttachmentEvent) {
          if (!event.success) {
            _showErrorSnackBar(translateFailureKey(context, event.failureKey!));
          }
        }
      });
    });

    super.initState();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorSnackbar(message)
    );
  }

  @override
  void dispose() {
    taskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskDetailsViewModel = context.watch<TaskDetailsViewmodel>();

    final textStyle = GoogleFonts.schibstedGrotesk(
      fontWeight: FontWeight.normal,
      fontSize: 28,
      color: Colors.white,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: widget.task.title, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final textMaxWidth = MediaQuery.of(context).size.width - 20;
    textPainter.layout(maxWidth: textMaxWidth);

    final contentHeight = 100 + textPainter.height + 20;
    final preferredHeight = contentHeight < 110 ? 100 : contentHeight;

    final appColors = AppGlobalColors.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(preferredHeight as double),
        child: AppBar(
          backgroundColor: _getPriorityColor(context, widget.task.priority),
          elevation: 12,
          shadowColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              )
          ),
          actions: [
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: _getPriorityColor(context, widget.task.priority),
              onSelected: (value) {
                if (value == "edit") {
                  // TODO quando estiver pronto a tela de edição
                }
                if (value == "delete") {
                  // TODO chamar o deleteTask do taskDetaisViewmodel
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "edit",
                  child: Row(
                    spacing: 10,
                    children: [
                      const Icon(Icons.edit, size: 25),
                      Text(
                        AppLocalizations.of(context)!.edit,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "delete",
                  child: Row(
                    spacing: 10,
                    children: [
                      const Icon(Icons.close_rounded, size: 25),
                      Text(
                        AppLocalizations.of(context)!.delete,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ]
            )
          ],
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.task.title,
                          style: textStyle,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.task.category.description != "Default")
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      size: 35,
                      color: hexToColor(widget.task.category.color)
                    ),
                    Text(
                      widget.task.category.description,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                      )
                    )
                  ],
                ),

                // Description
                if (widget.task.description != null)
                Container(
                  decoration: BoxDecoration(
                    color: appColors.welcomeScreenCardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      widget.task.description!,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      )
                    ),
                  )
                ),
                Divider(),
                // Attachments
                if (widget.task.attachmentList.isNotEmpty) ...[
                  Row(
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.file_present_outlined ,
                        size: 35,
                      ),
                      Text(
                        AppLocalizations.of(context)!.attachments,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 23,
                        )
                      )
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: !taskDetailsViewModel.isLoading
                      ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.task.attachmentList.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AttachmentWidget(
                              attachment: widget.task.attachmentList[i],
                            ),
                          );
                        }
                      )
                      : SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator()
                      )
                  )
                ],
              ]
            ),
          ),
        ),
      ),
    );
  }
}
