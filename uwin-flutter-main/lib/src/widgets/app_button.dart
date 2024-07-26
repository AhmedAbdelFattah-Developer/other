import 'dart:async';

import 'package:flutter/cupertino.dart';

class AppButton extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function() onPressed;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color disabledColor;
  final double minSize;
  final double pressedOpacity;
  final BorderRadius borderRadius;
  final AlignmentGeometry alignment;

  const AppButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.padding,
    this.color,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool showActivity = false;

  @override
  Widget build(BuildContext context) {
    if (showActivity) {
      return CupertinoButton(
        color: CupertinoColors.extraLightBackgroundGray,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 16.0),
            Text(
              'Loading',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ],
        ),
        onPressed: () {},
      );
    }

    return CupertinoButton(
      padding: widget.padding,
      color: widget.color,
      disabledColor: widget.disabledColor,
      minSize: widget.minSize,
      pressedOpacity: widget.pressedOpacity,
      borderRadius: widget.borderRadius,
      alignment: widget.alignment,
      child: widget.child,
      onPressed: () async {
        setState(() {
          showActivity = true;
        });
        await widget.onPressed();
        setState(() {
          showActivity = false;
        });
      },
    );
  }
}
