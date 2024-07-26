import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uwin_flutter/src/blocs/add_other_card_bloc.dart';
import 'package:uwin_flutter/src/blocs/buy_gift_voucher_bloc.dart';
import 'package:uwin_flutter/src/blocs/delete_account_bloc.dart';
import 'package:uwin_flutter/src/blocs/home_bloc.dart';
import 'package:uwin_flutter/src/blocs/how_to_use_bloc.dart';
import 'package:uwin_flutter/src/blocs/invite_friends_bloc.dart';
import 'package:uwin_flutter/src/blocs/mission_list_bloc.dart';
import 'package:uwin_flutter/src/blocs/mission_success_bloc.dart';
import 'package:uwin_flutter/src/blocs/my_win_other_card_details_bloc.dart';
import 'package:uwin_flutter/src/blocs/other_cards_bloc.dart';
import 'package:uwin_flutter/src/blocs/send_gift_voucher_bloc.dart';
import 'package:uwin_flutter/src/blocs/shop_voucher_success_bloc.dart';
import 'package:uwin_flutter/src/blocs/sport_shop_bloc.dart';
import 'package:uwin_flutter/src/blocs/win_credits_bloc.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/mission_repository.dart';
import 'package:uwin_flutter/src/repositories/other_card_repository.dart';
import 'package:uwin_flutter/src/repositories/post_repository.dart';
import 'package:uwin_flutter/src/repositories/product_item_repository.dart';
import 'package:uwin_flutter/src/repositories/shop_type_repository.dart';
import 'package:uwin_flutter/src/repositories/win_credits_repository.dart';
import 'package:uwin_flutter/src/scanner/barcode_scanner.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';

import 'src/App.dart';
import 'src/blocs/checkout_bloc.dart';
import 'src/blocs/partner_card_add_bloc.dart';
import 'src/blocs/partner_card_list_bloc.dart';
import 'src/blocs/partner_card_show_bloc.dart';
import 'src/blocs/payment_summary_bloc.dart';
import 'src/blocs/pos_bloc.dart';
import 'src/blocs/providers/auth_block_provider.dart';
import 'src/blocs/providers/catalog_bloc_provider.dart';
import 'src/blocs/providers/coupons_bloc_provider.dart';
import 'src/blocs/providers/edit_profile_bloc_provider.dart';
import 'src/blocs/providers/flashsells_bloc_provider.dart';
import 'src/blocs/providers/forget_password_bloc_provider.dart';
import 'src/blocs/providers/my_wins_bloc_provider.dart';
import 'src/blocs/providers/pos_query_bloc_provider.dart';
import 'src/blocs/providers/register_bloc_provider.dart';
import 'src/blocs/providers/shop_bloc_provider.dart';
import 'src/blocs/providers/shop_voucher_bloc_provider.dart';
import 'src/blocs/scan_partner_qr_bloc.dart';
import 'src/blocs/shipping_address_bloc.dart';
import 'src/blocs/shop_transaction_bloc.dart';
import 'src/cache/http_cache_manager.dart';
import 'src/database/database_factory.dart' as uwindb;
import 'src/repositories/banner_repository.dart';
import 'src/repositories/city_repository.dart';
import 'src/repositories/coupon_repository.dart';
import 'src/repositories/gender_repository.dart';
import 'src/repositories/item_ext_repository.dart';
import 'src/repositories/item_repository.dart';
import 'src/repositories/marital_status_repository.dart';
import 'src/repositories/occupation_repository.dart';
import 'src/repositories/payment_repository.dart';
import 'src/repositories/sales_order_repository.dart';
import 'src/repositories/shop_repository.dart';
import 'src/repositories/shop_voucher_repository.dart';
import 'src/repositories/transaction_repository.dart';
import 'src/repositories/transportation_repository.dart';
import 'src/repositories/user_repository.dart';
import 'src/repositories/voucher_repository.dart';

void main() {
  debugPaintSizeEnabled = false;
  HttpOverrides.global = MyHttpOverrides();

  runApp(_BootstrapApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'uWin',
          ),
        ),
      ),
    );
  }
}

class _BootstrapApp extends StatefulWidget {
  _BootstrapApp();

  @override
  __BootstrapAppState createState() => __BootstrapAppState();
}

class __BootstrapAppState extends State<_BootstrapApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final dbFactory = uwindb.DatabaseFactory();
  UserRepository userRepo;
  AuthService authService;

  @override
  void initState() {
    userRepo = UserRepository(http.Client());
    authService = AuthService(http.Client(), 'https://u-win.shop');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppleSignInAvailable>(
        future: AppleSignInAvailable.check(),
        builder: (context, asiaSnap) {
          if (!asiaSnap.hasData) {
            return Container();
          }

          return Provider<SportShopBloc>(
            create: (_) => SportShopBloc(),
            dispose: (_, bloc) => bloc.dispose(),
            child: Provider<AppleSignInAvailable>(
              create: (_) => asiaSnap.hasError
                  ? AppleSignInAvailable(false)
                  : asiaSnap.data,
              child: FutureBuilder<Object>(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(
                          child: Center(child: Text(snapshot.error)),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                    );
                  }

                  return FutureBuilder<HttpCacheManager>(
                    future: dbFactory.create('uwin_0016', 16).then(
                          (db) => HttpCacheManager(db),
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('[main] $snapshot.error}');

                        return Container();
                      }

                      if (!snapshot.hasData) {
                        return MaterialApp(
                          home: Scaffold(
                            body: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                        );
                      }

                      return ForgetPasswordBlocProvider(
                        child: AuthBlocProvider(
                          userRepo: userRepo,
                          authService: authService,
                          child: _BootstrapSecuredApp(snapshot.data, userRepo),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        });
  }
}

class _BootstrapSecuredApp extends StatefulWidget {
  final UserRepository userRepo;
  final HttpCacheManager cache;

  _BootstrapSecuredApp(this.cache, this.userRepo);

  @override
  __BootstrapSecuredAppState createState() => __BootstrapSecuredAppState();
}

class __BootstrapSecuredAppState extends State<_BootstrapSecuredApp> {
  CityRepository cityRepo;
  GenderRepository genderRepo;
  OccupationRepository occupationRepo;
  MaritalStatusRepository maritalStatusRepo;
  TransportationRepository transportationRepo;
  ShopVoucherRepository shopVoucherRepo;
  ShopRepository shopRepo;
  ItemRepository itemRepo;
  SalesOrderRepository soRepo;
  PaymentRepository paymentRepo;
  ItemExtRepository itemExtRepo;
  BannerRepository bannerRepo;
  ProductItemRepository productItemRepo;
  http.Client httpClient;
  String firebaseFunctionsUrl;

  @override
  void initState() {
    httpClient = http.Client();
    cityRepo = CityRepository(httpClient);
    genderRepo = GenderRepository(httpClient);
    occupationRepo = OccupationRepository(httpClient);
    maritalStatusRepo = MaritalStatusRepository(httpClient);
    transportationRepo = TransportationRepository(httpClient);
    shopVoucherRepo = ShopVoucherRepository();
    shopRepo = ShopRepository();
    itemExtRepo = ItemExtRepository();
    itemRepo = ItemRepository(itemExtRepo, shopRepo);
    soRepo = SalesOrderRepository(widget.userRepo);
    paymentRepo = PaymentRepository();
    bannerRepo = BannerRepository();
    productItemRepo = ProductItemRepository();
    firebaseFunctionsUrl = 'https://us-central1-uwin-201010.cloudfunctions.net';
    // assert(() {
    //   firebaseFunctionsUrl = 'http://localhost:5000/uwin-201010/us-central1';

    //   return true;
    // }());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    httpClient.close();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = AuthBlocProvider.of(context);
    bloc.autoAuthenticate();
    final authService = bloc.authService;

    final voucherRepo = VoucherRepository(authBloc: bloc);
    final giftVoucherRepo = GiftVoucherRepository();
    final couponRepo = CouponRepository(authBloc: bloc);
    final shopTypeRepo = ShopTypeRepository(
      FirebaseFirestore.instance.collection('shopTypes'),
    );
    final transactionRepo = TransactionRepository(
      authBloc: bloc,
      httpClient: httpClient,
      firebaseFunctionsUrl: firebaseFunctionsUrl,
    );
    final otherCardRepo = OtherCardRepository(
      FirebaseFirestore.instance.collection('users'),
    );
    final barcodeScanner = UwinBarcodeScanner();
    final postRepo = PostRepository(
      FirebaseFirestore.instance.collection('posts'),
    );
    final missionRepo = MissionRepository(httpClient);

    return Provider<AuthBloc>(
      create: (context) => bloc,
      child: Provider<RegisterBloc>(
        create: (_) => RegisterBloc(bloc, authService),
        child: Provider<InviteFriendsBloc>(
          create: (_) => InviteFriendsBloc(bloc, bloc.userRepo),
          child: Provider<MyWinOtherCardDetailsBloc>(
            create: (_) => MyWinOtherCardDetailsBloc(bloc, otherCardRepo),
            dispose: (_, bloc) => bloc.dispose(),
            child: Provider<DeleteAccountBloc>(
              create: (_) => DeleteAccountBloc(bloc.userRepo, bloc),
              child: Provider<MissionListBloc>(
                create: (_) => MissionListBloc(bloc, missionRepo),
                dispose: (_, bloc) => bloc.dispose(),
                child: Provider<MissionSuccessBloc>(
                  create: (_) => MissionSuccessBloc(bloc, missionRepo),
                  child: Provider<AddOtherCardBloc>(
                    create: (_) => AddOtherCardBloc(
                      otherCardRepo,
                      bloc,
                    ),
                    dispose: (_, bloc) => dispose(),
                    child: Provider<HomeBloc>(
                      create: (_) => HomeBloc(shopTypeRepo),
                      dispose: (_, bloc) => bloc.dispose(),
                      child: Provider<HowToUseBloc>(
                        create: (_) => HowToUseBloc(postRepo),
                        child: Provider<OtherCardsBloc>(
                          create: (_) => OtherCardsBloc(
                            bloc,
                            otherCardRepo,
                            barcodeScanner,
                          ),
                          dispose: (_, val) => val.dispose(),
                          child: Provider<BuyGiftVouchersBloc>(
                            create: (_) => BuyGiftVouchersBloc(giftVoucherRepo),
                            dispose: (_, val) => val.dispose(),
                            child: Provider<WinCreditsBloc>(
                              create: (context) => WinCreditsBloc(
                                WinCreditsRepository(),
                              ),
                              dispose: (context, val) => val.dispose(),
                              child: Provider<PaymentSummaryBloc>(
                                create: (context) => PaymentSummaryBloc(
                                  paymentRepo: paymentRepo,
                                  soRepo: soRepo,
                                ),
                                dispose: (context, val) => val.dispose(),
                                child: Provider<ShippingAddressBloc>(
                                  create: (context) => ShippingAddressBloc(
                                    authBloc: bloc,
                                    shopRepo: shopRepo,
                                    soRepo: soRepo,
                                  ),
                                  dispose: (context, val) => val.dispose(),
                                  child: Provider<CheckoutBloc>(
                                    create: (context) => CheckoutBloc(
                                      authBloc: bloc,
                                      shopRepo: shopRepo,
                                      itemRepo: itemRepo,
                                      soRepo: soRepo,
                                      voucherRepo: voucherRepo,
                                    ),
                                    dispose: (context, val) => val.dispose(),
                                    child: Provider<PartnerCardListBloc>(
                                      create: (context) => PartnerCardListBloc(
                                        shopRepo: shopRepo,
                                        authBloc: bloc,
                                      ),
                                      dispose: (context, value) =>
                                          value.dispose(),
                                      child: Provider<PartnerCardShowBloc>(
                                        create: (context) =>
                                            PartnerCardShowBloc(
                                          authBloc: bloc,
                                          shopRepo: shopRepo,
                                        ),
                                        dispose: (context, value) =>
                                            value.dispose(),
                                        child: Provider<PartnerCardAddBloc>(
                                          create: (context) =>
                                              PartnerCardAddBloc(),
                                          dispose: (context, value) =>
                                              value.dispose(),
                                          child: Provider<SendGiftVoucherBloc>(
                                            create: (_) => SendGiftVoucherBloc(
                                                bloc, giftVoucherRepo),
                                            dispose: (_, val) => val.dispose(),
                                            child:
                                                Provider<ShopTransactionBloc>(
                                              create: (context) =>
                                                  ShopTransactionBloc(
                                                authBloc: bloc,
                                                shopRepo: shopRepo,
                                                userRepo: bloc.userRepo,
                                                voucherRepo: voucherRepo,
                                                giftVoucherRepo:
                                                    giftVoucherRepo,
                                                couponRepo: couponRepo,
                                                transactionRepo:
                                                    transactionRepo,
                                              ),
                                              dispose: (context, value) =>
                                                  value.dispose(),
                                              child:
                                                  Provider<ScanPartnerQrBloc>(
                                                create: (context) =>
                                                    ScanPartnerQrBloc(
                                                  authBloc: bloc,
                                                  shopRepo: shopRepo,
                                                  transactionRepo:
                                                      transactionRepo,
                                                ),
                                                dispose: (context, value) =>
                                                    value.dispose,
                                                child: Provider<
                                                    ShopVoucherSuccessBloc>(
                                                  create: (_) =>
                                                      ShopVoucherSuccessBloc(
                                                          bloc,
                                                          shopRepo,
                                                          giftVoucherRepo),
                                                  child:
                                                      EditProfileBlocProvider(
                                                    cityRepo: cityRepo,
                                                    genderRepo: genderRepo,
                                                    occupationRepo:
                                                        occupationRepo,
                                                    maritalStatusRepo:
                                                        maritalStatusRepo,
                                                    transportationRepo:
                                                        transportationRepo,
                                                    userRepo: bloc.userRepo,
                                                    authBloc: bloc,
                                                    child:
                                                        ShopVoucherBlocProvider(
                                                      authBloc: bloc,
                                                      soRepo: soRepo,
                                                      repo: shopVoucherRepo,
                                                      child:
                                                          RegisterBlocProvider(
                                                        authBloc: bloc,
                                                        authService:
                                                            authService,
                                                        child:
                                                            MyWinsBlocProvider(
                                                          authBloc: bloc,
                                                          voucherRepo:
                                                              voucherRepo,
                                                          giftVoucherRepo:
                                                              giftVoucherRepo,
                                                          child:
                                                              PosQueryBlocProvider(
                                                            authBloc: bloc,
                                                            cache: widget.cache,
                                                            voucherRepo:
                                                                voucherRepo,
                                                            shopTypeRepo:
                                                                shopTypeRepo,
                                                            child:
                                                                CatalogBlocProvider(
                                                              authBloc: bloc,
                                                              productItemRepo:
                                                                  productItemRepo,
                                                              child:
                                                                  ShopBlocProvider(
                                                                authBloc: bloc,
                                                                cache: widget
                                                                    .cache,
                                                                child:
                                                                    FlashsellsProvider(
                                                                  authBloc:
                                                                      bloc,
                                                                  cache: widget
                                                                      .cache,
                                                                  bannerRepo:
                                                                      bannerRepo,
                                                                  child:
                                                                      CouponsBlocProvider(
                                                                    authBloc:
                                                                        bloc,
                                                                    child: Provider(
                                                                        dispose: (context, val) => val.dispose(),
                                                                        create: (context) => PosBloc(
                                                                              authBloc: bloc,
                                                                              shopRepo: shopRepo,
                                                                            ),
                                                                        child: App()),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    if (!Platform.isIOS) {
      return AppleSignInAvailable(false);
    }

    try {
      final isAvailable = await SignInWithApple.isAvailable();
      return AppleSignInAvailable(isAvailable);
    } catch (err) {
      print('[main.dart] Could not evaluate apple sign in availability');
      if (err is Error) {
        print(err.stackTrace);
      } else {
        print(err);
      }
      return AppleSignInAvailable(false);
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
