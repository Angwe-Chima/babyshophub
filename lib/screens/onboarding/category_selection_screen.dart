import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  final Map<String, String> _categoryMapping = {
    'diapers': 'Diapers & Wipes',
    'clothing': 'Baby Clothing',
    'toys': 'Toys & Games',
    'feeding': 'Feeding',
    'care': 'Baby Care',
    'nursery': 'Nursery',
    'safety': 'Safety',
    'health': 'Health',
    'travel': 'Travel & Gear',
    'books': 'Books',
  };

  final List<CategoryItem> _categories = [
    CategoryItem(name: 'Diapers & Wipes', key: 'diapers', icon: Icons.baby_changing_station, color: Colors.blue),
    CategoryItem(name: 'Baby Clothing', key: 'clothing', icon: Icons.child_care, color: Colors.pink),
    CategoryItem(name: 'Toys & Games', key: 'toys', icon: Icons.toys, color: Colors.orange),
    CategoryItem(name: 'Feeding', key: 'feeding', icon: Icons.restaurant, color: Colors.green),
    CategoryItem(name: 'Baby Care', key: 'care', icon: Icons.spa, color: Colors.purple),
    CategoryItem(name: 'Nursery', key: 'nursery', icon: Icons.bed, color: Colors.teal),
    CategoryItem(name: 'Safety', key: 'safety', icon: Icons.security, color: Colors.red),
    CategoryItem(name: 'Health', key: 'health', icon: Icons.health_and_safety, color: Colors.cyan),
    CategoryItem(name: 'Travel & Gear', key: 'travel', icon: Icons.luggage, color: Colors.brown),
    CategoryItem(name: 'Books', key: 'books', icon: Icons.menu_book, color: Colors.indigo),
  ];

  void _toggleCategory(String categoryKey) {
    setState(() {
      if (_selectedCategories.contains(categoryKey)) {
        _selectedCategories.remove(categoryKey);
      } else {
        _selectedCategories.add(categoryKey);
      }
    });
  }

  Future<void> _saveInterests() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final productCategories =
      _selectedCategories.map((key) => _categoryMapping[key] ?? key).toList();

      await userProvider.updateUserInterests(productCategories);
      // You can navigate here if needed, or let a wrapper handle it
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Choose Your Interests',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you shopping for?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select categories that interest you. We\'ll show you these products first.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_selectedCategories.length} selected',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategories.contains(category.key);

                  return GestureDetector(
                    onTap: () => _toggleCategory(category.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                          isSelected ? category.color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? category.color.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? category.color
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInterests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final String key;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.key,
    required this.icon,
    required this.color,
  });
}
