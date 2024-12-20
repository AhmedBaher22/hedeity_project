import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/friends_gift_card.dart';
import '../layouts/gift_card.dart';
import '../layouts/navbar.dart';
import '../models/gift.dart';

class GiftsScreen extends StatefulWidget {
  @override
  _GiftsScreenState createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  final GiftController _controller = GiftController();
  List<Gift> _gifts = [];
  String? _selectedSortOption;
  int eventId = -1;
  String fireBaseId = "";
  String eventName = "";
  bool _isInitialized = false;

  // Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final args = ModalRoute
        .of(context)
        ?.settings
        .arguments;
    if (args is Map) {
      setState(() {
        if (args['firebaseId'] != null) {
          fireBaseId = args['firebaseId'] as String;
        }
        if (args['eventId'] != null && args['eventName'] != null) {
          eventId = args['eventId'] as int;
          eventName = args["eventName"] as String;
        }
      });
    }
    _loadGifts();
    _isInitialized = true;
  }

  Future<void> _loadGifts() async {
    List<Gift> gifts;
    try {
      if (fireBaseId.isNotEmpty) {
        gifts = await _controller.fetchGiftsForEvent(fireBaseId);
      } else if (eventId == -1) {
        gifts = await _controller.getAllGifts();
      } else {
        gifts = await _controller.getGiftsByEventId(eventId);
      }
      setState(() {
        _gifts = gifts;
      });
    } catch (e) {
      print('Error loading gifts: $e');
      setState(() {
        _gifts = [];
      });
    }
  }

  void _sortGifts(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      switch (sortOption) {
        case "Sort by Name":
          _gifts.sort((a, b) => a.title.compareTo(b.title));
          break;
        case "Sort by Category":
          _gifts.sort((a, b) => a.category.compareTo(b.category));
          break;
        case "Sort by Price":
          _gifts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case "Sort by Event":
          _gifts.sort((a, b) => a.eventId.compareTo(b.eventId));
          break;
        case "Sort by Status":
          _gifts.sort((a, b) =>
          a.isPledged ? 1 : 0.compareTo(b.isPledged ? 1 : 0));
          break;
      }
    });
  }

  void _addGift() async {
    Navigator.pushNamed(context, '/create_gift');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Wrap entire Scaffold body in a Container with gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryBlue,
              secondaryBlue.withOpacity(0.7),
              Colors.white,
            ],
            stops: [
              0.0,
              0.3,
              0.5
            ], // Adjust these values to control gradient spread
          ),
        ),
        child: Column(
          children: [
            // Header Section
            SafeArea(
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
                            fontFamily: 'Kitten',
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
                    SizedBox(height: 20),
                    // Page Title and Add Button
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          Flexible(
                            child: Text(
                              eventId == -1
                                  ? "All Gifts"
                                  : "Gifts for $eventName",
                              style: TextStyle(
                                fontFamily: 'Aclonica',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryBlue, accentBlue],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              onPressed: _addGift,
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

            // Main Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Sort Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: secondaryBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: primaryBlue, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          prefixIcon: Icon(Icons.sort, color: primaryBlue),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          "Sort by Name",
                          "Sort by Category",
                          "Sort by Price",
                          "Sort by Event",
                          "Sort by Status"
                        ].map((String value) {
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
                          if (value != null) _sortGifts(value);
                        },
                        value: _selectedSortOption,
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

                    // Gifts List
                    Expanded(
                      child: _gifts.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 64,
                              color: secondaryBlue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No gifts available.\nStart adding some!',
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
                        itemCount: _gifts.length,
                        itemBuilder: (context, index) {
                          final gift = _gifts[index];
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
                            child: fireBaseId.isNotEmpty
                                ? FriendGiftCard(
                              gift: gift,
                              eventTitle: eventName,
                              eventId: fireBaseId,
                            )
                                : GiftCard(gift: gift),
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
      bottomNavigationBar: CustomNavBar(selectedIndex: 0),
    );
  }
}