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
  String metalName = 'XAU';
  String currency = 'USD';
  String weightUnit = 'gram'; // Set weight unit to "gram" by default
  double currentPrice = 0.0;

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
    var metalPrice = await fetchGoldPrices(metal: metalName, weightUnit: weightUnit, currency: currency);
    if (metalPrice != null) {
      setState(() {
        metalName = metalPrice.metalName;
        currency = metalPrice.currency;
        currentPrice = metalPrice.price;
      });
    }
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
                        'Metal: ',
                        style: TextStyle(fontSize: 18),
                      ),
                      DropdownButton<String>(
                        value: metalName,
                        items: metalNames.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(metalNames[value]!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            metalName = newValue!;
                            updateGoldPrices();
                          });
                        },
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
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Metal: ${metalNames[metalName]}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Currency: $currency',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Price: $currentPrice $currency',
                    style: TextStyle(fontSize: 18),
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