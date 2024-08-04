import 'package:flutter/material.dart';

class MusicSeries extends StatefulWidget {
  const MusicSeries({super.key});

  @override
  State<MusicSeries> createState() => _MusicSeriesState();
}

class _MusicSeriesState extends State<MusicSeries> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            width:120,
            height:120,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }
}
