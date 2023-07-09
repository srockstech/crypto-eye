import 'package:coin_eye/screens/welcome_screen.dart';
import 'package:coin_eye/utilities/bottom_navigation_menu.dart';
import 'package:coin_eye/utilities/field_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/coin_data.dart';
import '../utilities/coin_card.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen>
    with TickerProviderStateMixin {
  TabController _tabController;
  String selectedCurrencySymbol = '\$';
  String selectedCurrencyCode = 'USD';
  Widget allCoinsTab;
  Widget selectedCurrencyIcon;
  var coinsData;
  CoinData coinData;
  bool disposed;
  int selectedIndex = 0;

  // bool updatePrice = false;

  List<PopupMenuItem<String>> getPopupFlatCurrenciesList() {
    List<PopupMenuItem<String>> popupFlatCurrencies = [];
    currenciesList.forEach((key, value) {
      PopupMenuItem<String> popupFlatCurrency = PopupMenuItem(
        child: Text('$value $key'),
        value: key,
      );
      popupFlatCurrencies.add(popupFlatCurrency);
    });
    return popupFlatCurrencies;
  }

  List<PopupMenuItem<String>> getPopupMenuItemsList() {
    List<PopupMenuItem<String>> popupMenuItems = [
      PopupMenuItem(
        child: Text('Logout'),
        value: 'logout',
      )
    ];
    return popupMenuItems;
  }

  void updateUI() async {
    for (; disposed == false;) {
      print('fetching data from api...');
      coinData = CoinData(currency: selectedCurrencyCode);
      coinsData = await coinData.fetchCoinsMetaData();
      if (coinData != null) {
        setState(() {
          allCoinsTab = Column(
            children: <Widget>[
              FieldBanner(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (listViewContext, index) {
                    try {
                      var priceInString, coins24HChangeInString;
                      double price =
                          coinData.getCoinsPrice().values.toList()[index];

                      if (price < 1) {
                        priceInString = price.toStringAsFixed(6);
                      } else {
                        priceInString = price.toStringAsFixed(2);
                      }
                      double coin24HChange =
                          coinData.getCoins24Change().values.toList()[index];

                      coins24HChangeInString = coin24HChange.toStringAsFixed(2);

                      String logoUrl = coinsData['data'][coinData
                          .getCoinsName()
                          .keys
                          .toList()[index]
                          .toUpperCase()][0]['logo'];

                      String coinName;
                      coinName = coinData.getCoinsName().values.toList()[index];

                      String coinCode;
                      coinCode = coinData.getCoinsName().keys.toList()[index];

                      return CoinCard(
                        coinName: coinName,
                        coinCode: coinCode,
                        rate: priceInString,
                        percent24HChange: coins24HChangeInString,
                        selectedCurrencyCode: selectedCurrencyCode,
                        logoUrl: logoUrl,
                      );
                    } catch (e) {
                      return Center(
                        child: SpinKitThreeBounce(
                          color: Colors.grey[200],
                          size: 30,
                        ),
                      );
                    }
                  },
                  itemCount: coinData.getCoinsName().length,
                ),
              ),
            ],
          );

          selectedCurrencyIcon = Text(
            selectedCurrencySymbol,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          );
        });

        await Future.delayed(Duration(seconds: 30));
      }
    }
  }

  @override
  void initState() {
    disposed = false;
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    allCoinsTab = Center(
      child: SpinKitRing(
        color: Colors.black,
        size: 30,
        lineWidth: 4,
      ),
    );
    selectedCurrencyIcon = Text(
      selectedCurrencySymbol,
      style: TextStyle(
        color: Colors.black,
        fontSize: 23,
        fontWeight: FontWeight.w500,
      ),
    );
    updateUI();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationMenu(
          screenWidth: screenWidth,
          selectedIndex: selectedIndex,
          onTap: (index) {
            if (index != selectedIndex) {
              setState(() {
                selectedIndex = index;
              });
            }
          },
        ),
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.1,
          elevation: 5,
          shadowColor: Colors.grey[100],
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                'Coins',
                style: TextStyle(
                  height: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: screenHeight * 0.038,
                  letterSpacing: -1.5,
                ),
              ),
              // Text(
              //   'eye',
              //   style: TextStyle(
              //     height: 1,
              //     color: Color(0xFF2BFFF1),
              //     // shadows: <Shadow>[
              //     //   Shadow(
              //     //     color: Color(0xFF2BFFF1),
              //     //     offset: Offset(0, 0),
              //     //     blurRadius: 5,
              //     //   ),
              //     // ],
              //     fontWeight: FontWeight.w900,
              //     fontSize: screenHeight * 0.038,
              //     letterSpacing: -1.5,
              //   ),
              // ),
            ],
          ),
          leadingWidth: 0,
          leading: SizedBox(
            width: 0,
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.024,
                ),
                PopupMenuButton<String>(
                  splashRadius: screenHeight * 0.03,
                  itemBuilder: (BuildContext context) {
                    return getPopupFlatCurrenciesList();
                  },
                  onSelected: (key) {
                    selectedCurrencySymbol = currenciesList[key];
                    selectedCurrencyCode = key;
                    setState(() {
                      selectedCurrencyIcon = SpinKitRing(
                        color: Colors.white,
                        size: screenHeight * 0.025,
                        lineWidth: 2,
                      );
                    });
                    updateUI();
                  },
                  icon: selectedCurrencyIcon,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.024,
                ),
                PopupMenuButton<String>(
                  splashRadius: screenHeight * 0.03,
                  itemBuilder: (BuildContext context) {
                    return getPopupMenuItemsList();
                  },
                  onSelected: (key) {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen()));
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screenHeight * 0.02,
            ),
          ],
          bottom: TabBar(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicatorColor: Color(0xFF2BFFF1),
            controller: _tabController,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Text(
                  'All Coins',
                  style: TextStyle(
                      color: Colors.black, fontSize: screenHeight * 0.018),
                ),
              ),
              Tab(
                child: Text(
                  'My Watchlist',
                  style: TextStyle(
                      color: Colors.black, fontSize: screenHeight * 0.018),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            allCoinsTab,
            Center(
              child: Container(
                margin: EdgeInsets.all(50),
                child: Text(
                  'You have not added any coin to your watchlist.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
