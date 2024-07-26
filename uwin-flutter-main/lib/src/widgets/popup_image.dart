import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupImage extends StatelessWidget {
  final String title;
  final String src;

  const PopupImage({
    Key key,
    @required this.title,
    @required this.src,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: double.infinity,
              alignment: Alignment.topRight,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CupertinoButton(
                borderRadius: BorderRadius.all(Radius.circular(100.0)),
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    border: Border.all(
                        color: CupertinoTheme.of(context).primaryColor,
                        width: 1.0),
                  ),
                  child: Icon(
                    CupertinoIcons.clear,
                    size: 30.0,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              color: Colors.white,
              child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.network(src, width: double.infinity),
                  )),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                  child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
