import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.24,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1B1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: const Center(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            ListTile(
              leading: Icon(
                Icons.favorite_border,
                color: Color(0xFF27bc5c),
              ),
              title: Text(
                'Like',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: Color(0xFF27bc5c)),
              title: Text(
                'Add In Collection',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
