import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gold_tracking_desktop_stock_app/providers/api_key_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Gold is XAU, Silver is XAG, Platinum is XPT, and Palladium is XPD

class MetalPrice {
  final String metalName;
  final String currency;
  final double price;

  MetalPrice({
    required this.metalName,
    required this.currency,
    required this.price,
  });
}

double currentPrice = 0.0;

Future<Map<String, Map<String, double>>?> fetchGoldPrices({
  required BuildContext context,
  required String metal,
  required String weightUnit,
  required String currency,
  String? karat,
}) async {
  final apiKeyProvider = Provider.of<ApiKeyProvider>(context, listen: false);
  var headers = {
    'x-api-key': apiKeyProvider.apiKey,
  };

  var requestUrl =
      'https://gold.g.apised.com/v1/latest?metals=$metal&base_currency=$currency&currencies=$currency&weight_unit=$weightUnit';

  print('Request URL: $requestUrl');
  var request = http.Request('GET', Uri.parse(requestUrl));
  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      // Debug JSON response
      print('JSON Response: $jsonResponse');

      if (jsonResponse['data'] != null &&
          jsonResponse['data']['metal_prices'] != null) {
        var metalPrices = jsonResponse['data']['metal_prices'];
        var price = metalPrices[metal]?['price'];

        print('Extracted Price for $metal in $currency: $price');

        if (price != null) {
          currentPrice = price;

          if (metal == 'XAU' && karat != null) {
            // If it's gold and karat-specific, calculate karat-based prices
            return {
              metal: {
                '24K': price,
                '22K': price * (22 / 24),
                '18K': price * (18 / 24),
                '14K': price * (14 / 24),
                '10K': price * (10 / 24),
              }
            };
          } else {
            // For other metals, return default price
            return {metal: {'default': price}};
          }
        }
      }
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Request failed: $e');
  }

  return null;
}
