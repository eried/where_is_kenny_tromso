import 'package:flutter/material.dart';
import 'features/distance/distance_screen.dart';
import 'features/soundboard/soundboard_screen.dart';
import 'features/model_viewer/model_viewer_screen.dart';
// import 'features/splash/splash_screen.dart'; // COMMENTED OUT - Using native splash only
import 'shared/theme/app_theme.dart';

class WhereIsKennyApp extends StatelessWidget {
  const WhereIsKennyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Where Is Kenny?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(), // Direct to main screen - no in-app splash
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DistanceScreen(),
    SoundboardScreen(),
    ModelViewerScreen(),
  ];

  final List<NavigationItem> _navItems = const [
    NavigationItem(
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on,
      label: 'Distance',
    ),
    NavigationItem(
      icon: Icons.volume_up_outlined,
      activeIcon: Icons.volume_up,
      label: 'Sounds',
    ),
    NavigationItem(
      icon: Icons.view_in_ar_outlined,
      activeIcon: Icons.view_in_ar,
      label: '3D Model',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
