import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final List<Color> colors;
  final String title;
  final String amount;
  final String imageUrl;
  final Function() onPress;
  final bool stripped;

  const TicketCard({
    Key key,
    this.colors,
    this.title = 'ADIDAS',
    this.amount = '800',
    this.onPress,
    this.imageUrl,
    this.stripped = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            image: AssetImage(
              stripped ? 'assets/images/bg.png' : 'assets/images/bg_blue.png',
            ),
          ),

          // gradient: LinearGradient(
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          //   colors: colors,
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              offset: Offset(0, 4.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25.0,
                    backgroundImage: CachedNetworkImageProvider(imageUrl),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 90,
              child: CustomPaint(
                painter: DottedLinePainter(
                  gap: 4.0,
                  strokeLength: 4.0,
                  p: Paint()
                    ..color = Colors.white
                    ..strokeWidth = 1.0,
                ),
                size: Size(1, double.infinity),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    amount,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'REDEEM',
                  style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final double gap;
  final double strokeLength;
  final Paint p;

  DottedLinePainter(
      {@required this.gap, @required this.strokeLength, @required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    double endX = 0;

    while (endX < size.height) {
      startX = endX + gap;
      endX = startX + strokeLength;

      if (endX > size.height) {
        endX = size.height;
      }

      canvas.drawLine(Offset(0, startX), Offset(0, endX), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
