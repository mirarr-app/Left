import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Left/homepage.dart';
import 'package:Left/models/user_data.dart';
import 'package:Left/screens/setup_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserDataAdapter());
  Hive.registerAdapter(ImportantDateAdapter());

  final box = await Hive.openBox<UserData>('userData');
  final hasCompletedSetup = box.get('user') != null;

  runApp(MainApp(hasCompletedSetup: hasCompletedSetup));
}

class MainApp extends StatelessWidget {
  final bool hasCompletedSetup;

  const MainApp({
    super.key,
    required this.hasCompletedSetup,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: hasCompletedSetup ? const HomePage() : const SetupScreen(),
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Scratchy',
      ),
    );
  }
}
