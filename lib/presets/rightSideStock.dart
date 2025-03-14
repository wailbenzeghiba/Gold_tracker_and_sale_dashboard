import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:gold_tracking_desktop_stock_app/pages/product_list_page.dart';
import 'package:gold_tracking_desktop_stock_app/pages/API/GoldApi.dart';

class RightSideStock extends StatefulWidget {
  const RightSideStock({super.key});

  @override
  _RightSideStockState createState() => _RightSideStockState();
}

class _RightSideStockState extends State<RightSideStock> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _basePriceController = TextEditingController();

  String _selectedType = 'Gold';
  String? _selectedKarat;
  String currency = 'DZD';

  final List<String> _metalTypes = ['Gold', 'Silver', 'Platinum', 'Palladium'];
  final List<String> _goldKarats = ['24K', '22K', '18K', '14K', '10K'];
  final List<String> _currencies = ['USD', 'EUR', 'DZD', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 217, 215, 215),
        child: Column(
          children: [
            // Top bar with consistent color
            Container(
              color: Theme.of(context).cardColor, // Matching dashboard color
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock Prices',
                          style: TextStyle(
                            fontSize: 22,
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
                                  MaterialPageRoute(
                                    builder: (context) => ProductListPage(),
                                  ),
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

                    // Form Section
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a product name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Metal Type Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Metal Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
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
                          SizedBox(height: 16),

                          // Karat Dropdown (for Gold only)
                          if (_selectedType == 'Gold')
                            DropdownButtonFormField<String>(
                              value: _selectedKarat,
                              decoration: InputDecoration(
                                labelText: 'Karat',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              fillColor: Colors.white,
                              ),
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

                          // Weight
                          TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight (grams)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the weight';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Quantity
                          TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the quantity';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Sell Price
                          TextFormField(
                            controller: _sellPriceController,
                            decoration: InputDecoration(
                              labelText: 'Sell Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),

                          // Base Price
                          TextFormField(
                            controller: _basePriceController,
                            decoration: InputDecoration(
                              labelText: 'Base Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),

                          // Currency Selector
                          Row(
                            children: [
                              Text(
                                'Currency:',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 8),
                              DropdownButton<String>(
                                focusColor: Colors.white,
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
                          SizedBox(height: 24),

                          // Submit Button
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  double weight =
                                      double.parse(_weightController.text);
                                  double pricePerGram =
                                      await _getPricePerGram(context);
                                  double totalPrice = weight * pricePerGram;
                            
                                  Map<String, dynamic> product = {
                                    'name': _nameController.text,
                                    'type': _selectedType,
                                    'karat': _selectedKarat,
                                    'weight': weight,
                                    'price': totalPrice,
                                    'quantity':
                                        int.parse(_quantityController.text),
                                    'sell_price':
                                        double.parse(_sellPriceController.text),
                                    'base_price':
                                        double.parse(_basePriceController.text),
                                  };
                            
                                  await DatabaseHelper().insertProduct(product);
                                  setState(() {});
                                }
                              },
                              child: Text('Add Product', style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor, // Modern dark color
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4, // Soft shadow for depth
                                ),
                              
                            ),
                            
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _getPricePerGram(BuildContext context) async {
    var metalPrices = await fetchGoldPrices(
      context: context, // Pass the BuildContext here
      metal: _selectedType == 'Gold'
          ? 'XAU'
          : _selectedType == 'Silver'
              ? 'XAG'
              : _selectedType == 'Platinum'
                  ? 'XPT'
                  : 'XPD',
      weightUnit: 'gram',
      currency: currency,
      karat: _selectedKarat,
    );

    if (metalPrices != null) {
      if (_selectedType == 'Gold' && _selectedKarat != null) {
        return metalPrices['XAU']?[_selectedKarat] ?? 0.0;
      } else {
        return metalPrices[_selectedType == 'Gold'
                ? 'XAU'
                : _selectedType == 'Silver'
                    ? 'XAG'
                    : _selectedType == 'Platinum'
                        ? 'XPT'
                        : 'XPD']?['default'] ??
            0.0;
      }
    } else {
      return 0.0;
    }
  }
}
