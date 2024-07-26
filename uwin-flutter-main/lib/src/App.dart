import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/mission_list_bloc.dart';
import 'package:uwin_flutter/src/blocs/other_cards_bloc.dart';
import 'package:uwin_flutter/src/blocs/payment_summary_bloc.dart';
import 'package:uwin_flutter/src/blocs/providers/catalog_bloc_provider.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/screens/add_other_card_screen.dart';
import 'package:uwin_flutter/src/screens/buy_gift_vouchers_screen.dart';
import 'package:uwin_flutter/src/screens/catalog_screen.dart';
import 'package:uwin_flutter/src/screens/delete_account_screen.dart';
import 'package:uwin_flutter/src/screens/how_to_use_screen.dart';
import 'package:uwin_flutter/src/screens/invite_friends_screen.dart';
import 'package:uwin_flutter/src/screens/mission_list_screen.dart';
import 'package:uwin_flutter/src/screens/mission_success_screen.dart';
import 'package:uwin_flutter/src/screens/my_win_other_card_details_screen.dart';
import 'package:uwin_flutter/src/screens/my_wins_gift_vouchers_screen.dart';
import 'package:uwin_flutter/src/screens/my_wins_id_card_screen.dart';
import 'package:uwin_flutter/src/screens/my_wins_other_cards_screen.dart';
import 'package:uwin_flutter/src/screens/otp_sigin_pin_screen.dart';
import 'package:uwin_flutter/src/screens/otp_signin_screen.dart';
import 'package:uwin_flutter/src/screens/qrscan_landing_screen.dart';
import 'package:uwin_flutter/src/screens/send_gift_voucher_screen.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';
import 'package:uwin_flutter/src/widgets/complete_profile_builder.dart';

import 'blocs/checkout_bloc.dart';
import 'blocs/partner_card_list_bloc.dart';
import 'blocs/partner_card_show_bloc.dart';
import 'blocs/pos_bloc.dart';
import 'blocs/providers/coupons_bloc_provider.dart';
import 'blocs/providers/edit_profile_bloc_provider.dart';
import 'blocs/providers/flashsells_bloc_provider.dart';
import 'blocs/providers/forget_password_bloc_provider.dart';
import 'blocs/providers/my_wins_bloc_provider.dart';
import 'blocs/providers/pos_query_bloc_provider.dart';
import 'blocs/providers/shop_bloc_provider.dart';
import 'blocs/shop_transaction_bloc.dart';
import 'models/item.dart';
import 'models/sales_order.dart';
import 'screens/checkout_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/find_shop_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_wins_coupons_screen.dart';
import 'screens/my_wins_flash_sales_screen.dart';
import 'screens/my_wins_screen.dart';
import 'screens/my_wins_vouchers_screen.dart';
import 'screens/partner_card_list_screen.dart';
import 'screens/partner_card_new_screen.dart';
import 'screens/partner_card_show_screen.dart';
import 'screens/payment_summary_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/product_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/shipping_address_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/shop_transaction_screen.dart';
import 'screens/shop_voucher_screen.dart';
import 'screens/shop_voucher_success_screen.dart';
import 'screens/win_credits_screen.dart';
import 'widgets/app_secured_screen_builder.dart';

const _defaultCategory = 'Favourite';

class App extends StatelessWidget {
  static const primaryColorShades = MaterialColor(0xFFF58320, {
    50: Color(0xFFFFC88A),
    100: Color(0xFFFEBC73),
    200: Color(0xFFFEB15B),
    300: Color(0xFFFEA644),
    400: Color(0xFFFE9B2C),
    500: Color(0xFFF58320),
    600: Color(0xFFE58213),
    700: Color(0xFFCB7311),
    800: Color(0xFFB2650F),
    900: Color(0xFF98560D),
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: true,
      title: 'uWin',
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        primaryColor: primaryColorShades[500],
        primaryContrastingColor: Colors.white,
      ),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Map<String, dynamic> args = settings.arguments ?? <String, dynamic>{};
    final routeId = '${settings.name} $args';
    FirebaseAnalytics.instance
        .logScreenView(screenName: routeId)
        .then((_) => debugPrint('[App] Analytics Log Screen $routeId'));

    debugPrint('[App] Route $routeId');

    switch (settings.name) {
      case DeleteAccountScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => DeleteAccountScreen(),
          settings: settings,
        );

      case '/register':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return Theme(
              data: Theme.of(context).copyWith(
                textTheme: TextTheme(
                  headline2: TextStyle(color: const Color(0xFFA55F10)),
                ),
                primaryColor: Colors.black,
                hintColor: Colors.white,
              ),
              child: RegisterScreen(),
            );
          },
        );

      case '/my-wins':
        // final tab = args['tab'] ?? 'flashsales';

        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            FlashsellsProvider.of(context).fetch();
            final bloc = MyWinsBlocProvider.of(context);
            bloc.fetch('my_coupons');
            bloc.fetch('my_voucher');

            return MyWinsScreen();
          },
        );

      case '/my-wins/flash-sales':
      case '/my-wins/flashsale':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            FlashsellsProvider.of(context).fetch();

            return MyWinsFlashSalesScreen();
          },
        );

      case '/my-wins/coupons':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            final bloc = MyWinsBlocProvider.of(context);
            bloc.fetch('my_coupons');

            return CompleteProfileBuilder(
              builder: (_) => MyWinsCouponsScreen(),
            );
          },
        );

      case '/my-wins/vouchers':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            final bloc = MyWinsBlocProvider.of(context);
            bloc.fetch('my_voucher');

            return CompleteProfileBuilder(
              builder: (_) => MyWinsVouchersScreen(),
            );
          },
        );

      case '/my-wins/gift-vouchers':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return CompleteProfileBuilder(
              builder: (context) => MyWinsGiftVouchersScreen(),
            );
          },
        );

      case MyWinsOtherCardsScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            Provider.of<OtherCardsBloc>(context, listen: false).init();

            return MyWinsOtherCardsScreen();
          },
        );

      case MyWinsIDCardScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return MyWinsIDCardScreen();
          },
        );

      case '/disclaimer':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return DisclaimerScreen();
          },
        );

      case '/forgot-password':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            final bloc = ForgetPasswordBlocProvider.of(context);
            bloc.emailCtrl.text = args['email'];

            return Theme(
              data: Theme.of(context).copyWith(
                textTheme: TextTheme(
                  headline2: TextStyle(color: const Color(0xFFA55F10)),
                ),
                primaryColor: Colors.black,
                hintColor: Colors.white,
              ),
              child: ForgotPasswordScreen(),
            );
          },
        );

      case '/find-shops':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            final posQueryBloc = PosQueryBlocProvider.of(context);

            return AppSecuredScreenBuilder(
              builder: (BuildContext context) =>
                  FindShopScreen(posQueryBloc, _defaultCategory),
            );
          },
        );

      case '/find-shops/by-category':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => AppSecuredScreenBuilder(
            builder: (BuildContext context) {
              final posQueryBloc = PosQueryBlocProvider.of(context);
              final category = args['category'];
              print('category: $category');
              // posQueryBloc.fetch(category);

              return FindShopScreen(posQueryBloc, category);
            },
          ),
        );

      case '/find-shops/by-category/query':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => AppSecuredScreenBuilder(
            builder: (BuildContext context) {
              final posQueryBloc = PosQueryBlocProvider.of(context);
              final category = args['category'];
              final query = args['query'];
              final autofocus = args['autofocus'];
              // posQueryBloc.fetch(category, query: query);

              return FindShopScreen(
                posQueryBloc,
                category,
                query: query,
                autofocus: autofocus,
              );
            },
          ),
        );

      case '/profile':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => AppSecuredScreenBuilder(
            builder: (BuildContext context) {
              return ProfileScreen();
            },
          ),
        );

      case EditProfileScreen.routeName:
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            EditProfileBlocProvider.of(context).fetchDisclaimer();

            return AppSecuredScreenBuilder(
              checkIncompleteProfile: false,
              builder: (BuildContext context) => EditProfileScreen(),
            );
          },
        );

      case '/shops/show':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(builder: (BuildContext context) {
              final bloc = ShopBlocProvider.of(context);
              bloc.fetch(args['id']);

              return ShopScreen();
            });
          },
        );

      case '/shops/vouchers':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return AppSecuredScreenBuilder(
              builder: (context) {
                return ShopVoucherScreen(args['shop']);
              },
            );
          },
        );

      case '/shops/vouchers/success':
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return AppSecuredScreenBuilder(
              builder: (context) {
                return ShopVoucherSuccessScreen(
                  args['so'],
                );
              },
            );
          },
        );

      case '/win-credits':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return WinCreditsScreen();
              },
            );
          },
        );

      case '/shop-transaction':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final String shopId = args['shopId'];
                final String geolocation = args['geolocation'] ?? '';
                Provider.of<ShopTransactionBloc>(context)
                    .fetch(shopId, geolocation);

                return ShopTransactionScreen();
              },
            );
          },
        );

      case '/partners_cards':
      case '/my-wins/loyalty':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            Provider.of<PartnerCardListBloc>(context).fetch();

            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return CompleteProfileBuilder(
                  builder: (context) => PartnerCardListScreen(),
                );
              },
            );
          },
        );

      case '/partners_cards/show':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final String shopId = args['shopId'];
                Provider.of<PartnerCardShowBloc>(context).fetch(shopId);

                return PartnerCardShowScreen();
              },
            );
          },
        );

      case '/shops/checkout':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return CheckoutScreen(
                    Provider.of<CheckoutBloc>(context), args['shopId']);
              },
            );
          },
        );

      case '/shops/shipping-address':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final SalesOrder so = args['so'];
                final String title = args['title'] ?? 'Shipping Address';
                final String successRedirect = args['successRedirect'];

                return ShippingAddressScreen(
                  so,
                  title,
                  successRedirect: successRedirect,
                );
              },
            );
          },
        );

      case '/shops/payment-summary':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final SalesOrder so = args['so'];
                final String successRedirect = args['successRedirect'];
                final bloc = Provider.of<PaymentSummaryBloc>(context);

                return PaymentSummaryScreen(
                  bloc,
                  so,
                  successRedirect: successRedirect,
                );
              },
            );
          },
        );

      case '/shops/item':
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final Item it = args['item'];

                return ProductScreen(it);
              },
            );
          },
        );

      case '/partners_cards/new':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return PartnerCardNew();
              },
            );
          },
        );

      case '/pos/show':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final String shopId = args['shopId'];
                final String posId = args['posId'];
                Provider.of<PosBloc>(context).fetch(shopId, posId);

                return PosScreen();
              },
            );
          },
        );

      case '/shops/catalog':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final Shop shop = args['shop'];
                CatalogBlocProvider.of(context).fetch(shop);

                return CatalogDialog(shop);
              },
            );
          },
        );

      case '/shop-qrscan':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final Shop shop = args['shop'];

                return QrscanLandingScreen(shop);
              },
            );
          },
        );

      case '/send-gift-voucher':
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                final GiftVoucher gv = args['giftVoucher'];
                return SendGiftVoucherScreen(gv);
              },
            );
          },
        );

      case HowToUseScreen.routeName:
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return HowToUseScreen();
              },
            );
          },
        );

      case BuyGiftVoucherScreen.route:
        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return BuyGiftVoucherScreen();
              },
            );
          },
        );

      case MissionListScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            final bloc = Provider.of<MissionListBloc>(context);
            bloc.fetchList();

            return MissionListScreen();
          },
        );

      case AddOtherCardScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) => AppSecuredScreenBuilder(
            builder: (context) => AddOtherCardScreen(),
          ),
        );

      case MyWinOtherCardDetailsScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => AppSecuredScreenBuilder(
            builder: (_) => MyWinOtherCardDetailsScreen(id: args['id']),
          ),
        );

      case InviteFriendsScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return AppSecuredScreenBuilder(
              builder: (BuildContext context) {
                return InviteFriendsScreen();
              },
            );
          },
        );

      case OtpSignInPinScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(
                textTheme: TextTheme(
                  headline2: TextStyle(color: const Color(0xFFA55F10)),
                ),
                primaryColor: Colors.black,
                hintColor: Colors.white,
                accentColor: const Color(0xFFFE9015)),
            child: OtpSignInPinScreen(token: args['token']),
          ),
          settings: settings,
        );

      case OtpSignInScreen.routeName:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(
                textTheme: TextTheme(
                  headline2: TextStyle(color: const Color(0xFFA55F10)),
                ),
                primaryColor: Colors.black,
                hintColor: Colors.white,
                accentColor: const Color(0xFFFE9015)),
            child: OtpSignInScreen(),
          ),
        );

      default:
        final nodes = settings.name.split('/');
        if (nodes.length == 3 &&
            nodes[1] == MissionSuccessScreen.routeFirstNode) {
          return CupertinoPageRoute(builder: (context) {
            final bloc = Provider.of<MissionListBloc>(context);
            bloc.fetchList();

            return MissionSuccessScreen(mid: nodes[2]);
          });
        }

        if (nodes.length == 4 &&
            nodes[1] == "mission" &&
            nodes[2] == "success") {
          final params = nodes[3].split('=');
          if (params.length == 2) {
            return CupertinoPageRoute(
              builder: (context) {
                final bloc = Provider.of<MissionListBloc>(context);
                bloc.fetchList();

                return MissionSuccessScreen(mid: params[1]);
              },
            );
          }
        }

        return _NoAnimationMaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) => AppSecuredScreenBuilder(
            builder: (BuildContext context) {
              final bloc = FlashsellsProvider.of(context);
              final couponsBloc = CouponsBlocProvider.of(context);
              final myWinsBloc = MyWinsBlocProvider.of(context);

              return HomeScreen(bloc, couponsBloc, myWinsBloc);
            },
          ),
        );
    }
  }
}

class _NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _NoAnimationMaterialPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class AppEnvironment {
  static const stageUsers = <String>[
    "5931982d5f66505b1d83a851", // mouratsing@gmail.com
    "5b6adbca5f665004e0ff9280", // jeanmarie@gmail.com
  ];
  static final AppEnvironment _singleton = AppEnvironment._internal();
  final isDev;
  FirebaseAuth _auth;

  factory AppEnvironment({FirebaseAuth auth}) {
    if (auth == null) {
      auth = FirebaseAuth.instance;
    }
    _singleton._auth = auth;

    return _singleton;
  }

  AppEnvironment._internal() : isDev = _initIsDev();

  static bool _initIsDev() {
    bool flag = false;
    assert(() {
      flag = true;
      return true;
    }());

    return flag;
  }

  bool get isNotDev => !isDev;

  bool get isStage {
    final u = _auth.currentUser;
    final uid = "${u?.uid}";
    return u != null && stageUsers.contains(uid);
  }
}
