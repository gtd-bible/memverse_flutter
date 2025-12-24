import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation/tab scaffold using GoRouter and ShellRoute
class TabScaffold extends StatelessWidget {
  const TabScaffold({required this.child, super.key});

  final Widget child;

  static final _tabs = [
    const _TabItem(label: 'Home', icon: Icons.home, location: '/home'),
    const _TabItem(label: 'Review', icon: Icons.menu_book_rounded, location: '/review'),
    const _TabItem(label: 'Progress', icon: Icons.bar_chart_rounded, location: '/progress'),
    const _TabItem(label: 'Settings', icon: Icons.settings, location: '/settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // Find the index of the current location in the tabs list.
    // If not found, default to a specific tab, e.g., 'Review' which is at index 1.
    int index = _tabs.indexWhere((t) => location.startsWith(t.location));
    return index >= 0 ? index : 1;
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIdx,
        onTap: (idx) {
          final loc = _tabs[idx].location;
          // Only navigate if the location is different to prevent unnecessary rebuilds/pops
          if (GoRouterState.of(context).uri.toString() != loc) {
            context.go(loc);
          }
        },
        items: _tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.icon, required this.location});

  final String label;
  final IconData icon;
  final String location;
}
