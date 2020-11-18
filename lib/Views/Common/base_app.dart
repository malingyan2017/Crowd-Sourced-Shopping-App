import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Home/home_main.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:shopping_app/Views/Reviews/reviews_main.dart';
import 'package:shopping_app/Views/Barcode_Scan/scan_main.dart';
import 'package:shopping_app/Views/Search/search_main.dart';
import 'package:shopping_app/Views/Common/side_drawer.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';
import 'package:shopping_app/Views/Shopping_List/shopping_list_view.dart';

// Sources: https://www.youtube.com/watch?v=WG4y47qGPX4&t=5s
// https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html

class BaseApp extends StatefulWidget {
  @override
  _BaseAppState createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  int _selectedIndex = 0; // Selected Index of the navigation bar
  List<Widget> _widgetOptions = <Widget>[
    Home(),
    SearchPage(),
    BarcodeScan(),
    Reviews(),
    // ShoppingList()
  ];

  List<String> _appBarTitles = <String>[
    'Live Feed',
    'Search',
    'Scan Item',
    'Reviews',
    // 'Shopping List'
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new SideDrawer(),
      appBar: MyAppBar(_appBarTitles.elementAt(_selectedIndex)),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      //resizeToAvoidBottomPadding: true,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // canvasColor: Theme.of(context).primaryColor,
            canvasColor: Colors.grey[350],
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.black54))),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code,
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.comment,
              ),
              label: 'Reviews',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTap,
        ),
      ),
    );
  }
}
