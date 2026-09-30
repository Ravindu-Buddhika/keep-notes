import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/note_controller.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NoteController (ChangeNotifierProvider)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteController()..fetchAllData()),
      ],
      child: MaterialApp(
        title: 'Keep Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          brightness: Brightness.dark, // Dark theme
        ),
        home: const HomeScreen(),
      ),
    );
  }
}