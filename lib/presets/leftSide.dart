import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/pages/Dashboard.dart';
import 'package:gold_tracking_desktop_stock_app/pages/homePage.dart';
import 'package:gold_tracking_desktop_stock_app/pages/inventory.dart';



class Leftside extends StatefulWidget {
  const Leftside({super.key});

  @override
  _LeftsideState createState() => _LeftsideState();
}

class _LeftsideState extends State<Leftside> {
  String selectedPage = 'Stock';
  String hoveringPage = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(),
            ),
            Container(
              padding: EdgeInsets.only(left: 16.0 ,right: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_sharp, color: const Color.fromARGB(255, 255, 255, 255), size: 24 ), // Gold or mineral icon
                  SizedBox(width: 8.0),
                  Text(
                    'Gildora  ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15,),
            Expanded(
              child: ListView(
                children: [
                  buildListTile(context, 'Dashboard', Dashboard(), Icons.analytics_outlined),
                  buildListTile(context, 'Inventory', Inventory(), Icons.inventory_2_outlined),
                  buildListTile(context, 'Prices', homePage(), Icons.price_change_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(BuildContext context, String title, Widget page, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveringPage = title;
          });
        },
        onExit: (_) {
          setState(() {
            hoveringPage = '';
          });
        },
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedPage = title;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: selectedPage == title
                  ? Colors.red
                  : hoveringPage == title
                      ? Colors.red.withOpacity(0.5)
                      : Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24.0, // Fixed width for the icon
                    child: Icon(icon, color: Colors.white, size: 20, ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white,fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
