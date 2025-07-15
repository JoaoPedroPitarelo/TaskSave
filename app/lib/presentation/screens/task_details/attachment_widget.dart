import 'dart:io';

import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/domain/enums/file_type_enum.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttachmentWidget extends StatelessWidget {
  final AttachmentVo attachment;

  const AttachmentWidget({
    required this.attachment,
    super.key
  });

  Widget _buildImage(FileTypeEnum type) {
    if (type == FileTypeEnum.jpeg || type == FileTypeEnum.png || type == FileTypeEnum.jpg) {
      return Image.file(File(attachment.localFilePath!));
    }
    return Icon(
      Icons.file_present_rounded,
      size: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);

    return GestureDetector(
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
              child: attachment.localFilePath != null
                ? _buildImage(attachment.fileType)
                : CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                attachment.fileName,
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
}
