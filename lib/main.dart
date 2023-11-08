import 'package:flutter/material.dart';
import 'package:todolist_uts/todo_page.dart';

// Irham Johar Permana
// A11.2020.12652

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TodoPage();
  }
}
