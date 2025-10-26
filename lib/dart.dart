import 'package:yaml/yaml.dart';
import 'dart:io';

dynamic readFileSynchronously(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    try {
      var contents = loadYaml(file.readAsStringSync());
      return contents;
    } catch (e) {
      print('Error reading file: $e');
    }
  } else {
    print('File not found: $filePath');
  }
}
