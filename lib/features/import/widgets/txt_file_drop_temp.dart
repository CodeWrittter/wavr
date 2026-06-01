import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class TxtFileDrop extends StatefulWidget {
  final void Function(String content, String fileName) onFilePicked;

  const TxtFileDrop({super.key, required this.onFilePicked});

  @override
  State<TxtFileDrop> createState() => TxtFileDropState();
}

class TxtFileDropState extends State<TxtFileDrop> {
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _fileName != null
              ? AppColors.theme.withOpacity(0.4)
              : AppColors.theme.withOpacity(0.2),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // file icon
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.theme.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _fileName != null
                  ? Icons.check_circle_outline_rounded
                  : Icons.insert_drive_file_outlined,
              color: AppColors.theme,
              size:  28,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            _fileName ?? 'Choose a file (.txt)',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color: _fileName != null
                  ? AppColors.theme
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          if (_fileName == null) ...[
            Text(
              'One song per line',
              style: TextStyle(
                fontFamily: AppFonts.jetbrainsMono,
                fontSize:   11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.jetbrainsMono,
                  fontSize:   11,
                  color: Colors.white.withOpacity(0.4),
                ),
                children: const [
                  TextSpan(text: 'Format: '),
                  TextSpan(
                    text: 'Artist — Title',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:      Colors.white,
                    ),
                  ),
                  TextSpan(text: ' or '),
                  TextSpan(
                    text: 'Title — Artist',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // example preview box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: AppFonts.jetbrainsMono,
                    fontSize:   11,
                    height:     1.9,
                  ),
                  children: [
                    const TextSpan(
                      text:  'Drake',
                      style: TextStyle(color: AppColors.theme),
                    ),
                    TextSpan(
                      text:  " — God's Plan\n",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7)),
                    ),
                    TextSpan(
                      text:  'Last last',
                      style:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    const TextSpan(
                      text:  ' — ',
                      style: TextStyle(
                          color: AppColors.theme),
                    ),
                    const TextSpan(
                      text:  'Burna Boy\n',
                      style: TextStyle(color: AppColors.theme),
                    ),
                    const TextSpan(
                      text:  'Fally Ipupa',
                      style: TextStyle(color: AppColors.theme),
                    ),
                    TextSpan(
                      text:  ' — 8ème Merveille\n',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7)),
                    ),
                    TextSpan(
                      text:  '…',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Text(
              'File loaded — ready to import',
              style: TextStyle(
                fontFamily: AppFonts.jetbrainsMono,
                fontSize:   11,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> pick() async {
    // final result = await FilePicker.pickFiles(
    //   type:           FileType.custom,
    //   allowedExtensions: ['txt'],
    // );
    // if (result == null || result.files.isEmpty) return;

    // final file = result.files.first;
    // if (file.bytes == null) return;

    // final content  = String.fromCharCodes(file.bytes!);
    // final fileName = file.name;

    // setState(() => _fileName = fileName);
    // widget.onFilePicked(content, fileName);
  }
}
