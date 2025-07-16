import 'dart:io';

import 'package:app/core/themes/app_global_colors.dart';
import 'package:app/domain/enums/file_type_enum.dart';
import 'package:app/domain/models/attachmentVo.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentWidget extends StatefulWidget {
  final AttachmentVo attachment;

  const AttachmentWidget({
    required this.attachment,
    super.key
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {

  Widget _buildImage(FileTypeEnum type) {
    if (type == FileTypeEnum.jpeg || type == FileTypeEnum.png || type == FileTypeEnum.jpg) {
      return Image.file(File(widget.attachment.localFilePath!), fit: BoxFit.cover);
    }
    return Icon(
      Icons.file_present_rounded,
      size: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppGlobalColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(insetPadding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                   padding: EdgeInsets.all(12.0),
                   child: Column(
                     children: [
                       Stack(
                         alignment: AlignmentDirectional.center,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Text(
                                 widget.attachment.fileName.length > 22 ?
                                 "${widget.attachment.fileName.substring(0, 22)}..."
                                 : widget.attachment.fileName,
                                 textAlign: TextAlign.center,
                                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                               ),
                             ],
                           ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               PopupMenuButton<String>(
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(20),
                                 ),
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
                                     value: "download",
                                     child: Row(
                                       spacing: 10,
                                       children: [
                                         Icon(
                                           Icons.download_rounded,
                                           size: 25,
                                           color: Colors.green
                                         ),
                                         Text(
                                           AppLocalizations.of(context)!.download,
                                           style: GoogleFonts.roboto(
                                             fontWeight: FontWeight.w500,
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
                                           color: Colors.red
                                         ),
                                         Text(
                                           AppLocalizations.of(context)!.delete,
                                           style: GoogleFonts.roboto(
                                             fontWeight: FontWeight.w500,
                                             fontSize: 15,
                                           ),
                                         ),
                                       ],
                                     ),
                                   )
                                 ]
                               )
                             ],
                           )
                         ],
                       ),
                     ],
                   ),
                ),
                 Expanded(
                 child: widget.attachment.fileType == FileTypeEnum.pdf ? PDFView(
                    filePath: widget.attachment.localFilePath,
                    fitPolicy: FitPolicy.BOTH,
                    onRender: (pages) {
                       print("SUCESSO: PDF renderizado com $pages páginas.");
                    },
                    onError: (error) {
                      print("ERRO no PDFView: $error");
                    },
                    onPageError: (page, error) {
                      print('ERRO na página $page: $error');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                        print('View do PDF criada com sucesso.');
                    },
                  )
                   : _buildImage(widget.attachment.fileType),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            textDirection: TextDirection.ltr,
                            size: 32,
                          )
                        )
                      )
                    ],
                  ),
                ),
               ],
               )
             );
          },
        );
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
              child: widget.attachment.localFilePath != null
                ? _buildImage(widget.attachment.fileType)
                : CircularProgressIndicator(),
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
}
