import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/pages/API/GoldApi.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:provider/provider.dart';
import 'package:gold_tracking_desktop_stock_app/providers/api_key_provider.dart';

class Rightside extends StatefulWidget {
  const Rightside({super.key});

  @override
  _RightsideState createState() => _RightsideState();
}

class _RightsideState extends State<Rightside> {
  String currency = 'DZD';
  String weightUnit = 'gram';
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
    setState(() => isLoading = true);

    Map<String, Map<String, double>> newPrices = {};
    for (String metal in metalNames.keys) {
      newPrices[metal] = {};
      if (metal == 'XAU') {
        for (String karat in goldKarats) {
          var metalPrice = await fetchGoldPrices(
            context: context, // Pass the BuildContext here
            metal: metal,
            weightUnit: weightUnit,
            currency: currency,
            karat: karat,
          );
          if (metalPrice != null) {
            newPrices[metal]![karat] = metalPrice[metal]![karat]!;
          }
        }
      } else {
        var metalPrice = await fetchGoldPrices(
          context: context, // Pass the BuildContext here
          metal: metal,
          weightUnit: weightUnit,
          currency: currency,
        );
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
    return Consumer<ApiKeyProvider>(
      builder: (context, apiKeyProvider, child) {
        return Expanded(
          child: Container(
            color: const Color.fromARGB(255, 217, 215, 215), // Light background color
            child: Column(
              children: [
                /// Top Bar
                Container(
                  color: Theme.of(context).cardColor, // Consistent top bar color
                  child: WindowTitleBarBox(
                    child: Row(
                      children: [
                        Expanded(child: MoveWindow()),
                        Windowbuttons(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Metal Prices',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, size: 24),
                              onPressed: updateGoldPrices,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        /// Currency and Weight Unit Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Currency:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: currency,
                                  items: ['USD', 'EUR', 'DZD', 'GBP']
                                      .map((value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      currency = value!;
                                      updateGoldPrices();
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'Weight Unit: gram',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        /// Metal Price Cards
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: metalNames.keys.map((metal) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      metalNames[metal]!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 6, 6, 6),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    if (metal == 'XAU')
                                      ...goldKarats.map((karat) {
                                        return Text(
                                          isLoading
                                              ? 'Loading...'
                                              : prices[metal]?[karat] != null
                                                  ? '$karat: ${prices[metal]![karat]!.toStringAsFixed(2)} $currency'
                                                  : '$karat: N/A',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: const Color.fromARGB(255, 14, 14, 14),
                                          ),
                                        );
                                      }).toList()
                                    else
                                      Text(
                                        isLoading
                                            ? 'Loading...'
                                            : prices[metal]?['default'] != null
                                                ? '${prices[metal]!['default']!.toStringAsFixed(2)} $currency'
                                                : 'N/A',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(255, 15, 15, 15),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
