import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BorrowerListPage extends StatefulWidget {
  @override
  _BorrowerListPageState createState() => _BorrowerListPageState();
}

class _BorrowerListPageState extends State<BorrowerListPage> {
  List<Map<String, dynamic>> _borrowers = [];
  List<Map<String, dynamic>> _filteredBorrowers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBorrowers();
  }

  Future<void> _loadBorrowers() async {
    _borrowers = await DatabaseHelper().getBorrowers();
    _filteredBorrowers = _borrowers;
    setState(() {});
  }

  void _searchBorrowers(String query) {
    final filtered = _borrowers.where((borrower) {
      final nameLower = borrower['full_name'].toLowerCase();
      final typeLower = borrower['type'].toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) || typeLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredBorrowers = filtered;
    });
  }

  void _showEditBorrowerDialog(BuildContext context, Map<String, dynamic> borrower) {
    final _formKey = GlobalKey<FormState>();
    final _fullNameController = TextEditingController(text: borrower['full_name']);
    final _borrowedMoneyController = TextEditingController(text: borrower['borrowed_money'].toString());
    final _dueTimeController = TextEditingController(text: borrower['due_time'] ?? '');
    String _selectedType = borrower['type'];
    File? _identityCardImage = borrower['identity_card_image'] != null ? File(borrower['identity_card_image']) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Borrower'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Borrowed Money
                  TextFormField(
                    controller: _borrowedMoneyController,
                    decoration: InputDecoration(
                      labelText: 'Borrowed Money',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Give', 'Take'].map((String type) {
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

                  // Due Time
                  TextFormField(
                    controller: _dueTimeController,
                    decoration: InputDecoration(
                      labelText: 'Due Time (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
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

                  // Image Picker
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _identityCardImage = File(pickedFile.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Pick ID Card (optional)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_identityCardImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _identityCardImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> updatedBorrower = {
                    'full_name': _fullNameController.text,
                    'borrowed_money': double.parse(_borrowedMoneyController.text),
                    'type': _selectedType,
                    'due_time': _dueTimeController.text.isNotEmpty ? _dueTimeController.text : null,
                    'identity_card_image': _identityCardImage != null ? _identityCardImage!.path : null,
                  };

                  await DatabaseHelper().updateBorrower(borrower['id'], updatedBorrower);
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Borrower List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBorrowers,
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
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchBorrowers('');
                  },
                ),
              ),
              onChanged: _searchBorrowers,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredBorrowers.isEmpty
                  ? const Center(child: Text('No borrowers found'))
                  : ListView.builder(
                      itemCount: _filteredBorrowers.length,
                      itemBuilder: (context, index) {
                        var borrower = _filteredBorrowers[index];
                        return Card(
                          color: theme.cardColor,
                          child: ListTile(
                            title: Text(borrower['full_name']),
                            subtitle: Text(
                              'Type: ${borrower['type']} | Due: ${borrower['due_time'] ?? 'N/A'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditBorrowerDialog(context, borrower);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteBorrower(borrower['id']);
                                    _loadBorrowers();
                                  },
                                ),
                              ],
                            ),
                            leading: borrower['identity_card_image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(borrower['identity_card_image']),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
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