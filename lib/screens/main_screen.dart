import 'package:flutter/material.dart';
import 'package:mswhd/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart';
import '../pages/history_page.dart';
import '../pages/download_page.dart';
import '../pages/profile_page.dart';
import '../pages/request_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/exit_confirmation_dialog.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainScreen({required this.toggleTheme, super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const RequestPage(),
    const DownloadPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTabIndex();
  }

  void _loadTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selected_index') ?? 0;
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_index', index);
  }

  void _onPageChanged(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_index', index);
  }

  Future<bool> _onWillPop() async {
    return await showExitConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width >= 600;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          toggleTheme: widget.toggleTheme,
          isLightTheme: isLightTheme,
        ),
        floatingActionButton: FloatingActionButton.small(onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }, child: const Image(
          image: AssetImage("assets/images/chat.png"),
          width: 24,  // Adjust width and height as needed
          height: 24,
        ),),
        body: Row(
          children: [
            if (isLargeScreen)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                ),
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.movie_filter_outlined),
                      label: Text('Request'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.offline_pin_outlined),
                      label: Text('Downloads'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
              ),
            if (isLargeScreen)
              const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _pages,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isLargeScreen
            ? null
            : BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              label: 'Request',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.offline_pin_outlined),
              label: 'Downloads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
