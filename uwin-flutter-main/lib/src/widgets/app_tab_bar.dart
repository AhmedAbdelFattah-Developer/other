import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTabBar extends StatelessWidget {
  final int currentIndex;
  static const List<String> routes = <String>[
    '/',
    '/find-shops',
    '/my-wins',
    '/profile',
    '/win-credits',
  ];

  const AppTabBar({this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          Navigator.of(context).pushReplacementNamed(
            routes[index],
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'My Wins',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/myvoice-monochrome.png')),
            label: 'Win Voucher',
          ),
        ],
      ),
    );
  }
}
