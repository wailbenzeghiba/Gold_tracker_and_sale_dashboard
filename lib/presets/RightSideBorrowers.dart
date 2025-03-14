import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:gold_tracking_desktop_stock_app/pages/borrower_list_page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RightSideBorrowers extends StatefulWidget {
  const RightSideBorrowers({super.key});

  @override
  _RightSideBorrowersState createState() => _RightSideBorrowersState();
}

class _RightSideBorrowersState extends State<RightSideBorrowers> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _borrowedMoneyController = TextEditingController();
  final _dueTimeController = TextEditingController();
  String _selectedType = 'Give';
  File? _identityCardImage;

  final List<String> _types = ['Give', 'Take'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _identityCardImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            // Title Bar Section
            Container(
              color: Theme.of(context).cardColor, // ✅ Match card color
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 35, // ✅ Match other title bars
              child: Row(
                children: [
                  Expanded(child: MoveWindow()), // ✅ Make it draggable
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.list, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BorrowerListPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () {
                          setState(() {});
                        },
                      ),
                      const Windowbuttons(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Borrowers',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.list),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BorrowerListPage(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Name Input
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Borrowed Money Input
                      TextFormField(
                        controller: _borrowedMoneyController,
                        decoration: const InputDecoration(labelText: 'Borrowed Money'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the borrowed money';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: _types.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due Time Input
                      TextFormField(
                        controller: _dueTimeController,
                        decoration: const InputDecoration(labelText: 'Due Time (optional)'),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dueTimeController.text = pickedDate.toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pick Image Button
                      Row(
                        children: [
                          
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.image_outlined),
                            label: Text('Pick Identity Card Image' , style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),),
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.white70,
                              foregroundColor: const Color.fromARGB(255, 237, 237, 237), 
                              backgroundColor: Theme.of(context).primaryColor, 
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          _identityCardImage != null
                              ? Image.file(
                                  _identityCardImage!,
                                  width: 100,
                                  height: 100,
                                )
                              : Container(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Add Borrower Button
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic> borrower = {
                              'full_name': _fullNameController.text,
                              'borrowed_money': double.parse(_borrowedMoneyController.text),
                              'type': _selectedType,
                              'due_time': _dueTimeController.text.isNotEmpty
                                  ? _dueTimeController.text
                                  : null,
                              'identity_card_image': _identityCardImage != null
                                  ? _identityCardImage!.path
                                  : null,
                            };

                            await DatabaseHelper().insertBorrower(borrower);
                            setState(() {});
                          }
                        },
                        child: const Text('Add Borrower'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightSideDashboard extends StatefulWidget {
  const RightSideDashboard({super.key});

  @override
  _RightSideDashboardState createState() => _RightSideDashboardState();
}

class _RightSideDashboardState extends State<RightSideDashboard> {
  int _totalProducts = 0;
  double _totalGoldWeight = 0.0;
  double _totalSilverWeight = 0.0;
  double _totalValue = 0.0;
  double _netProfit = 0.0;
  double _monthlyNetProfit = 0.0;
  double _yearlyNetProfit = 0.0;

  Map<String, dynamic>? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final products = await DatabaseHelper().getProducts();
    final profit = await DatabaseHelper().getProfit();

    setState(() {
      _totalProducts = products.length;
      _totalGoldWeight = products.fold(0.0, (sum, product) {
        if (product['type'] == 'Gold') {
          return sum + (product['weight'] * product['quantity']);
        }
        return sum;
      });

      _totalSilverWeight = products.fold(0.0, (sum, product) {
        if (product['type'] == 'Silver') {
          return sum + (product['weight'] * product['quantity']);
        }
        return sum;
      });

      _totalValue = products.fold(0.0, (sum, product) => sum + product['price'] * product['quantity']);
      _netProfit = profit['net_profit'];
      _monthlyNetProfit = profit['monthly_net_profit'];
      _yearlyNetProfit = profit['yearly_net_profit'];
    });
  }

  void _showProductSoldDialog(BuildContext context) {
    final _quantityController = TextEditingController(text: '1');
    final _sellerNameController = TextEditingController();
    final _clientNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Sold'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No products available');
                    } else {
                      return DropdownButtonFormField<Map<String, dynamic>>(
                        items: snapshot.data!.map((product) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: product,
                            child: Text(product['name']),
                          );
                        }).toList(),
                        onChanged: (Map<String, dynamic>? selectedProduct) {
                          setState(() {
                            _selectedProduct = selectedProduct;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Select Product'),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity Sold'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sellerNameController,
                  decoration: const InputDecoration(labelText: 'Seller Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(labelText: 'Client Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedProduct != null) {
                  int quantitySold = int.parse(_quantityController.text);
                  double sellPrice = _selectedProduct!['sell_price'];
                  double basePrice = _selectedProduct!['base_price'];
                  double profit = (sellPrice - basePrice) * quantitySold;

                  int newQuantity = _selectedProduct!['quantity'] - quantitySold;

                  await DatabaseHelper().updateProductQuantity(
                    _selectedProduct!['id'],
                    newQuantity,
                  );

                  if (newQuantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'The quantity for ${_selectedProduct!['name']} is now 0 and the product has been deleted.',
                        ),
                      ),
                    );
                  }

                  setState(() {
                    _netProfit += profit;
                    _monthlyNetProfit += profit;
                    _yearlyNetProfit += profit;
                    _loadDashboardData(); // Reload data after update
                  });

                  await DatabaseHelper().updateProfit(_netProfit, _monthlyNetProfit, _yearlyNetProfit);

                  // Generate and print the receipt
                  await _generateAndPrintReceipt(
                    productName: _selectedProduct!['name'],
                    quantitySold: quantitySold,
                    sellPrice: sellPrice,
                    totalPrice: sellPrice * quantitySold,
                    sellerName: _sellerNameController.text,
                    clientName: _clientNameController.text,
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndPrintReceipt({
    required String productName,
    required int quantitySold,
    required double sellPrice,
    required double totalPrice,
    required String sellerName,
    required String clientName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Product Name: $productName', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Quantity Sold: $quantitySold', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Sell Price: ${sellPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Total Price: ${totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 16),
              pw.Text('Seller Name: $sellerName', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Client Name: $clientName', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 16),
              pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white38,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_money),
                    onPressed: () {
                      _showProductSoldDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dashboard Data Cards
              _buildDashboardCard('Total Products', _totalProducts.toString()),
              const SizedBox(height: 16),
              _buildDashboardCard('Total Gold Weight (grams)', _totalGoldWeight.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildDashboardCard('Total Silver Weight (grams)', _totalSilverWeight.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildDashboardCard('Total Value', _totalValue.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildDashboardCard('Net Profit', _netProfit.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildDashboardCard('Monthly Net Profit', _monthlyNetProfit.toStringAsFixed(2)),
              const SizedBox(height: 16),
              _buildDashboardCard('Yearly Net Profit', _yearlyNetProfit.toStringAsFixed(2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value) {
    return Card(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
