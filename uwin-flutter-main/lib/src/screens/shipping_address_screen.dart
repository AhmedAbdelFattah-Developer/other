import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/providers/shop_bloc_provider.dart';
import '../blocs/shipping_address_bloc.dart';
import '../models/shop.dart';
import '../models/sales_order.dart';
import '../widgets/currency_number_format.dart';
import '../blocs/checkout_bloc.dart';

const BoxDecoration _kDefaultRoundedBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);
// Value inspected from Xcode 11 & iOS 13.0 Simulator.
const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);

class ShippingAddressScreen extends StatelessWidget {
  final SalesOrder so;
  final String title;
  final String successRedirect;

  ShippingAddressScreen(this.so, this.title, {this.successRedirect});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                middle: StreamBuilder<Shop>(
                    stream: Provider.of<ShippingAddressBloc>(context)
                        .getShop(so.shopId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Container();
                      }

                      return Text(snapshot.data.name);
                    }),
                largeTitle: Text(title),
              ),
              _buildFormHeader(context),
              _buildNetTotal(context, so.itemsTotal),
              _buildFormFields(context),
            ],
          ),
          _buildPlaceOrderButton(context),
        ],
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0x33000000)),
            bottom: BorderSide(color: Color(0x33000000)),
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              radius: 30.0,
              child: Icon(CupertinoIcons.shopping_cart, size: 30.0),
            ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Order Total',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                CurrencyNumberFormat(
                  number: so.total,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<CheckoutBloc>(context)
                        .changeStep(CheckoutSteps.items);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(CupertinoIcons.pencil),
                      SizedBox(width: 8.0),
                      Text('Modify your order'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetTotal(BuildContext context, int nettotal) {
    const style = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0x33000000)),
            bottom: BorderSide(color: Color(0x33000000)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Net Total', style: style),
            CurrencyNumberFormat(
              number: nettotal,
              style: style,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    final bloc = Provider.of<ShippingAddressBloc>(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0x4C000000),
              width: 0.0, // One physical pixel.
              style: BorderStyle.solid,
            ),
          ),
        ),
        height: 90.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: StreamBuilder<ButtonState>(
              stream: bloc.buttonState,
              builder: (context, snapshot) {
                return CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  disabledColor: Colors.black38,
                  onPressed: snapshot.data == ButtonStates.enabled
                      ? () async {
                          try {
                            await bloc.placeOrder(so);
                            // await _showSuccessModal(context);
                            Navigator.of(context).pushNamed(
                              '/shops/payment-summary',
                              arguments: <String, dynamic>{
                                'so': so,
                                'successRedirect': successRedirect,
                              },
                            );
                          } catch (err) {
                            print(
                                '[shippping_addres_screen] Error on place order. $err');
                            await _showErrorModal(context);
                          }
                        }
                      : null,
                  child: snapshot.data == ButtonStates.spinning
                      ? CupertinoActivityIndicator()
                      : Text('PLACE ORDER'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<T> _showErrorModal<T>(BuildContext context) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Order Error',
          style: TextStyle(color: Colors.red),
        ),
        message: const Text('Your order could not be placed.'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return _FormFields(Provider.of<ShippingAddressBloc>(context));
  }
}

class _FormFields extends StatefulWidget {
  final ShippingAddressBloc bloc;

  _FormFields(this.bloc);

  @override
  __FormFieldsState createState() => __FormFieldsState();
}

class __FormFieldsState extends State<_FormFields> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postCodeCtrl = TextEditingController();

  @override
  void initState() {
    widget.bloc.lastShippingDetails.listen((sd) {
      _firstNameCtrl.text = sd.firstName;
      _lastNameCtrl.text = sd.lastName;
      _emailCtrl.text = sd.email;
      _cityCtrl.text = sd.city;
      _phoneCtrl.text = sd.phone;
      _postCodeCtrl.text = sd.postCode;
      _streetCtrl.text = sd.street;

      widget.bloc.changeFirstName(sd.firstName);
      widget.bloc.changeLastName(sd.lastName);
      widget.bloc.changeEmail(sd.email);
      widget.bloc.changeCity(sd.city);
      widget.bloc.changePhone(sd.phone);
      widget.bloc.changePostCode(sd.postCode);
      widget.bloc.changeStreet(sd.street);
    });

    widget.bloc.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SizedBox(height: 20.0),
          StreamBuilder<bool>(
            stream: widget.bloc.firstNameValid,
            builder: (context, snapshot) {
              return CupertinoTextField(
                padding: EdgeInsets.all(12.0),
                placeholder: 'First Name*',
                placeholderStyle: TextStyle(color: Colors.red.shade800),
                controller: _firstNameCtrl,
                onChanged: widget.bloc.changeFirstName,
                decoration: (snapshot.data != true)
                    ? BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade800),
                      )
                    : _kDefaultRoundedBorderDecoration,
              );
            },
          ),
          StreamBuilder<bool>(
              stream: widget.bloc.lastNameValid,
              builder: (context, snapshot) {
                return CupertinoTextField(
                  padding: EdgeInsets.all(12.0),
                  placeholder: 'Last name*',
                  placeholderStyle: TextStyle(color: Colors.red.shade800),
                  controller: _lastNameCtrl,
                  onChanged: widget.bloc.changeLastName,
                  decoration: (snapshot.data != true)
                      ? BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade800),
                        )
                      : _kDefaultRoundedBorderDecoration,
                );
              }),
          SizedBox(height: 20.0),
          StreamBuilder<bool>(
              stream: widget.bloc.emailValid,
              builder: (context, snapshot) {
                return CupertinoTextField(
                  padding: EdgeInsets.all(12.0),
                  placeholder: 'Email*',
                  placeholderStyle: TextStyle(color: Colors.red.shade800),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailCtrl,
                  onChanged: widget.bloc.changeEmail,
                  decoration: (snapshot.data != true)
                      ? BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade800),
                        )
                      : _kDefaultRoundedBorderDecoration,
                );
              }),
          StreamBuilder<bool>(
              stream: widget.bloc.phoneValid,
              builder: (context, snapshot) {
                return CupertinoTextField(
                  padding: EdgeInsets.all(12.0),
                  keyboardType: TextInputType.phone,
                  placeholder: 'Phone*',
                  placeholderStyle: TextStyle(color: Colors.red.shade800),
                  controller: _phoneCtrl,
                  onChanged: widget.bloc.changePhone,
                  decoration: (snapshot.data != true)
                      ? BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade800),
                        )
                      : _kDefaultRoundedBorderDecoration,
                );
              }),
          SizedBox(height: 20.0),
          StreamBuilder<bool>(
              stream: widget.bloc.streetValid,
              builder: (context, snapshot) {
                return CupertinoTextField(
                  padding: EdgeInsets.all(12.0),
                  placeholder: 'Street*',
                  placeholderStyle: TextStyle(color: Colors.red.shade800),
                  controller: _streetCtrl,
                  onChanged: widget.bloc.changeStreet,
                  decoration: (snapshot.data != true)
                      ? BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                        )
                      : _kDefaultRoundedBorderDecoration,
                );
              }),
          StreamBuilder<bool>(
              stream: widget.bloc.cityValid,
              builder: (context, snapshot) {
                return CupertinoTextField(
                  padding: EdgeInsets.all(12.0),
                  placeholder: 'City*',
                  placeholderStyle: TextStyle(color: Colors.red.shade800),
                  controller: _cityCtrl,
                  onChanged: widget.bloc.changeCity,
                  decoration: (snapshot.data != true)
                      ? BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                        )
                      : _kDefaultRoundedBorderDecoration,
                );
              }),
          CupertinoTextField(
            padding: EdgeInsets.all(12.0),
            placeholder: 'Post Code',
            controller: _postCodeCtrl,
            onChanged: widget.bloc.changePostCode,
          ),
          SizedBox(height: 110.0),
        ],
      ),
    );
  }
}
