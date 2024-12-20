import 'package:flutter/material.dart';

import '../controllers/event_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/event_card.dart';
import '../layouts/navbar.dart';
import '../models/event.dart';


class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventController _controller = EventController();
  List<Event> _events = [];
  String? _currentSortOption; // Stores selected sorting option
  bool _isLoading = false; // Indicates if loading is in progress

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = await _controller.getAllEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  void _sortEvents(String? sortOption) async {
    if (sortOption == null) return;

    setState(() {
      _isLoading = true;
      _events.clear(); // Clear the current list
    });

    final events = await _controller.getAllEvents();

    if (sortOption == "Sort by Title") {
      events.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortOption == "Sort by Status") {
      events.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == "Sort by Category") {
      events.sort((a, b) => a.category.compareTo(b.category));
    }

    setState(() {
      _events = events; // Rebuild with sorted list
      _isLoading = false;
    });
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
            colors: [
              primaryBlue,
              secondaryBlue.withOpacity(0.7),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // App Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hedieaty',
                            style: TextStyle(
                              fontFamily: 'LobsterTwo',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Image.asset(
                            'assets/icons/Gift_title_Icon.png',
                            height: 32.0,
                            width: 32.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Events Title and Add Button
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event, color: primaryBlue, size: 30),
                                SizedBox(width: 10),
                                Text(
                                  "Events",
                                  style: TextStyle(
                                    fontFamily: 'Aclonica',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryBlue, accentBlue],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/create_event');
                                },
                                icon: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Sort Dropdown with new design
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: lightBlue.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _currentSortOption,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: secondaryBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: primaryBlue, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          prefixIcon: Icon(Icons.sort, color: primaryBlue),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ["Sort by Title", "Sort by Status", "Sort by Category"]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontFamily: 'Aclonica',
                                color: primaryBlue,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _currentSortOption = value;
                          });
                          _sortEvents(value);
                        },
                        hint: Text(
                          "Sort By",
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            color: secondaryBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Events List
                    Expanded(
                      child: _isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        ),
                      )
                          : _events.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: secondaryBlue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No events available.\nCreate your first event!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 16,
                                fontFamily: 'Aclonica',
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: lightBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: EventCard(
                              eventId: event.id,
                              title: event.title,
                              category: event.category,
                              date: event.date,
                              icon: Icons.event,
                              iconColor: primaryBlue,
                              onDelete: () async {
                                await _controller.deleteEvent(event.id!);
                                _loadEvents();
                              },
                              onUpdate: (updatedEvent) async {
                                final updatedWithId = Event(
                                  id: event.id,
                                  title: updatedEvent.title,
                                  category: updatedEvent.category,
                                  date: updatedEvent.date,
                                  userId: updatedEvent.userId,
                                );
                                await _controller.updateEvent(updatedWithId);
                                _loadEvents();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3),
    );
  }
}
