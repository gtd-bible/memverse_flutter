import 'package:flutter/material.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/scripture_dialog.dart';

class FutureItemTile extends StatefulWidget {
  final Scripture data;
  const FutureItemTile({super.key, required this.data});

  @override
  State<FutureItemTile> createState() => _FutureItemTileState();
}

class _FutureItemTileState extends State<FutureItemTile> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) => ListTile(
        selected: isSelected,
        onTap: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => VerseDialog(scripture: widget.data),
        ),
        title: Text(widget.data.reference),
      );
}
