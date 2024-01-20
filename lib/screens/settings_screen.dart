
import 'package:get_it/get_it.dart';
import 'package:my_app/data_access/file_interactor.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:my_app/data_access/database_interactor.dart';
import 'package:my_app/model/settings.dart';
import 'package:my_app/model/settings_factory.dart';
import 'package:settings_ui/settings_ui.dart';
final getIt = GetIt.instance;

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FileInteractor fileInteractor = FileInteractor();
  final DatabaseInteractor database = getIt<DatabaseInteractor>();
  SettingsFactory settingsFactory = getIt<SettingsFactory>();
  Settings settings = getIt<Settings>();

  @override
  void initState() {
    database.init();
    settingsFactory.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: buildSettingsList(),
      // drawer: const MenuDrawer(),
    );
  }

  SettingsList buildSettingsList() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('Location'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              value: const Text('English'),
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Data'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.upload),
              title: const Text('Export data'),
              onPressed: (_) => exportData(),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.download),
              title: const Text('Import data'),
              onPressed: (_) => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Importing will erase all existing data'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'OK');
                        importData();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Preferences'),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              leading: const Icon(Icons.umbrella),
              title: const Text('Decoration ingredients required'),
              initialValue: settings.isDecorationIncluded,
              onToggle:(value) {
                setState(() => settings.isDecorationIncluded = value);
                settingsFactory.save(settings);
              },
            ),
          ],
        ),
      ],
    );
  }

  void exportData() async {
    var data = database.export();
    var fileName = getFileName();

    fileInteractor.save(data, fileName);
  }

  void importData() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) {
      return;
    }

    String data;
    try {
      data = fileInteractor.load(result.files.single);
    } on FormatException catch (_){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unrecognised file'),
      ));
      return;
    }

    database.import(data);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data has been successfully imported.'),
    ));

  }

  String getFileName(){
    var datetime = DateFormat('yyyy-MM-dd-kk:mm').format(DateTime.now());
    return 'MyApp-$datetime.json';
  }
}
