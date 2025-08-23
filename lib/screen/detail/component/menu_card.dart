import 'package:flutter/material.dart';
import '../../../data/model/restaurant_detail.dart';

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final bool isFood;

  const MenuCard({super.key, required this.item, required this.isFood});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isFood ? Icons.fastfood : Icons.local_drink,
              color: isFood ? Colors.orange : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
