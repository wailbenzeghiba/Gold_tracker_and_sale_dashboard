import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';

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
