import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventCard extends StatefulWidget {
  final int? eventId;
  final String title;
  final String category;
  final String date;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onDelete;
  final ValueChanged<Event> onUpdate;
  final bool showActions;
  final String? firebaseId; // Optional Firebase ID

  const EventCard({
    Key? key,
    required this.eventId,
    required this.title,
    required this.category,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.onDelete,
    required this.onUpdate,
    this.showActions = true,
    this.firebaseId, // Include the optional parameter
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isEditing = false;
  late String _title;
  late String _category;
  late String _date;

  late String _originalTitle;
  late String _originalCategory;
  late String _originalDate;

  late String _status; // Added to track status

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _category = widget.category;
    _date = widget.date;

    // Save original values for cancellation
    _originalTitle = widget.title;
    _originalCategory = widget.category;
    _originalDate = widget.date;

    _status = _calculateStatus(); // Calculate initial status
  }

  /// Method to calculate the status based on the date
  String _calculateStatus() {
    final today = DateTime.now();
    final eventDate = DateTime.tryParse(_date)?.toLocal() ?? DateTime.now();

    // Compare only the date parts
    if (eventDate.year == today.year &&
        eventDate.month == today.month &&
        eventDate.day == today.day) {
      return "Current";
    } else if (eventDate.isAfter(today)) {
      return "Upcoming";
    } else {
      return "Past";
    }
  }




  /// Build the dynamic border using the status color
  Border _buildBorder() {
    return Border.all(color: _getStatusColor(), width: 2);
  }


  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _date = pickedDate.toLocal().toString().split(' ')[0];
        _status = _calculateStatus(); // Recalculate status when date changes
      });
    }
  }
// Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  /// Method to get the color based on the status
  Color _getStatusColor() {
    switch (_status) {
      case "Current":
        return Colors.green;
      case "Upcoming":
        return primaryBlue;
      case "Past":
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!_isEditing) {
              Navigator.pushNamed(
                context,
                '/gifts',
                arguments: {
                  'eventId': widget.eventId,
                  'eventName': widget.title,
                  if (widget.firebaseId != null) 'firebaseId': widget.firebaseId,
                },
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(_isEditing ? 16.0 : 12.0),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isEditing
                      ? lightBlue.withOpacity(0.3)
                      : lightBlue.withOpacity(0.2),
                  blurRadius: _isEditing ? 12 : 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status indicator and icon
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: _getStatusColor(),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Title and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isEditing
                              ? TextFormField(
                            initialValue: _title,
                            onChanged: (value) => _title = value,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(color: primaryBlue),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryBlue),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'Aclonica',
                              fontSize: 18,
                            ),
                          )
                              : Text(
                            _title,
                            style: TextStyle(
                              fontFamily: 'Aclonica',
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _isEditing
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _category,
                                items: ['Fun', 'Work', 'Love', 'General']
                                    .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _category = value;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle: TextStyle(color: primaryBlue),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: secondaryBlue),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: primaryBlue),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _pickDate,
                                icon: Icon(Icons.calendar_today),
                                label: Text(_date.isNotEmpty
                                    ? 'Date: $_date'
                                    : 'Pick a Date'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.category, _category),
                              SizedBox(height: 4),
                              _buildInfoRow(Icons.calendar_today, _date),
                              SizedBox(height: 4),
                              _buildInfoRow(Icons.access_time, _status),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    if (widget.showActions)
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                                if (!_isEditing) {
                                  _title = _originalTitle;
                                  _category = _originalCategory;
                                  _date = _originalDate;
                                }
                              });
                            },
                            icon: Icon(
                              _isEditing ? Icons.cancel : Icons.edit,
                              color: _isEditing ? Colors.red : primaryBlue,
                            ),
                          ),
                          IconButton(
                            onPressed: widget.onDelete,
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedEvent = Event(
                          title: _title,
                          category: _category,
                          date: _date,
                          userId: currentUser?.uid ?? "",
                        );
                        widget.onUpdate(updatedEvent);
                        setState(() {
                          _isEditing = false;
                          _originalTitle = _title;
                          _originalCategory = _category;
                          _originalDate = _date;
                          _status = _calculateStatus();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Aclonica',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: secondaryBlue,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}