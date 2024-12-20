import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_controller.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';

class CreateGiftScreen extends StatefulWidget {
  @override
  _CreateGiftScreenState createState() => _CreateGiftScreenState();
}

class _CreateGiftScreenState extends State<CreateGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  String _price = '';
  String _description = '';
  int? _selectedEventId;

  final GiftController _giftController = GiftController();
  final EventController _eventController = EventController();

  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _eventController.getAllEvents();
    print(events);
    setState(() {
      _events = events;
    });
  }

  void _saveGift() async {
    if (_formKey.currentState!.validate() && _selectedEventId != null) {
      _formKey.currentState!.save();

      // Create a new Gift object
      final newGift = Gift(
        title: _title,
        category: _category,
        price: _price,
        description: _description,
        isPledged: false, // Set isPledged to false by default
        eventId: _selectedEventId!,
      );

      // Save the gift using the GiftController
      await _giftController.addGift(newGift);

      // Show a confirmation message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift created successfully!')),
      );

      // Navigate back to the previous screen
      Navigator.pushNamed(context, '/gifts');
    } else {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields and select an event')),
      );
    }
  }
  // Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryBlue, secondaryBlue.withOpacity(0.7), Colors.white],
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: Column(
          children: [
            // Custom Header
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Create Gift',
                      style: TextStyle(
                        fontFamily: 'Aclonica',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 40), // For balance
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gift Icon
                        Center(
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              size: 60,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Form Fields
                        _buildDropdownField(
                          'Select Event',
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.event, color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            items: _events.map((event) {
                              return DropdownMenuItem<int>(
                                value: event.id,
                                child: Text(event.title),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() {
                              _selectedEventId = value;
                            }),
                            validator: (value) {
                              if (value == null) return 'Please select an event';
                              return null;
                            },
                          ),
                        ),

                        _buildTextField(
                          'Gift Title',
                          Icons.title,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                              (value) => _title = value!,
                        ),

                        _buildDropdownField(
                          'Category',
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.category, color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            items: ['Electronics', 'Clothing', 'Books', 'General', 'Other']
                                .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                                .toList(),
                            onChanged: (value) => setState(() {
                              _category = value!;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                        ),

                        _buildTextField(
                          'Price',
                          Icons.attach_money,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            return null;
                          },
                              (value) => _price = value!,
                          keyboardType: TextInputType.number,
                        ),

                        _buildTextField(
                          'Description',
                          Icons.description,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                              (value) => _description = value!,
                          maxLines: 3,
                        ),

                        SizedBox(height: 30),

                        // Save Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveGift,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Save Gift',
                                  style: TextStyle(
                                    fontFamily: 'Aclonica',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3, highlightSelected: false),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      String? Function(String?) validator,
      void Function(String?) onSaved, {
        TextInputType? keyboardType,
        int? maxLines,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryBlue),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownField(String label, Widget dropdown) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          dropdown,
        ],
      ),
    );
  }
}