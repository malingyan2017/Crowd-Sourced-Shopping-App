import 'package:flutter/material.dart';
import 'package:shopping_app/Views/home_main.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:shopping_app/Views/reviews_main.dart';
import 'package:shopping_app/Views/scan_main.dart';
import 'package:shopping_app/Views/search_main.dart';

// Sources: https://www.youtube.com/watch?v=WG4y47qGPX4&t=5s
// https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  final AuthService _auth = AuthService();
  int _selectedIndex = 0; // Selected Index of the navigation bar
  List<Widget> _widgetOptions = <Widget>[
    Home(),
    SearchPage(),
    BarcodeScan(),
    Reviews(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Name',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.blue[200],
        iconTheme: new IconThemeData(
          color: Colors.black,
        ),
        actions: <Widget>[
          Icon(
            Icons.shopping_cart,
            size: 32,
          ),
        ],
      ),
      drawer: Drawer(
        //backgroundColor: Colors.black
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue[200],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 12.0,
                    left: 16.0,
                    child: Text(
                      "- User Info Placeholder - ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Positioned(
                    left: 95,
                    top: 15,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.black,
                      size: 100,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Edit Location'),
              onTap: () {
                //stuff
              },
            ),
            ListTile(
              title: Text('Edit Username'),
              onTap: () {
                //stuff
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                await _auth.signout();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Colors.blue[200],
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.black54))),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.black,
                size: 32,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: Colors.black,
                size: 32,
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code,
                color: Colors.black,
                size: 32,
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.comment,
                color: Colors.black,
                size: 32,
              ),
              label: 'Reviews',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTap,
          selectedItemColor: Colors.black,
        ),
      ),
    );
  }
}
