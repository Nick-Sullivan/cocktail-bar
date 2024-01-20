/// This is a trick to successfully compile on multiple platforms
/// https://gpalma.pt/blog/conditional-importing/

import 'package:file_picker/file_picker.dart';

import 'platform/stub.dart'
  if (dart.library.html) 'platform/web.dart'
  if (dart.library.io) 'platform/mobile.dart';
  

class FileInteractor {
  final FileInteractorImplementation _interactor;

  FileInteractor() : _interactor = FileInteractorImplementation();

  void save(String data, String fileName){
    _interactor.save(data, fileName);
  }

  String load(PlatformFile file){
    return _interactor.load(file);
  }

}


