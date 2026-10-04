import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/dog_provider.dart';
import '../../providers/match_provider.dart';
import '../dogs/my_dogs_screen.dart';
import '../matcher/tinder_matcher_screen.dart';
import '../profile/profile_screen.dart';
import '../community/community_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _attachedUserId;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
    DashboardTab(onNavigateToTab: _navigateToTab),
    const TinderMatcherScreen(),
    const CommunityScreen(),
    const MyDogsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    final authProvider = context.read<app_auth.AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId != null) {
      _attachUserListeners(userId);
    }
  }

  void _attachUserListeners(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty || _attachedUserId == normalizedUserId) return;

    _attachedUserId = normalizedUserId;
    context.read<DogProvider>().listenToUserDogs(normalizedUserId);
    context.read<DogProvider>().listenToAvailableDogs(normalizedUserId);
    context.read<MatchProvider>().listenToSentRequests(normalizedUserId);
    context.read<MatchProvider>().listenToReceivedRequests(normalizedUserId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<app_auth.AuthProvider>().currentUser?.uid;
    if (userId != null) {
      _attachUserListeners(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'My Dogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
