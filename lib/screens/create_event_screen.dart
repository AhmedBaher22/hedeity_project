import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/event_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';
import '../models/event.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  DateTime? _date;

  final EventController _controller = EventController();

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate() && _date != null) {
      _formKey.currentState!.save();

      // Create a new Event object with the provided data
      final newEvent = Event(
        title: _title,
        category: _category,
        date: _date!.toLocal().toString().split(' ')[0], // Format date as string
        userId: currentUser?.uid??""
      );

      // Save the event using the EventController
      await _controller.addEvent(newEvent);

      // Show a confirmation message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      // Navigate back to the previous screen
      Navigator.pushNamed(context, '/events');
    } else {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
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
                      'Create Event',
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
                        // Event Icon
                        Center(
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event,
                              size: 60,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Event Title Field
                        _buildTextField(
                          'Event Title',
                          Icons.title,
                              (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                              (value) => _title = value!,
                        ),
                        SizedBox(height: 20),

                        // Category Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: lightBlue.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: primaryBlue),
                              prefixIcon: Icon(Icons.category, color: primaryBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: primaryBlue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: secondaryBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: primaryBlue, width: 2),
                              ),
                            ),
                            items: ['Fun', 'Work', 'Love', 'General', 'Other']
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
                        SizedBox(height: 20),

                        // Date Picker
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: secondaryBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Event Date',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: primaryBlue),
                                  SizedBox(width: 10),
                                  Text(
                                    _date != null
                                        ? _date!.toLocal().toString().split(' ')[0]
                                        : 'No date selected',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: _pickDate,
                                    child: Text(
                                      'Select Date',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),

                        // Save Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveEvent,
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
                                  'Save Event',
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
      void Function(String?) onSaved,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryBlue),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: secondaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}