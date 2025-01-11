import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<List<String>> onCategorySelected;

  const SearchBarWidget({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50, // Height for the search bar
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      // Handle search query change if needed
                      print('Search query: $value');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        // Filter Dropdown, which will open a dialog
        GestureDetector(
          onTap: () => _openCategoryFilterDialog(context),
          child: Icon(Icons.filter_list, color: Colors.black),
        ),
      ],
    );
  }

  // Function to show category selection dialog
  void _openCategoryFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoryFilterDialog(
          categories: categories,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }
}

class CategoryFilterDialog extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<List<String>> onCategorySelected;

  const CategoryFilterDialog({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _CategoryFilterDialogState createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Categories'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.categories.map((category) {
            return CheckboxListTile(
              title: Text(category),
              value: selectedCategories.contains(category),
              onChanged: (bool? isSelected) {
                setState(() {
                  if (isSelected ?? false) {
                    selectedCategories.add(category);
                  } else {
                    selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cancel the selection
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selectedCategories.clear(); // Reset selection
            });
          },
          child: Text('Reset'),
        ),
        TextButton(
          onPressed: () {
            widget.onCategorySelected(selectedCategories); // Apply selection
            Navigator.pop(context);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
