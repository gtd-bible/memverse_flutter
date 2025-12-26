import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memverse_flutter/src/features/signed_in/presentation/placeholders.dart';

const _tabs = <Widget>[
  HomeTab(),
  VerseTextQuizScreen(),
  MemversePage(),
  SettingsScreen()
];

class SignedInScreen extends HookWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(1);
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded), label: "Verse"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.bookmarks_outlined), label: "Ref"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.settings), label: "Settings"),
    ];
    return Scaffold(
      body: IndexedStack(index: selectedIndex.value, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
      ),
    );
  }
}
