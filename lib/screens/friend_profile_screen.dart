import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/event_card.dart';
import '../layouts/navbar.dart';
import '../models/event.dart';
import '../models/user.dart';

class FriendProfileScreen extends StatefulWidget {
  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final EventController _eventController = EventController();
  UserModel? _userModel;

  // Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserModel) {
      setState(() {
        _userModel = args;
      });
    }
  }

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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  // App Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
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
                  ),

                  // Profile Card
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryBlue, accentBlue],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              _userModel?.name[0].toUpperCase() ?? '',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Aclonica',
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Name
                        Text(
                          _userModel?.name ?? "Unknown User",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                            color: primaryBlue,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Phone Number
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone, color: primaryBlue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                _userModel?.phone ?? "N/A",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Aclonica',
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Events Section
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Events Header
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                      child: Row(
                        children: [
                          Icon(Icons.event, color: primaryBlue),
                          SizedBox(width: 10),
                          Text(
                            "Events",
                            style: TextStyle(
                              fontFamily: 'Aclonica',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Events List
                    Expanded(
                      child: FutureBuilder<List<Event>>(
                        future: _eventController.getEventsByUserIdFromFirebase(
                          _userModel!.uid,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<Color>(primaryBlue),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: primaryBlue,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error loading events',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontFamily: 'Aclonica',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    color: secondaryBlue,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No events available',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 16,
                                      fontFamily: 'Aclonica',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final event = snapshot.data![index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: EventCard(
                                  eventId: 0,
                                  title: event.title,
                                  category: event.category,
                                  date: event.date,
                                  icon: Icons.event,
                                  iconColor: primaryBlue,
                                  onDelete: () {},
                                  showActions: false,
                                  onUpdate: (updatedData) {},
                                  firebaseId: event.firebaseId,
                                ),
                              );
                            },
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
      bottomNavigationBar: CustomNavBar(selectedIndex: 4, highlightSelected: false),
    );
  }
}