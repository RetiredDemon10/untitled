import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:untitled/main.dart'; // Replace with your actual main Dart file

void main() {
  setUrlStrategy(
      PathUrlStrategy()); // This configures your app to use the path URL strategy
  runApp(const MyApp());
}
