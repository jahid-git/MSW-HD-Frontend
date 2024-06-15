import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class FileUploaderDialog extends StatefulWidget {
  const FileUploaderDialog({super.key});

  @override
  State<FileUploaderDialog> createState() => _FileUploaderDialogState();
}

class _FileUploaderDialogState extends State<FileUploaderDialog> {
  List<int>? fileBytes;
  String? fileName;

  Future pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        PlatformFile platformFile = result.files.first;
        fileBytes = platformFile.bytes;
        fileName = platformFile.name;
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while picking the file: $e');
      }
    }
  }

  Future uploadFile() async {
    if (fileBytes == null || fileName == null) return;

    try {
      Uint8List data = Uint8List.fromList(fileBytes!);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName!);
      UploadTask uploadTask = firebaseStorageRef.putData(data);
      await uploadTask.whenComplete(() => setState(() {}));
    } catch (e) {
      if (kDebugMode) {
        print('Error while uploading the file: $e');
      }
    }
  }

  bool isImageFile(String fileName) {
    final extensions = [
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'tif', 'webp', 'ico',
      'heif', 'heic', 'raw', 'arw', 'cr2', 'nrw', 'k25', 'jfif', 'jp2',
      'j2k', 'jpf', 'jpx', 'jpm', 'mj2', 'dng', 'orf', 'rw2', 'pef',
      'sr2', 'raf', '3fr', 'rwl', 'srw', 'x3f', 'erf', 'mef', 'mos'
    ];
    return extensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload File'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Pick a file'),
            ),
            const SizedBox(height: 20),
            if (fileName != null)
              Text('Selected file: $fileName'),
            if (fileName != null && isImageFile(fileName!))
              Image.memory(
                Uint8List.fromList(fileBytes!),
                width: 300,
                height: 300,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}