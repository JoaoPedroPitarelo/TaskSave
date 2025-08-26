import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_save/core/enums/file_type_enum.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/l10n/app_localizations.dart';
import 'package:task_save/presentation/screens/task_details/task_details_viewmodel.dart';

class AttachmentViewerScreen extends StatefulWidget {
  final AttachmentVo attachment;
  final TaskDetailsViewmodel taskDetailsViewmodel;

  const AttachmentViewerScreen({
    required this.attachment,
    required this.taskDetailsViewmodel,
    super.key,
  });

  @override
  State<AttachmentViewerScreen> createState() => _AttachmentViewerScreenState();
}

class _AttachmentViewerScreenState extends State<AttachmentViewerScreen> {
  PDFViewController? _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;

  Widget _buildImage(FileTypeEnum type) {
    if (type == FileTypeEnum.jpeg || type == FileTypeEnum.png || type == FileTypeEnum.jpg) {
      return Image.file(File(widget.attachment.localFilePath!), fit: BoxFit.contain);
    }
    return const Icon(
      Icons.file_present_rounded,
      size: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attachment.fileName,
          style: GoogleFonts.roboto(
            color: Colors.white
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8),
        )),
        actions: [
          PopupMenuButton<String>(
            color: theme.appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) async {
              if (value == "saveAs") {
                await widget.taskDetailsViewmodel.saveAsAttachment(
                  widget.attachment,
                  appLocalizations.download,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
              if (value == "delete") {
                if (context.mounted) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => _DeleteAttachmentDialog(
                      attachment: widget.attachment,
                      taskDetailsViewmodel: widget.taskDetailsViewmodel,
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "saveAs",
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 25,
                      color: Colors.green,
                    ),
                    Text(
                      appLocalizations.download,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15,
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
                    const Icon(
                      Icons.close_rounded,
                      size: 25,
                      color: Colors.red,
                    ),
                    Text(
                      appLocalizations.delete,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: widget.attachment.fileType == FileTypeEnum.pdf
        ? PDFView(
          filePath: widget.attachment.localFilePath,
          fitPolicy: FitPolicy.BOTH,
          backgroundColor: Colors.transparent,
          swipeHorizontal: true,
          onRender: (pages) {
            setState(() {
              _totalPages = pages!;
            });
          },
          onViewCreated: (PDFViewController pdfViewController) {
            setState(() {
              _pdfViewController = pdfViewController;
            });
          },
          onPageChanged: (page, total) {
            setState(() {
              _currentPage = page!;
            });
          },
          onError: (error) {
            print("ERRO no PDFView: $error");
          },
          onPageError: (page, error) {
            print('ERRO na página $page: $error');
          },
        )
        : InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.5,
          maxScale: 4,
          child: Center(child: _buildImage(widget.attachment.fileType)
        ),
      )
    );
  }
}

class _DeleteAttachmentDialog extends StatelessWidget {
  final AttachmentVo attachment;
  final TaskDetailsViewmodel taskDetailsViewmodel;

  const _DeleteAttachmentDialog({
    super.key,
    required this.attachment,
    required this.taskDetailsViewmodel,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(width: 10),
              Text(
                appLocalizations.wantToDelete,
                style: GoogleFonts.roboto(fontSize: 24, color: Colors.white),
              ),
            ],
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
                  Text(
                    appLocalizations.no,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () async {
                await taskDetailsViewmodel.deleteAttachment(attachment);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.check, size: 24, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(
                    appLocalizations.yes,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
