import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_app/data_access/platform/interface.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';


class FileInteractorImplementation extends BaseFileInteractorImplementation {

  @override
  void save(String data, String fileName) async {
    debugPrint('Saving');
    
    String directory = (await getApplicationDocumentsDirectory()).path;

    // var status = await Permission.storage.status;
    // if (status.isDenied){
    //   return;
    // }

    final path = "$directory/$fileName";
    debugPrint(path);
    final File file = File(path);
    await file.writeAsString(data);

    Share.shareXFiles([XFile(path)]);
  }
  
  @override
  String load(PlatformFile file){
    File f = File(file.path!);
    return f.readAsStringSync();
  }
  
}


