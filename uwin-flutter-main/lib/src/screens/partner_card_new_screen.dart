import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/partner_card_add_bloc.dart';

const _padding = const EdgeInsets.all(10.0);

class PartnerCardNew extends StatelessWidget {
  final _boxDeco = BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(color: Colors.grey.shade300),
      bottom: BorderSide(color: Colors.grey.shade300),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Card'),
      ),
      child: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              CupertinoTextField(
                placeholder: 'Name',
                decoration: _boxDeco,
                padding: _padding,
              ),
              SizedBox(height: 20.0),
              _buildScanField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanField(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        final data = Provider.of<PartnerCardAddBloc>(context).scan();
        print('###################### data: $data');
      },
      child: Container(
        padding: _padding,
        decoration: _boxDeco,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Scan bar code'),
            Icon(CupertinoIcons.right_chevron),
          ],
        ),
      ),
    );
  }
}
