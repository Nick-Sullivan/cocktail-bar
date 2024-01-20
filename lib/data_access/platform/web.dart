import 'dart:convert';
import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:my_app/data_access/platform/interface.dart';


class FileInteractorImplementation extends BaseFileInteractorImplementation {

  @override
  void save(String data, String fileName) async {
    final content = base64Encode(utf8.encode(data));
    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", fileName)
      ..click();
  }

  @override
  String load(PlatformFile file){
    return utf8.decode(file.bytes!);
  }
  
}





