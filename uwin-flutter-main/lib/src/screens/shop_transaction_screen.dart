import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/providers/my_wins_bloc_provider.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/widgets/voucher_code_widget.dart';
import '../blocs/shop_transaction_bloc.dart';
import '../models/shop.dart';
import '../models/voucher.dart';
import '../models/coupon.dart';
import '../models/flashsale.dart';
import 'package:flutter_share/flutter_share.dart';

final _formatter = CurrencyFormatter();

class ShopTransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: StreamBuilder<Shop>(
            stream: Provider.of<ShopTransactionBloc>(context).shop,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.name);
              }

              return Container();
            }),
      ),
      child: StreamBuilder<Shop>(
        stream: Provider.of<ShopTransactionBloc>(context).shop,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.data}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }

          return _TransactionScreen(snapshot.data);
        },
      ),
    );
  }
}

const _cardHeaderStyle = TextStyle(fontWeight: FontWeight.bold);

class _TransactionScreen extends StatelessWidget {
  _TransactionScreen(this.shop);

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  if (shop.shopTypeId == '5915ba355f66500b20132252')
                    _buildCatalogCard(context),
                  _buildHeader(context),
                  _buildTransactionTotal(context),
                  _buildFlashsaleList(context),
                  _buildVoucherList(context),
                  _buildGiftVoucherList(context),
                  _buildCouponList(context),
                  // _buildDiscount(context),
                  _buildLoyaltyCard(context),
                  _buildTotalCard(context),
                  SizedBox(
                    height: 90.0,
                  ) // For button navbar + 10.0 margin bottom
                ],
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildFooterNavbar(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .18,
                ),
                child: Image.asset(
                  'assets/category_icons/food.png',
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Restaurant Menu',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navLargeTitleTextStyle
                    .copyWith(fontSize: 22.0),
              ),
              SizedBox(height: 8.0),
              Text(shop.description),
              SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                child: CupertinoButton(
                    child: Text(
                      'Open Menu',
                      style:
                          CupertinoTheme.of(context).textTheme.actionTextStyle,
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(
                          '/shops/catalog',
                          arguments: {'shop': shop},
                        ),
                    color: Colors.grey.shade200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildFooterNavbar(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
          color: theme.barBackgroundColor.withAlpha(255),
          border: Border(
              top: BorderSide(
            color: const Color(0x4D000000),
            width: 1.0,
          ))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        child: StreamBuilder<SubmitButtonState>(
          stream: bloc.submitBtnState,
          builder: (context, snapshot) {
            return CupertinoButton(
              color: theme.primaryColor,
              disabledColor: theme.primaryColor.withAlpha(100),
              child: snapshot.data == SubmitButtonStates.spinner
                  ? CupertinoActivityIndicator()
                  : Text('Save Transaction'),
              onPressed: snapshot.data == SubmitButtonStates.enabled
                  ? () async {
                      try {
                        final myWinsBloc = MyWinsBlocProvider.of(context);
                        final codes = await bloc.submit(myWinsBloc);

                        showTransactionDialog(context, codes);
                      } catch (err) {
                        print('[shop_transaction_screen] $err');
                        showCupertinoDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text("An Error has occured"),
                              content: Text(
                                  'An unexpected error has occured when saving your transaction.\nPlease try again'),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  StreamBuilder<List<Flashsale>> _buildFlashsaleList(BuildContext context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return StreamBuilder<List<Flashsale>>(
      stream: bloc.flashSales,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Center(
              child: Text('Error: ${snapshot.error}.'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 50.0,
                horizontal: 0.0,
              ),
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        }

        if (snapshot.data.length == 0) {
          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('Flashsales', style: _cardHeaderStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25.0,
                    horizontal: 10.0,
                  ),
                  child: Center(
                    child: Text('No flash sale found for this shop'),
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          child: Column(
            children: <Widget>[
              ListTile(title: Text('Flashsales', style: _cardHeaderStyle)),
              for (var fs in snapshot.data)
                StreamBuilder<int>(
                  stream: bloc.selectedFlashsale(fs.id),
                  builder: (context, selected) {
                    return _FlashsaleListTile(
                      fs,
                      quantity: selected.hasData ? selected.data : 0,
                      onTap: (current) {
                        // bloc.toggleFlashSale(current);
                      },
                    );
                  },
                )
            ],
          ),
        );
      },
    );
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      child: StreamBuilder<ShopTransaction>(
          stream: Provider.of<ShopTransactionBloc>(context).shopTransaction,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error));
            }

            if (!snapshot.hasData) {
              return Container(
                height: 200.0,
                alignment: Alignment.center,
                child: CupertinoActivityIndicator(),
              );
            }

            final user = snapshot.data.user;
            final shop = snapshot.data.shop;
            final now = DateTime.now();

            return Card(
              color: CupertinoTheme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(user.fullname,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0)),
                            Text(
                                '${user.statulsLabel} (${shop.getDiscount(user.statulsLabel)}% Discount)\nDate: ${now.day}/${now.month}/${now.year}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.0)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildVoucherList(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text('Vouchers', style: _cardHeaderStyle)),
          _buildVoucherSelectedList(context),
        ],
      ),
    );
  }

  Widget _buildVoucherSelectedList(BuildContext context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<Voucher>>(
        stream: bloc.allVoucherList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No voucher available'),
            );
          }

          return _voucherListCheckbox(context, snapshot.data);
        },
      ),
    );
  }

  Widget _voucherListCheckbox(BuildContext context, List<Voucher> vouchers) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return StreamBuilder<List<Voucher>>(
        stream: bloc.voucherList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Container();
          }

          return Column(
            children: vouchers.map<Widget>((voucher) {
              return CheckboxListTile(
                title: Text(voucher.name),
                subtitle: Text('Rs ${voucher.amount}'),
                value: bloc.isVoucherSelected(voucher, snapshot.data),
                activeColor: CupertinoTheme.of(context).primaryColor,
                onChanged: (bool value) {
                  () async {
                    if (value) {
                      if (await bloc.hasGiftVouher()) {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Gift voucher already selected'),
                            content: Text(
                                'You can\'t select a voucher if you have already selected a gift voucher'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          ),
                        );
                        return;
                      }
                      bloc.addVoucher(voucher);
                    } else {
                      bloc.removeVoucher(voucher);
                    }
                  }();
                },
              );
            }).toList(),
          );
        });
  }

  // Widget _buildAddVoucherButton(BuildContext context) {
  //   const btnPadding = EdgeInsets.symmetric(vertical: 0, horizontal: 5.0);
  //   final bloc = Provider.of<ShopTransactionBloc>(context);

  //   return StreamBuilder<bool>(
  //     stream: bloc.showVoucherButtonSpinner,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData && snapshot.data) {
  //         return Container(
  //           margin: EdgeInsets.only(bottom: 10.0),
  //           padding: EdgeInsets.symmetric(horizontal: 10.0),
  //           width: double.infinity,
  //           child: OutlineButton(
  //             padding: btnPadding,
  //             borderSide:
  //                 BorderSide(color: CupertinoTheme.of(context).primaryColor),
  //             child: CupertinoActivityIndicator(),
  //             onPressed: null,
  //           ),
  //         );
  //       }
  //       return Container(
  //         margin: EdgeInsets.only(bottom: 10.0),
  //         padding: EdgeInsets.symmetric(horizontal: 10.0),
  //         width: double.infinity,
  //         child: OutlineButton(
  //           padding: btnPadding,
  //           borderSide:
  //               BorderSide(color: CupertinoTheme.of(context).primaryColor),
  //           child: Text(
  //             '+ Add Voucher',
  //             style: TextStyle(
  //                 fontSize: 14.0,
  //                 color: CupertinoTheme.of(context).primaryColor),
  //           ),
  //           onPressed: () async {
  //             final vouchers = await bloc.fetchVoucherList();

  //             if (vouchers.length == 0) {
  //               showCupertinoDialog(
  //                 context: context,
  //                 useRootNavigator: true,
  //                 builder: (context) {
  //                   return CupertinoAlertDialog(
  //                     title: Text("No Voucher Available"),
  //                     content:
  //                         Text("The customer has no voucher for your shop"),
  //                     actions: [
  //                       CupertinoDialogAction(
  //                         isDefaultAction: true,
  //                         child: Text("Okay"),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       )
  //                     ],
  //                   );
  //                 },
  //               );

  //               return;
  //             }

  //             final act = CupertinoActionSheet(
  //               title: Text('Select Voucher'),
  //               actions: vouchers
  //                   .map<Widget>(
  //                     (v) => CupertinoActionSheetAction(
  //                       child: Text('Rs ${v.amount}'),
  //                       onPressed: () {
  //                         bloc.addVoucher(v);
  //                         Navigator.of(context).pop();
  //                       },
  //                     ),
  //                   )
  //                   .toList(),
  //               cancelButton: CupertinoActionSheetAction(
  //                 child: Text('Cancel'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             );
  //             showCupertinoModalPopup(
  //               context: context,
  //               builder: (BuildContext context) => act,
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildCouponList(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text('Coupons', style: _cardHeaderStyle)),
          _buildCouponSelectedList(context),
          _buildAddCouponButton(context),
        ],
      ),
    );
  }

  Widget _buildCouponSelectedList(context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return StreamBuilder<List<Coupon>>(
      stream: bloc.couponList,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.hasData && snapshot.data.length == 0) {
          return Container();
        }

        return Column(
          children: snapshot.data
              .map<Widget>(
                (c) => ListTile(
                  title: Text(c.name),
                  subtitle: Text('Rs ${c.discountValue}'),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    onPressed: () => bloc.removeCoupon(c),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildAddCouponButton(BuildContext context) {
    // const btnPadding = EdgeInsets.symmetric(vertical: 0, horizontal: 5.0);
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return StreamBuilder<bool>(
      stream: bloc.showCouponButtonSpinner,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            width: double.infinity,
            child: OutlinedButton(
              // padding: btnPadding,
              // borderSide:
              //    BorderSide(color: CupertinoTheme.of(context).primaryColor),
              child: CupertinoActivityIndicator(),
              onPressed: null,
            ),
          );
        }
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          width: double.infinity,
          child: OutlinedButton(
            // padding: btnPadding,
            // borderSide:
            //     BorderSide(color: CupertinoTheme.of(context).primaryColor),
            child: Text(
              '+ Add Coupon',
              style: TextStyle(
                  fontSize: 14.0,
                  color: CupertinoTheme.of(context).primaryColor),
            ),
            onPressed: () async {
              final coupons = await bloc.fetchCouponList();

              if (coupons.length == 0) {
                showCupertinoDialog(
                  context: context,
                  useRootNavigator: true,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text("No Coupon Available"),
                      content: Text(
                          "The customer has no coupon available for your shop"),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: Text("Okay"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );

                return;
              }

              final act = CupertinoActionSheet(
                title: Text('Select Coupon'),
                actions: coupons
                    .map<Widget>(
                      (c) => CupertinoActionSheetAction(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              c.itemName,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Text(
                              'Rs ${c.discountValue}',
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            ),
                          ],
                        ),
                        onPressed: () {
                          bloc.addCoupon(c);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              );
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => act,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionTotal(BuildContext context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'Transaction Total',
              style: _cardHeaderStyle,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: StreamBuilder<double>(
                stream: bloc.transactionTotal,
                builder: (context, snapshot) {
                  return CupertinoTextField(
                    onChanged: bloc.updateTransactionTotal,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(BuildContext context) {
    // final bloc = Provider.of<ShopTransactionBloc>(context);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'Loyalty',
              style: _cardHeaderStyle,
            ),
          ),
          ListTile(
            title: Text('0 point'),
          )
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Transaction Total'),
            trailing: StreamBuilder<double>(
                stream: bloc.transactionTotal,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(
                        '[transaction_screen] flashsale discount error: ${snapshot.error}');
                    return Text('Error');
                  }

                  if (!snapshot.hasData) {
                    return Text('-');
                  }

                  return Text('Rs ${snapshot.data}');
                }),
          ),
          ListTile(
            title: Text('Flashsale'),
            trailing: StreamBuilder<double>(
                stream: bloc.totalFlashsales,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(
                        '[transaction_screen] flashsale discount error: ${snapshot.error}');
                    return Text('Error');
                  }

                  if (!snapshot.hasData) {
                    return Text('-');
                  }

                  return Text('(Rs ${snapshot.data})');
                }),
          ),
          ListTile(
            title: Text('Voucher'),
            trailing: StreamBuilder<double>(
              stream: bloc.totalVoucher,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(
                      '[transaction_screen] flashsale discount error: ${snapshot.error}');
                  return Text('Error');
                }

                if (!snapshot.hasData) {
                  return Text('Rs 0.00');
                }

                return Text('(Rs ${snapshot.data})');
              },
            ),
          ),
          ListTile(
            title: Text('Gift Voucher'),
            trailing: StreamBuilder<int>(
              stream: bloc.totalGiftVoucher,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(
                      '[transaction_screen] flashsale discount error: ${snapshot.error}');
                  return Text('Error');
                }

                if (!snapshot.hasData) {
                  return Text('Rs 0.00');
                }

                return Text('(${_formatter.format(snapshot.data)})');
              },
            ),
          ),
          ListTile(
            title: Text('Coupon'),
            trailing: StreamBuilder<double>(
              stream: bloc.totalCoupon,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(
                      '[transaction_screen] coupon discount error: ${snapshot.error}');

                  return Text('Error');
                }

                if (!snapshot.hasData) {
                  return Text('Rs 0.00');
                }

                return Text('(Rs ${snapshot.data})');
              },
            ),
          ),
          ListTile(
            title: Text(
              'Total',
              style: _cardHeaderStyle,
            ),
            trailing: StreamBuilder<double>(
              stream: bloc.total,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('[transaction_screen] ${snapshot.data}');

                  return Text('Error');
                }

                if (!snapshot.hasData) {
                  return Text('-');
                }

                return Text(
                  'Rs ${snapshot.data}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildGiftVoucherList(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text('Gift Vouchers', style: _cardHeaderStyle)),
          _buildGiftVoucherSelectedList(context),
        ],
      ),
    );
  }

  _buildGiftVoucherSelectedList(BuildContext context) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<GiftVoucher>>(
        stream: bloc.allGiftVoucherList,
        builder: (context, snapshot) {
          print('########### ${snapshot.data} ###########');
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No voucher available'),
            );
          }

          return _giftVoucherListCheckbox(context, snapshot.data);
        },
      ),
    );
  }

  _giftVoucherListCheckbox(
      BuildContext context, List<GiftVoucher> giftVouchers) {
    final bloc = Provider.of<ShopTransactionBloc>(context);

    return StreamBuilder<List<GiftVoucher>>(
      stream: bloc.giftVoucherList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Container();
        }

        return Column(
          children: giftVouchers.map<Widget>((gv) {
            return CheckboxListTile(
              title: Text(gv.name),
              subtitle: Text('${_formatter.format(gv.amount)}'),
              value: bloc.isGiftVoucherSelected(gv, snapshot.data),
              activeColor: CupertinoTheme.of(context).primaryColor,
              onChanged: (bool value) {
                if (value) {
                  () async {
                    if (await bloc.hasVouher()) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Voucher already selected'),
                          content: Text(
                              'You can\'t select a gift voucher if you have already selected a voucher'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          ],
                        ),
                      );
                      return;
                    }
                    bloc.addGiftVoucher(gv);
                  }();
                } else {
                  bloc.removeGiftVoucher(gv);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _FlashsaleListTile extends StatelessWidget {
  final Flashsale fs;
  final int quantity;
  final Function(Flashsale) onTap;

  _FlashsaleListTile(this.fs, {this.quantity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (fs.photoPath == null && fs.photoPathItem == null)
          ? Container(
              width: 50.0,
              height: 50.0,
              color: Colors.black54,
              child: Icon(
                Icons.image,
                color: Colors.white70,
              ),
            )
          : Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        'https://u-win.shop/files/shops/${fs.idShop}/${fs.photoPath ?? fs.photoPathItem}',
                      ))),
            ),
      title: Text(fs.name),
      subtitle: Text('${fs.discountValue}'),
      trailing: CupertinoButton(
        color: Colors.black.withAlpha(13),
        padding: EdgeInsets.zero,
        child: Text(
          '$quantity',
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
        onPressed: () {
          final bloc = Provider.of<ShopTransactionBloc>(context);

          final picker = CupertinoPicker(
            scrollController: FixedExtentScrollController(
                initialItem: bloc.getFlashSaleQuantity(fs)),
            onSelectedItemChanged: (value) {
              bloc.changeFlashSaleQuantity(fs, value);
            },
            itemExtent: 50.0,
            children: List.generate(
              fs.remainingNbSales + 1,
              (i) => Container(
                height: 50.0,
                alignment: Alignment.center,
                child: Text('$i'),
              ),
            ),
          );

          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _BottomPicker(child: picker),
          );
        },
      ),
      onTap: () => onTap(fs),
    );
  }
}

class _BottomPicker extends StatelessWidget {
  _BottomPicker({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216.0,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

void showTransactionDialog(
  BuildContext context,
  Map<String, VoucherCode> codes,
) {
  final showVoucherCodes = codes != null && codes.values.length > 0;
  final codePageViewKey = GlobalKey<VoucherCodePageViewState>();

  showCupertinoDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text("Transaction Recorded"),
        content: Material(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Text(
                'The transaction has been successfully added',
                textAlign: TextAlign.center,
              ),
              if (showVoucherCodes) SizedBox(height: 16.0),
              if (showVoucherCodes) Divider(),
              if (showVoucherCodes) SizedBox(height: 16.0),
              if (showVoucherCodes)
                Text(
                  'Voucher Code',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (showVoucherCodes)
                VoucherCodePageView(codes, key: codePageViewKey),
              if (showVoucherCodes && codes.length > 1)
                Text(
                  'Swipe the QR Code to access the other vouchers codes',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Okay"),
            onPressed: () {
              final codeState = codePageViewKey.currentState;
              if (showVoucherCodes && !codeState.isLast) {
                codeState.nextPage();

                return;
              }

              final nav = Navigator.of(context);
              nav.pop();
              if (nav.canPop()) {
                nav.pop();
              }
            },
          )
        ],
      );
    },
  );
}

class VoucherCodePageView extends StatefulWidget {
  final Map<String, VoucherCode> codes;

  VoucherCodePageView(this.codes, {Key key}) : super(key: key);

  @override
  VoucherCodePageViewState createState() => VoucherCodePageViewState();
}

class VoucherCodePageViewState extends State<VoucherCodePageView> {
  final _ctrl = PageController(initialPage: 0);
  int selectedindex = 0;
  bool copied = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() {
        copied = false;
      });
    });
  }

  Future<void> nextPage() => _ctrl.nextPage(
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );

  Future<void> previousPage() => _ctrl.previousPage(
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );

  double get page => _ctrl.page;

  bool get isLast {
    if (widget.codes.length == 0) {
      return true;
    }

    return selectedindex + 1 == widget.codes.length.toDouble();
  }

  void copyToClipboard() {
    Clipboard.setData(
      ClipboardData(text: List.from(widget.codes.values)[selectedindex].code),
    );
    setState(() {
      copied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.codes.length > 1)
                IconButton(
                  onPressed: selectedindex > 0 ? () => previousPage() : null,
                  icon: Icon(CupertinoIcons.chevron_back),
                ),
              SizedBox(
                height: 130.0,
                width: 130.0,
                child: PageView(
                  controller: _ctrl,
                  onPageChanged: (int page) {
                    setState(() {
                      selectedindex = page;
                    });
                  },
                  children: widget.codes.values
                      .map<Widget>(
                        (v) => VoucherCodeDetailsWidget(v),
                      )
                      .toList(),
                ),
              ),
              if (widget.codes.length > 1)
                IconButton(
                    onPressed: isLast ? null : () => nextPage(),
                    icon: Icon(CupertinoIcons.chevron_right)),
            ],
          ),
          Row(
            children: _buildPageIndicator(),
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
            ),
            child: Text(
              copied ? 'Copied!' : 'Copy',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: copyToClipboard,
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return Icon(
      isActive ? Icons.radio_button_on : Icons.radio_button_off,
      size: 12.0,
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < widget.codes.length; i++) {
      list.add(i == selectedindex ? _indicator(true) : _indicator(false));
    }
    return list;
  }
}

class VoucherCodeDetailsWidget extends StatelessWidget {
  final VoucherCode code;

  VoucherCodeDetailsWidget(this.code);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: VoucherCodeWidget(code.code),
    );
  }
}
