import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../config/constants.dart';

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
    CategoryItem(name: 'Diapers & Wipes', key: 'diapers', icon: Icons.baby_changing_station, color: AppConstants.primaryColor),
    CategoryItem(name: 'Baby Clothing', key: 'clothing', icon: Icons.child_care, color: AppConstants.warmAccent),
    CategoryItem(name: 'Toys & Games', key: 'toys', icon: Icons.toys, color: AppConstants.accentColor),
    CategoryItem(name: 'Feeding', key: 'feeding', icon: Icons.restaurant, color: AppConstants.secondaryColor),
    CategoryItem(name: 'Baby Care', key: 'care', icon: Icons.spa, color: AppConstants.highlightColor),
    CategoryItem(name: 'Nursery', key: 'nursery', icon: Icons.bed, color: AppConstants.darkGreen),
    CategoryItem(name: 'Safety', key: 'safety', icon: Icons.security, color: AppConstants.errorColor),
    CategoryItem(name: 'Health', key: 'health', icon: Icons.health_and_safety, color: AppConstants.successColor),
    CategoryItem(name: 'Travel & Gear', key: 'travel', icon: Icons.luggage, color: AppConstants.textSecondary),
    CategoryItem(name: 'Books', key: 'books', icon: Icons.menu_book, color: AppConstants.primaryColor),
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
        SnackBar(
          content: const Text('Please select at least one category'),
          backgroundColor: AppConstants.accentColor,
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
            backgroundColor: AppConstants.errorColor,
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
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Choose Your Interests',
          style: AppConstants.headingMedium.copyWith(
            fontSize: 20,
            color: AppConstants.textPrimary,
          ),
        ),
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Image.network(
              'https://res.cloudinary.com/dpcgk2sev/image/upload/v1755112706/Image_fx_the_one_19_cgyeu0.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Icon(
                    Icons.baby_changing_station,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            color: AppConstants.cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you shopping for?',
                  style: AppConstants.headingLarge.copyWith(
                    fontSize: 26,
                  ),
                ),
                SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Select categories that interest you. We\'ll show you these products first.',
                  style: AppConstants.bodyLarge.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
                SizedBox(height: AppConstants.spacingMedium),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    border: Border.all(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_selectedCategories.length} selected',
                    style: AppConstants.bodyMedium.copyWith(
                      color: AppConstants.primaryColor,
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
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacingMedium,
                  mainAxisSpacing: AppConstants.spacingMedium,
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
                            : AppConstants.cardColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: isSelected ? category.color : AppConstants.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? category.color.withOpacity(0.2)
                                : AppConstants.shadowColor,
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
                              margin: EdgeInsets.only(bottom: AppConstants.spacingSmall),
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 28,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              category.name,
                              style: AppConstants.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? category.color
                                    : AppConstants.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            color: AppConstants.cardColor,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInterests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppConstants.borderColor,
                  shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                ).copyWith(
                  elevation: MaterialStateProperty.all(_isLoading ? 0 : 4),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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