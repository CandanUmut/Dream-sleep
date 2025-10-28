import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  Future<Directory> get _appDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<File> _resolveFile(String name) async {
    final directory = await _appDirectory;
    final file = File('${directory.path}/$name.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode({'items': []}));
    }
    return file;
  }

  Future<List<Map<String, dynamic>>> readCollection(String name) async {
    final file = await _resolveFile(name);
    final contents = await file.readAsString();
    final jsonMap = jsonDecode(contents) as Map<String, dynamic>;
    final list = jsonMap['items'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> writeCollection(String name, List<Map<String, dynamic>> data) async {
    final file = await _resolveFile(name);
    final payload = jsonEncode({'items': data});
    await file.writeAsString(payload);
  }

  Future<void> clear(String name) async {
    final file = await _resolveFile(name);
    await file.writeAsString(jsonEncode({'items': []}));
  }
}
