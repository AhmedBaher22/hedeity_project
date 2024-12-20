import 'package:flutter/material.dart';

import '../controllers/UserController.dart';
import '../layouts/navbar.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _friendController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<UserModel>> _friendsFuture;
  late List<UserModel> _allFriends; // To hold the complete list of friends
  late List<UserModel> _filteredFriends; // To hold the filtered list
  final UserController _userController = UserController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _friendsFuture = _userController.fetchFriends();
    _friendsFuture.then((friends) {
      _allFriends = friends;
      _filteredFriends = friends;
    });
  }

  Future<void> _addNewFriend() async {
    final phoneNumber = _friendController.text;
    if (phoneNumber.isNotEmpty) {
      String addFriend = await _userController.addFriend(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addFriend)),
      );
      setState(() {
        _friendsFuture = _userController.fetchFriends();
        _friendsFuture.then((friends) {
          _allFriends = friends;
          _filteredFriends = friends;
        });
        _friendController.text = "";
      });
    }
  }

  void _filterFriends(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends
            .where((friend) =>
            friend.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2196F3), // Bright blue at top
                  Color(0xFF2196F3), // Lighter blue at bottom
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hedieaty',
                      style: TextStyle(
                        fontFamily: 'kitten',
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
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
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2196F3), // Bright blue at top
                        Color(0xFF64B5F6), // Lighter blue at bottom
                      ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Friend Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _friendController,
                                  decoration: InputDecoration(
                                    hintText: "Add Friend by Phone Number",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Aclonica',
                                      color: Colors.grey[400],
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color: secondaryBlue),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide:
                                      BorderSide(color: primaryBlue, width: 2),
                                    ),
                                    prefixIcon:
                                    Icon(Icons.person_add, color: primaryBlue),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryBlue, accentBlue],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  onPressed: _addNewFriend,
                                  icon: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Special Moments Section
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, accentBlue],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Image.asset(
                                    'assets/images/gift_box.png',
                                    height: 120,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Create Memorable\nMoments!",
                                      style: TextStyle(
                                        fontFamily: 'Aclonica',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/create_event');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: primaryBlue,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Create Event",
                                        style: TextStyle(
                                          fontFamily: 'Aclonica',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Search Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterFriends,
                          decoration: InputDecoration(
                            hintText: "Search Friends",
                            hintStyle: TextStyle(
                              fontFamily: 'Aclonica',
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: primaryBlue),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Friends List
                      FutureBuilder<List<UserModel>>(
                        future: _friendsFuture,
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
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 48, color: primaryBlue),
                                  SizedBox(height: 16),
                                  Text(
                                    'No friends yet.\nStart adding some!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 16,
                                      fontFamily: 'Aclonica',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _filteredFriends.length,
                              itemBuilder: (context, index) {
                                return _buildFriendCard(
                                    context, _filteredFriends[index]);
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 2),
    );
  }

  // Modified friend card with blue theme
  Widget _buildFriendCard(BuildContext context, UserModel friend) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: lightBlue,
          child: Text(
            friend.name[0],
            style: TextStyle(
              fontFamily: 'Aclonica',
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontFamily: 'Aclonica',
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: FutureBuilder<int>(
          future: _userController.fetchUserUpcomingEventsLength(friend.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error, color: Colors.red);
            } else {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: snapshot.data! > 0 ? primaryBlue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${snapshot.data}',
                  style: TextStyle(
                    fontFamily: 'Aclonica',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/friend', arguments: friend);
        },
      ),
    );
  }
}
