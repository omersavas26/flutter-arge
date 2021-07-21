import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:angaryos/view/SideMenu.dart';
import 'package:angaryos/helper/ResponsiveHelper.dart';
import 'package:angaryos/view/HomeScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Widget mobile = HomeScreen();

  final Widget tablet = Row(
    children: [
      Expanded(
        flex: 2,
        child: SideMenu(),
      ),
      Expanded(
        flex: 6,
        child: HomeScreen(),
      ),
    ],
  );

  final Widget desktop = Row(
    children: [
      Expanded(
        flex: 2,
        child: SideMenu(),
      ),
      Expanded(
        flex: 6,
        child: HomeScreen(),
      ),
    ],
  );

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: ResponsiveHelper(
        // Let's work on our mobile part
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      ),
      /*floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () {
          //code to execute on button press
        },
        child: Icon(Icons.send),
        //icon inside button
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      //floating action button position to right

      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        color: Colors.redAccent,
        shape: CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Row(
          //children inside bottom appbar
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            Padding(
              padding: EdgeInsets.only(right: 90),
              child: IconButton(
                icon: Icon(
                  Icons.people,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),*/

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        fabLocation: BubbleBottomBarFabLocation.end, //new
        hasNotch: true, //new
        hasInk: true, //new, gives a cute ink effect
        inkColor: Colors.black12, //optional, uses theme color if not specified
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: Colors.red,
              ),
              title: Text("Home")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(
                Icons.access_time,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.access_time,
                color: Colors.deepPurple,
              ),
              title: Text("Logs")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.folder_open,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.folder_open,
                color: Colors.indigo,
              ),
              title: Text("Folders")),
          BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(
                Icons.menu,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.menu,
                color: Colors.green,
              ),
              title: Text("Menu"))
        ],
      ),
    );
  }
}
