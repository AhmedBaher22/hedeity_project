import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/gift.dart';

class GiftCard extends StatefulWidget {
  final Gift gift;

  const GiftCard({
    required this.gift,
    Key? key,
  }) : super(key: key);

  @override
  _GiftCardState createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  final EventController _eventController = EventController();
  String _eventTitle = "";

  // Define color scheme
  final Color primaryBlue = Color(0xFF1E88E5);
  final Color secondaryBlue = Color(0xFF64B5F6);
  final Color accentBlue = Color(0xFF0D47A1);
  final Color lightBlue = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    _fetchEventTitle();
  }

  Future<void> _fetchEventTitle() async {
    final event = await _eventController.getEventById(widget.gift.eventId);
    if (event != null) {
      setState(() {
        _eventTitle = event.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/gift_details',
          arguments: widget.gift,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: secondaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Bar
            Container(
              decoration: BoxDecoration(
                color: widget.gift.isPledged
                    ? Colors.green.withOpacity(0.1)
                    : primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: widget.gift.isPledged ? Colors.green : primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.gift.isPledged ? "Pledged" : "Available",
                    style: TextStyle(
                      color: widget.gift.isPledged ? Colors.green : primaryBlue,
                      fontFamily: 'Aclonica',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gift Icon Container
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      'assets/icons/Gift.png',
                      height: 40.0,
                      width: 40.0,

                    ),
                  ),
                  SizedBox(width: 16),

                  // Gift Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.gift.title,
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Info Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.category,
                              widget.gift.category,
                            ),
                            _buildInfoChip(
                              Icons.attach_money,
                              "${widget.gift.price}",
                            ),
                            _buildInfoChip(
                              Icons.event,
                              _eventTitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: lightBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: accentBlue,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: accentBlue,
              fontSize: 14,
              fontFamily: 'Aclonica',
            ),
          ),
        ],
      ),
    );
  }
}