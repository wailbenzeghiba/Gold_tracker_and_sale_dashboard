import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gold_tracking_desktop_stock_app/Database/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:gold_tracking_desktop_stock_app/pages/borrower_list_page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('Pick Identity Card Image (optional)'),
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
