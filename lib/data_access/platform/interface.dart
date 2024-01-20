

import 'package:file_picker/file_picker.dart';

abstract class BaseFileInteractorImplementation{
  void save(String data, String fileName);
  String load(PlatformFile file);
}
