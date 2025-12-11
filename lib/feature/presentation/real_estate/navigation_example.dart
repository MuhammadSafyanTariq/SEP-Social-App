import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/real_estate/real_estate_list_screen.dart';

/// Example showing how to navigate to the Real Estate module
///
/// This file demonstrates different ways to integrate the real estate module
/// into your existing app navigation structure.

class RealEstateNavigationExample {
  /// Example 1: Navigate from a button
  static void navigateFromButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RealEstateListScreen()),
    );
  }

  /// Example 2: Add to a drawer menu
  static Widget drawerMenuItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.home_work, color: Colors.blue),
      title: const Text('Real Estate'),
      subtitle: const Text('Browse property listings'),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RealEstateListScreen()),
        );
      },
    );
  }

  /// Example 3: Add to grid menu (like in your home screen)
  static Widget gridMenuItem(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateFromButton(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_work, size: 32, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Real Estate',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Example 4: Add as a card in your home screen
  static Widget homeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateFromButton(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_work, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real Estate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Browse, list, and manage properties',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/// Example: Add to your drawer
/// 
/// In your Drawer widget:
/// ```dart
/// Drawer(
///   child: ListView(
///     children: [
///       // ... other items
///       RealEstateNavigationExample.drawerMenuItem(context),
///       // ... other items
///     ],
///   ),
/// )
/// ```

/// Example: Add to your home screen grid
/// 
/// In your GridView:
/// ```dart
/// GridView.count(
///   crossAxisCount: 2,
///   children: [
///     // ... other items
///     RealEstateNavigationExample.gridMenuItem(context),
///     // ... other items
///   ],
/// )
/// ```

/// Example: Add as a card in your home screen
/// 
/// In your Column or ListView:
/// ```dart
/// Column(
///   children: [
///     // ... other widgets
///     RealEstateNavigationExample.homeCard(context),
///     // ... other widgets
///   ],
/// )
/// ```

/// Example: Simple button
/// 
/// ```dart
/// ElevatedButton(
///   onPressed: () => RealEstateNavigationExample.navigateFromButton(context),
///   child: Text('Open Real Estate'),
/// )
/// ```
