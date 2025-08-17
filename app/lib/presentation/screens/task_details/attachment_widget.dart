import 'dart:io';

import 'package:task_save/core/themes/app_global_colors.dart';
import 'package:task_save/core/enums/file_type_enum.dart';
import 'package:task_save/domain/models/attachment_vo.dart';
import 'package:task_save/presentation/screens/task_details/attachment_viewer_screen.dart';
import 'package:task_save/presentation/screens/task_details/download_status.dart';
import 'package:task_save/presentation/screens/task_details/task_details_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AttachmentWidget extends StatefulWidget {
  final AttachmentVo attachment;
  final DownloadStatus status;

  const AttachmentWidget({
    required this.attachment,
    required this.status,
    super.key
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  Widget _buildImage(FileTypeEnum type) {
    if (type == FileTypeEnum.jpeg || type == FileTypeEnum.png || type == FileTypeEnum.jpg) {
      return Image.file(File(widget.attachment.localFilePath!), fit: BoxFit.contain);
    }
    return Icon(
      Icons.file_present_rounded,
      size: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskDetailsViewmodel = context.read<TaskDetailsViewmodel>();
    final appColors = AppGlobalColors.of(context);

    return GestureDetector(
      onTap: () {
        if (widget.status.state == DownloadState.completed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttachmentViewerScreen(
                attachment: widget.attachment,
                taskDetailsViewmodel: taskDetailsViewmodel,
              ),
            ),
          );
        } else if (widget.status.state == DownloadState.notDownloaded || widget.status.state == DownloadState.failed) {
          taskDetailsViewmodel.downloadAttachment(widget.attachment);
        }
      },
      child: Container(
        width: 150, height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: appColors.welcomeScreenCardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 100,
              width: 75,
              child: _buildAttachmentPreview(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.attachment.fileName.length > 15
                  ? "${widget.attachment.fileName.substring(0, 15)}..."
                  : widget.attachment.fileName,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 18
                )
              ),
            )
          ]
        )
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.status.state == DownloadState.completed && widget.attachment.localFilePath != null)
          _buildImage(widget.attachment.fileType)
        else
          Container(
            width: 75, height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

        if (widget.status.state != DownloadState.completed)
          Container(
            width: 75, height: 100,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

        if (widget.status.state == DownloadState.downloading)
          CircularProgressIndicator(value: widget.status.progress > 0 ? widget.status.progress : null, color: Colors.white),

        if (widget.status.state == DownloadState.notDownloaded)
          Icon(Icons.download_for_offline_rounded, color: Colors.white, size: 40),

        if (widget.status.state == DownloadState.failed)
          Icon(Icons.error_outline, color: Colors.red, size: 40),
      ],
    );
  }
}
