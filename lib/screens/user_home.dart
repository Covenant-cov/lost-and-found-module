import 'package:flutter/material.dart';
import 'package:lost_and_found_fnlyrprj/screens/found_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/lost_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/user_reported_found_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/favorites_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/notifications_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/profile_screen.dart';

class UserHome extends StatefulWidget {
  static String id = 'user_home';

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(), // Main Home screen content
    FavoritesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF643579),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF643579),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),

            // CTA Sections
            _SectionTitle(
              title: 'Report Lost Item',
              onViewAll: () => Navigator.pushNamed(context, LostScreen.id),
            ),
            _buildCTACard(
              context: context,
              width: cardWidth,
              icon: Icons.report_problem_outlined,
              title: 'Report Lost Item',
              subtitle: 'Let us know what you lost',
              routeName: LostScreen.id,
            ),
            _SectionTitle(
              title: 'Report Found Item',
              onViewAll: () => Navigator.pushNamed(context, FoundScreen.id),
            ),
            _buildCTACard(
              context: context,
              width: cardWidth,
              icon: Icons.find_in_page,
              title: 'Report Found Item',
              subtitle: 'Let us know what you found',
              routeName: FoundScreen.id,
            ),
            _SectionTitle(
              title: 'Browse Found Items',
              onViewAll:
                  () =>
                      Navigator.pushNamed(context, UserReportedFoundScreen.id),
            ),
            _buildCTACard(
              context: context,
              width: cardWidth,
              icon: Icons.list_alt,
              title: 'Browse Found Items',
              subtitle: 'See all items that’ve been found',
              routeName: UserReportedFoundScreen.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTACard({
    required BuildContext context,
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeName),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Color(0xFF643579)),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF643579),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, routeName),
                  child: Text('Go', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionTitle({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text('View', style: TextStyle(color: Color(0xFF643579))),
          ),
        ],
      ),
    );
  }
}
