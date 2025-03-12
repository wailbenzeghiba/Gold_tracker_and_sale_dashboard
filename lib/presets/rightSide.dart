import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/pages/API/GoldApi.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';

class Rightside extends StatefulWidget {
  const Rightside({super.key});

  @override
  _RightsideState createState() => _RightsideState();
}

class _RightsideState extends State<Rightside> {
  String currency = 'USD';
  String weightUnit = 'gram'; // Set weight unit to "gram" by default
  Map<String, double> prices = {};
  bool isLoading = false;

  final Map<String, String> metalNames = {
    'XAU': 'Gold',
    'XAG': 'Silver',
    'XPT': 'Platinum',
    'XPD': 'Palladium',
  };

  @override
  void initState() {
    super.initState();
    updateGoldPrices();
  }

  Future<void> updateGoldPrices() async {
    setState(() {
      isLoading = true;
    });

    Map<String, double> newPrices = {};
    for (String metal in metalNames.keys) {
      var metalPrice = await fetchGoldPrices(metal: metal, weightUnit: weightUnit, currency: currency);
      if (metalPrice != null) {
        newPrices[metal] = metalPrice.price;
      }
    }

    setState(() {
      prices = newPrices;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  Windowbuttons(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metal Prices',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: updateGoldPrices,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Currency: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      DropdownButton<String>(
                        value: currency,
                        items: <String>['USD', 'EUR', 'DZD', 'GBP']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            currency = newValue!;
                            updateGoldPrices();
                          });
                        },
                      ),
                      SizedBox(width: 280),
                      Text(
                        'Weight Unit: gram',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: metalNames.keys.map((metal) {
                      return Column(
                        children: [
                          Text(
                            metalNames[metal]!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            isLoading
                                ? 'Loading...'
                                : prices[metal] != null
                                    ? '${prices[metal]!.toStringAsFixed(2)} $currency '
                                    : 'N/A',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}