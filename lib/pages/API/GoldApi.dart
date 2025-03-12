import 'package:http/http.dart' as http;
import 'dart:convert';

// gold is XAU And silver is XAG Platinum is XPT and Palladium is XPD

class MetalPrice {
  final String metalName;
  final String currency;
  final double price;

  MetalPrice({required this.metalName, required this.currency, required this.price});
}

double currentPrice = 0.0;

Future<Map<String, Map<String, double>>?> fetchGoldPrices({
  required String metal,
  required String weightUnit,
  required String currency,
  String? karat,
}) async {
  var headers = {
    'x-api-key': 'sk_D3562492a6A1bc3eC38cE319373e9Ab5bD0e1e1c65cE14fd'
  };

  var requestUrl = 'https://gold.g.apised.com/v1/latest?metals=$metal&base_currency=$currency&currencies=$currency&weight_unit=$weightUnit';
  
  if (karat != null) {
    requestUrl += '&karat=$karat';
  }

  print('Request URL: $requestUrl');
  var request = http.Request('GET', Uri.parse(requestUrl));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseBody);

    // Debug print to check the JSON response structure
    print('JSON Response: $jsonResponse');

    // Check if the JSON structure is as expected
    if (jsonResponse != null && jsonResponse['data'] != null && jsonResponse['data']['metal_prices'] != null) {
      var prices = jsonResponse['data'];
      var metalPrices = prices['metal_prices'];

      // Debug print to check the metal prices structure
      print('Metal Prices: $metalPrices');

      // Example of extracting values for the selected metal in the selected currency
      var price = metalPrices[metal]?['price'];

      // Debug print to check the extracted price
      print('Extracted Price for $metal in $currency: $price');

      if (price != null) {
        currentPrice = price;
        return {metal: {karat ?? 'default': price}};
      } else {
        print('Price not found for $metal in $currency');
        return null;
      }
    } else {
      print('Unexpected JSON structure');
      return null;
    }
  } else {
    print('Error: ${response.reasonPhrase}');
    return null;
  }
}