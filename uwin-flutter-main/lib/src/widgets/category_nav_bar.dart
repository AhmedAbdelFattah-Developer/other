import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CategoryNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Container(
        height: 100.0,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3C000000),
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Fashion',
              'assets/category_icons/fashion.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Food & Drinks',
              'assets/category_icons/food.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Health & Beauty',
              'assets/category_icons/health_beauty.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Home & Garden',
              'assets/category_icons/home.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Leisure & Culture',
              'assets/category_icons/leisure.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Mobile & Electronics',
              'assets/category_icons/electronics_mobile.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Supermarkets',
              'assets/category_icons/supermarkets.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Services Directory',
              'assets/category_icons/services.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'Other',
              'assets/category_icons/other.png',
            ),
            SizedBox(width: 8.0),
            _QuickSearchTile(
              'All',
              'assets/category_icons/switch.png',
              query: '',
            ),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }
}

class _QuickSearchTile extends StatelessWidget {
  final title;
  final imagePath;
  final query;

  _QuickSearchTile(
    this.title,
    this.imagePath,
    {this.query}
  );

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
          // color: Colors.white,
          ),
      child: Container(
        decoration: BoxDecoration(
          image: new DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
          '/find-shops/by-category',
          arguments: <String, dynamic>{'category': query ?? title },
        );
      },
      child: Container(
        width: 70.0,
        child: Column(
          children: <Widget>[
            icon,
            SizedBox(height: 5.0),
            Text(
              title,
              style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor,
                fontSize: 11.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
