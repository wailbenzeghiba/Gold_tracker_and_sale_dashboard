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
  String currency = 'DZD';
  String weightUnit = 'gram'; // Set weight unit to "gram" by default
  Map<String, Map<String, double>> prices = {};
  bool isLoading = false;

  final Map<String, String> metalNames = {
    'XAU': 'Gold',
    'XAG': 'Silver',
    'XPT': 'Platinum',
    'XPD': 'Palladium',
  };

  final List<String> goldKarats = ['24K', '22K', '18K', '14K', '10K'];

  @override
  void initState() {
    super.initState();
    updateGoldPrices();
  }

  Future<void> updateGoldPrices() async {
    setState(() {
      isLoading = true;
    });

    Map<String, Map<String, double>> newPrices = {};
    for (String metal in metalNames.keys) {
      newPrices[metal] = {};
      if (metal == 'XAU') {
        for (String karat in goldKarats) {
          var metalPrice = await fetchGoldPrices(metal: metal, weightUnit: weightUnit, currency: currency, karat: karat);
          if (metalPrice != null) {
            newPrices[metal]![karat] = metalPrice[metal]![karat]!;
          }
        }
      } else {
        var metalPrice = await fetchGoldPrices(metal: metal, weightUnit: weightUnit, currency: currency);
        if (metalPrice != null) {
          newPrices[metal]!['default'] = metalPrice[metal]!['default']!;
        }
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
                      SizedBox(width: 50),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ 
                      Row(
                        children: [
                          Text(
                          'Currency: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 8),
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
                        ] 
                      ),
                     
                      
                      Text(
                        'Weight Unit: gram',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: metalNames.keys.map((metal) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metalNames[metal]!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          if (metal == 'XAU')
                            ...goldKarats.map((karat) {
                              return Text(
                                isLoading
                                    ? 'Loading...'
                                    : prices[metal]?[karat] != null
                                        ? '$karat: ${prices[metal]![karat]!.toStringAsFixed(2)} $currency '
                                        : '$karat: N/A',
                                style: TextStyle(fontSize: 18),
                              );
                            }).toList()
                          else
                            Text(
                              isLoading
                                  ? 'Loading...'
                                  : prices[metal]?['default'] != null
                                      ? '${prices[metal]!['default']!.toStringAsFixed(2)} $currency '
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