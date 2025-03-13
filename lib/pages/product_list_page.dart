import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:gold_tracking_desktop_stock_app/theme/theme.dart';
import 'package:gold_tracking_desktop_stock_app/pages/API/GoldApi.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _products = await DatabaseHelper().getProducts();
    _filteredProducts = _products;
    setState(() {});
  }

  void _searchProducts(String query) {
    final filtered = _products.where((product) {
      final nameLower = product['name'].toLowerCase();
      final typeLower = product['type'].toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) || typeLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product['name']);
    final _weightController = TextEditingController(text: product['weight'].toString());
    final _quantityController = TextEditingController(text: product['quantity'].toString());
    final _sellPriceController = TextEditingController(text: product['sell_price'].toString());
    String _selectedType = product['type'];
    String? _selectedKarat = product['karat'];
    String currency = 'DZD'; // Define the currency variable

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Product'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
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
                        items: ['Gold', 'Silver', 'Platinum', 'Palladium'].map((String type) {
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
                          items: ['24K', '22K', '18K', '14K', '10K'].map((String karat) {
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
                      Row(
                        children: [
                          Text(
                            'Currency: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          DropdownButton<String>(
                            value: currency,
                            items: ['USD', 'EUR', 'DZD', 'GBP'].map((String value) {
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        double weight = double.parse(_weightController.text);
                        double pricePerGram = await _getPricePerGram(_selectedType, _selectedKarat, currency);
                        double totalPrice = weight * pricePerGram;

                        Map<String, dynamic> updatedProduct = {
                          'name': _nameController.text,
                          'type': _selectedType,
                          'karat': _selectedKarat,
                          'weight': weight,
                          'price': totalPrice,
                          'quantity': int.parse(_quantityController.text),
                          'sell_price': double.parse(_sellPriceController.text),
                        };

                        await DatabaseHelper().updateProduct(product['id'], updatedProduct);
                        Navigator.of(context).pop();
                        _loadProducts();
                      } catch (e) {
                        // Handle parsing error
                        print('Error: $e');
                      }
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double> _getPricePerGram(String type, String? karat, String currency) async {
    var metalPrices = await fetchGoldPrices(
      metal: type == 'Gold' ? 'XAU' : type == 'Silver' ? 'XAG' : type == 'Platinum' ? 'XPT' : 'XPD',
      weightUnit: 'gram',
      currency: currency,
      karat: karat,
    );

    if (metalPrices != null) {
      if (type == 'Gold' && karat != null) {
        return metalPrices['XAU']?[karat] ?? 0.0;
      } else {
        return metalPrices[type == 'Gold' ? 'XAU' : type == 'Silver' ? 'XAG' : type == 'Platinum' ? 'XPT' : 'XPD']?['default'] ?? 0.0;
      }
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchProducts('');
                  },
                ),
              ),
              onChanged: _searchProducts,
            ),
            SizedBox(height: 16),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        var product = _filteredProducts[index];
                        return Card(
                          color: theme.cardColor,
                          child: ListTile(
                            title: Text(product['name']),
                            subtitle: Text(
                              'Type: ${product['type']}, Karat: ${product['karat']}, Weight: ${product['weight']} grams, Price: ${product['price']}, Quantity: ${product['quantity']}, Sell Price: ${product['sell_price']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditProductDialog(context, product);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteProduct(product['id']);
                                    _loadProducts();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}