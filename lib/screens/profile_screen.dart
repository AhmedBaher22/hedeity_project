import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/UserController.dart';
import '../controllers/event_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/event_card.dart';
import '../layouts/navbar.dart';
import '../models/user.dart';
import '../models/event.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? currentUser;
  final EventController _eventController = EventController();
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  UserController userController = UserController();

  // Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Loading...");
    _phoneController = TextEditingController(text: "Loading...");
    _initialize();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    UserModel? new_currentUser = await userController.getCurrentUser();
    if (new_currentUser != null) {
      setState(() {
        currentUser = new_currentUser;
        _nameController.text = new_currentUser.name ?? "No Name";
        _phoneController.text = new_currentUser.phone ?? "No Phone";
      });
    } else {
      setState(() {
        _nameController.text = "No Name";
        _phoneController.text = "No Phone";
      });
    }
  }

  Future<void> _logout() async {
    if (await userController.logout()) {
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed')),
      );
    }
  }

  Future<void> _saveDisplayName() async {
    try {
      if (_nameController.text.isNotEmpty && currentUser != null) {
        await userController.setName(currentUser!.uid, _nameController.text);
        UserModel? updatedUser = await userController.getCurrentUser();
        setState(() {
          currentUser = updatedUser;
          _isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: $e')),
      );
    }
  }

  Future<void> _savePhoneNumber() async {
    if (_phoneController.text.isNotEmpty && currentUser != null) {
      if (await userController.setPhoneNumber(
          currentUser!.uid, _phoneController.text)) {
        setState(() {
          _isEditingPhone = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone number updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update phone number')),
        );
      }
    }
  }

  Future<void> _publishToFirebase() async {
    if (currentUser != null) {
      int result = await _eventController.publishEventsToFirebase(currentUser!.uid);
      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing events')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result} new events published.')),
        );
      }
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
            colors: [primaryBlue, secondaryBlue.withOpacity(0.7), Colors.white],
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Profile Info
              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // App Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PROFILE',
                            style: TextStyle(
                              fontFamily: 'Kitten',
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Image.asset(
                            'assets/icons/diamond.png',
                            height: 32.0,
                            width: 32.0,
                            // color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Profile Card
                      Container(
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
                            Stack(
                              alignment: Alignment.center,
                              children: [
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
                                      currentUser?.name != null &&
                                          currentUser!.name!.isNotEmpty
                                          ? currentUser!.name![0]
                                          : "?",
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Aclonica',
                                        color: primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Name Section
                            _isEditingName
                                ? Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter name',
                                        hintStyle: TextStyle(
                                            color: primaryBlue
                                                .withOpacity(0.5)),
                                      ),
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontFamily: 'Aclonica',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: _saveDisplayName,
                                  ),
                                  IconButton(
                                    icon:
                                    Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingName = false;
                                        _nameController.text =
                                            currentUser?.name ?? "No Name";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Aclonica',
                                    color: primaryBlue,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _isEditingName = true),
                                  icon: Icon(Icons.edit, color: primaryBlue),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Phone Section
                            _isEditingPhone
                                ? Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone, color: primaryBlue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter phone number',
                                        hintStyle: TextStyle(
                                            color: primaryBlue
                                                .withOpacity(0.5)),
                                      ),
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontFamily: 'Aclonica',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: _savePhoneNumber,
                                  ),
                                  IconButton(
                                    icon:
                                    Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingPhone = false;
                                        _phoneController.text =
                                            currentUser?.phone ?? "No Phone";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                                : Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, color: primaryBlue),
                                  SizedBox(width: 8),
                                  Text(
                                    _phoneController.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Aclonica',
                                      color: primaryBlue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(
                                            () => _isEditingPhone = true),
                                    icon:
                                    Icon(Icons.edit, color: primaryBlue),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Action Buttons
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton.icon(
                                        onPressed: _publishToFirebase,
                                        icon: Icon(Icons.cloud_upload,
                                            color: Colors.white, size: 20),
                                        label: Text(
                                          'Publish',
                                          style: TextStyle(
                                            fontFamily: 'Aclonica',
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryBlue,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton.icon(
                                        onPressed: _logout,
                                        icon: Icon(Icons.logout,
                                            color: Colors.white, size: 20),
                                        label: Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontFamily: 'Aclonica',
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade400,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
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
              ),

              // Events Section
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            "Recent Events",
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
                    SizedBox(height: 16),

                    // Events List
                    FutureBuilder<List<Event>>(
                      future: _eventController.getFirstEvents(3),
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
                              children: [
                                Icon(Icons.error_outline,
                                    color: primaryBlue, size: 48),
                                SizedBox(height: 16),
                                Text('Error: ${snapshot.error}'),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_busy,
                                    color: secondaryBlue, size: 48),
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

                        return Column(
                          children: [
                            ...snapshot.data!.map((event) => Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: EventCard(
                                eventId: event.id,
                                title: event.title,
                                category: event.category,
                                date: event.date,
                                icon: Icons.event,
                                iconColor: primaryBlue,
                                onDelete: () async {
                                  await _eventController
                                      .deleteEvent(event.id!);
                                  setState(() {});
                                },
                                onUpdate: (updatedData) {},
                              ),
                            )).toList(),
                            if (snapshot.data!.length > 2)
                              TextButton.icon(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/events'),
                                icon:
                                Icon(Icons.arrow_forward, color: primaryBlue),
                                label: Text(
                                  "View All Events",
                                  style: TextStyle(
                                    fontFamily: 'Aclonica',
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 4),
    );
  }
}