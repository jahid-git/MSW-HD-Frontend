import 'package:flutter/material.dart';
import 'package:mswhd/screens/chat_screen.dart';
import '../screens/notifications_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback toggleTheme;
  final bool isLightTheme;

  const CustomAppBar({required this.toggleTheme, required this.isLightTheme, Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1); // Add 1 pixel for the Divider
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 1),
      child: Column(
        children: [
          AppBar(
            leading: LayoutBuilder(
              builder: (context, constraints) {
                double paddingValue = constraints.maxWidth < 600 ? 0 : 16.0;
                return Padding(
                  padding: EdgeInsets.only(left: paddingValue, top: 8.0, bottom: 8.0),
                  child: Image.asset('assets/images/icon.png'),
                );
              },
            ),
            title: _isSearching
                ? TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search content...',
                border: InputBorder.none,
              ),
              style: TextStyle(color: widget.isLightTheme ? Colors.black : Colors.white),
            )
                : const Text('MSW HD'),
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
              ),
              // IconButton(
              //   icon: const Icon(Icons.wechat_sharp),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const ChatScreen()),
              //     );
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: widget.toggleTheme,
              ),
            ],
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}