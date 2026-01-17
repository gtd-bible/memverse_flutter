import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mini_memverse/src/features/home/home_tab.dart';
import 'package:mini_memverse/src/features/ref_quiz/memverse_page.dart';
import 'package:mini_memverse/src/features/settings/presentation/settings_screen.dart';
import 'package:mini_memverse/src/features/verse_text_quiz/widgets/verse_text_quiz_screen.dart';

// TODO: Implement proper localization (l10n) using flutter_localizations
// Reference: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
const _tabs = <Widget>[HomeTab(), VerseTextQuizScreen(), MemversePage(), SettingsScreen()];

class SignedInNavScaffold extends HookWidget {
  const SignedInNavScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(1); // Start on Verse tab
    // TODO: Replace hardcoded strings with context.l10n.home, etc. when localization is implemented
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Verse Quiz'),
      const BottomNavigationBarItem(icon: Icon(Icons.bookmarks_outlined), label: 'Ref Quiz'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];
    return Scaffold(
      body: IndexedStack(index: selectedIndex.value, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: navItems,
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
      ),
    );
  }
}
