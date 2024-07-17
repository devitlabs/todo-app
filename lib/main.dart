import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_todo_screen.dart';
import 'object_box.dart';

late ObjectBox objectbox;

const SUPABASE_URL  = "https://zgmfexsiyohjdolcjixk.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpnbWZleHNpeW9oamRvbGNqaXhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjA4NjU4NDAsImV4cCI6MjAzNjQ0MTg0MH0.vIc5mMSZ9rapCmgz5P_YMIx-uX_D4zHmNDu51n_ucpE";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: false,
      ),
      home: const TodoScreen(),
    );
  }
}

