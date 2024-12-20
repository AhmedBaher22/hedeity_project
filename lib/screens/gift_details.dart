import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';
import '../models/gift.dart';

class GiftDetailsScreen extends StatefulWidget {
  GiftDetailsScreen({super.key});

  @override
  _GiftDetailsScreenState createState() => _GiftDetailsScreenState();
}

class _GiftDetailsScreenState extends State<GiftDetailsScreen> {
  late Gift gift;
  final GiftController _giftController = GiftController();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  bool _isEditingTitle = false;
  bool _isEditingCategory = false;
  bool _isEditingPrice = false;
  bool _isEditingDescription = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Gift?;
    if (args != null) {
      gift = args;
      _titleController = TextEditingController(text: gift.title);
      _categoryController = TextEditingController(text: gift.category);
      _priceController = TextEditingController(text: gift.price);
      _descriptionController = TextEditingController(text: gift.description ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEditTitle() {
    setState(() {
      _isEditingTitle = !_isEditingTitle;
    });
  }

  void _toggleEditCategory() {
    setState(() {
      _isEditingCategory = !_isEditingCategory;
    });
  }

  void _toggleEditPrice() {
    setState(() {
      _isEditingPrice = !_isEditingPrice;
    });
  }

  void _toggleEditDescription() {
    setState(() {
      _isEditingDescription = !_isEditingDescription;
    });
  }

  void _saveChanges() async {
    Gift updatedGift = Gift(
      id: gift.id,
      title: _titleController.text,
      category: _categoryController.text,
      price: _priceController.text,
      description: _descriptionController.text,
      isPledged: gift.isPledged,
      eventId: gift.eventId
    );
    await _giftController.updateGift(updatedGift);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift details updated successfully!')),
    );
    setState(() {
      gift = updatedGift;
    });
    Navigator.pushNamed(context, '/gifts');
  }

  void _deleteGift() async {
    if(gift.isPledged){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pledged Gifts can\'t be deleted')),
      );
      return;
    }
    await _giftController.deleteGift(gift.id!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift deleted successfully!')),
    );
    Navigator.pushNamed(context, '/gifts');
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
                      'Gift Details',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gift Status Banner
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: gift.isPledged
                              ? Colors.green.withOpacity(0.1)
                              : primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: gift.isPledged ? Colors.green : primaryBlue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              gift.isPledged ? "Pledged" : "Available",
                              style: TextStyle(
                                color: gift.isPledged ? Colors.green : primaryBlue,
                                fontFamily: 'Aclonica',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Gift Icon
                      Center(
                        child: Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: lightBlue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.card_giftcard,
                            size: 80,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Gift Details Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: lightBlue.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailSection(
                              'Name',
                              _titleController,
                              _isEditingTitle,
                              _toggleEditTitle,
                              gift.isPledged,
                            ),
                            Divider(height: 30),
                            _buildDetailSection(
                              'Description',
                              _descriptionController,
                              _isEditingDescription,
                              _toggleEditDescription,
                              gift.isPledged,
                            ),
                            Divider(height: 30),
                            _buildDetailSection(
                              'Price',
                              _priceController,
                              _isEditingPrice,
                              _toggleEditPrice,
                              gift.isPledged,
                            ),
                            Divider(height: 30),
                            _buildDetailSection(
                              'Category',
                              _categoryController,
                              _isEditingCategory,
                              _toggleEditCategory,
                              gift.isPledged,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: gift.isPledged ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Aclonica',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: gift.isPledged ? null : _deleteGift,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Aclonica',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDetailSection(
      String title,
      TextEditingController controller,
      bool isEditing,
      VoidCallback onToggle,
      bool isPledged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Aclonica',
                fontSize: 16,
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isPledged)
              IconButton(
                icon: Icon(
                  isEditing ? Icons.close : Icons.edit,
                  color: isEditing ? Colors.red : primaryBlue,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
          ],
        ),
        SizedBox(height: 8),
        isEditing
            ? TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: lightBlue.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: primaryBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 16,
          ),
        )
            : Text(
          controller.text,
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
