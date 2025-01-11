import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/navigation_controller.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    final items = [
      Icons.home,
      Icons.newspaper_outlined,
      Icons.photo_library_outlined,
      Icons.person_outline,
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 20, // Adjust the position of the navigation bar
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final isSelected = provider.currentIndex == index;
                    return IconButton(
                      onPressed: () {
                        provider.setIndex(index);
                      },
                      icon: Icon(
                        items[index],
                        color: isSelected ? Colors.red : Colors.grey,
                        size: isSelected ? 28 : 24,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
