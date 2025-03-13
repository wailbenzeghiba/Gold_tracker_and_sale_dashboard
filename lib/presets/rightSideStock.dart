import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:gold_tracking_desktop_stock_app/pages/API/GoldApi.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:gold_tracking_desktop_stock_app/pages/product_list_page.dart';

class RightsidestockT extends StatefulWidget {
  const RightsidestockT({super.key});

  @override
  _RightsidestockTState createState() => _RightsidestockTState();
}

class _RightsidestockTState extends State<RightsidestockT> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _basePriceController = TextEditingController(); // Add base price controller
  String _selectedType = 'Gold';
  String? _selectedKarat;
  double _price = 0.0;
  String currency = 'DZD'; // Define the currency variable

  final List<String> _metalTypes = ['Gold', 'Silver', 'Platinum', 'Palladium'];
  final List<String> _goldKarats = ['24K', '22K', '18K', '14K', '10K'];
  final List<String> _currencies = ['USD', 'EUR', 'DZD', 'GBP'];

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
                        'Stock Prices',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.list),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductListPage()),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Product Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a product name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(labelText: 'Metal Type'),
                          items: _metalTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                              _selectedKarat = null;
                            });
                          },
                        ),
                        if (_selectedType == 'Gold')
                          DropdownButtonFormField<String>(
                            value: _selectedKarat,
                            decoration: InputDecoration(labelText: 'Karat'),
                            items: _goldKarats.map((String karat) {
                              return DropdownMenuItem<String>(
                                value: karat,
                                child: Text(karat),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedKarat = newValue;
                              });
                            },
                          ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(labelText: 'Weight (grams)'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the weight';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the quantity';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _sellPriceController,
                          decoration: InputDecoration(labelText: 'Sell Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the sell price';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _basePriceController, // Add base price field
                          decoration: InputDecoration(labelText: 'Base Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the base price';
                            }
                            return null;
                          },
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
                              items: _currencies.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  currency = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              double weight = double.parse(_weightController.text);
                              double pricePerGram = await _getPricePerGram();
                              double totalPrice = weight * pricePerGram;

                              Map<String, dynamic> product = {
                                'name': _nameController.text,
                                'type': _selectedType,
                                'karat': _selectedKarat,
                                'weight': weight,
                                'price': totalPrice,
                                'quantity': int.parse(_quantityController.text),
                                'sell_price': double.parse(_sellPriceController.text),
                                'base_price': double.parse(_basePriceController.text), // Add base price to product
                              };

                              await DatabaseHelper().insertProduct(product);
                              setState(() {});
                            }
                          },
                          child: Text('Add Product'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _getPricePerGram() async {
    var metalPrices = await fetchGoldPrices(
      metal: _selectedType == 'Gold' ? 'XAU' : _selectedType == 'Silver' ? 'XAG' : _selectedType == 'Platinum' ? 'XPT' : 'XPD',
      weightUnit: 'gram',
      currency: currency,
      karat: _selectedKarat,
    );

    if (metalPrices != null) {
      if (_selectedType == 'Gold' && _selectedKarat != null) {
        return metalPrices['XAU']?[_selectedKarat] ?? 0.0;
      } else {
        return metalPrices[_selectedType == 'Gold' ? 'XAU' : _selectedType == 'Silver' ? 'XAG' : _selectedType == 'Platinum' ? 'XPT' : 'XPD']?['default'] ?? 0.0;
      }
    } else {
      return 0.0;
    }
  }
}