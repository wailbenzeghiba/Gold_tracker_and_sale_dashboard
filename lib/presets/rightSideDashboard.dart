import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
             _buildDashboardCard(Icons.inventory, 'Total Products', _totalProducts.toString()),
const SizedBox(height: 16),
_buildDashboardCard(Icons.currency_bitcoin, 'Total Gold Weight (grams)', _totalGoldWeight.toStringAsFixed(2)),
const SizedBox(height: 16),
_buildDashboardCard(Icons.monetization_on, 'Total Silver Weight (grams)', _totalSilverWeight.toStringAsFixed(2)),
const SizedBox(height: 16),
_buildDashboardCard(Icons.attach_money, 'Stock Total Price (DZD)', _totalValue.toStringAsFixed(2)),
const SizedBox(height: 16),
_buildDashboardCard(Icons.trending_up, 'Net Profit (DZD)', _netProfit.toStringAsFixed(2)),
const SizedBox(height: 16),
_buildDashboardCard(Icons.calendar_today, 'Monthly Net Profit (DZD)', _monthlyNetProfit.toStringAsFixed(2)),
const SizedBox(height: 16),
_buildDashboardCard(Icons.calendar_month, 'Yearly Net Profit (DZD)', _yearlyNetProfit.toStringAsFixed(2)),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, String value) {
  return Card(
    color: Colors.white, // Light modern color
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black54),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
