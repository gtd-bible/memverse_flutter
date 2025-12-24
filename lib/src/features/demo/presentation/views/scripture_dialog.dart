import 'package:flutter/material.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/burrable_verse_view.dart';
import 'package:share_plus/share_plus.dart';

class VerseDialog extends StatelessWidget {
  const VerseDialog({super.key, required this.scripture});

  final Scripture scripture;
  String get reference => scripture.reference;
  String get translation => scripture.translation;
  String get text => scripture.text;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Column(children: [
              Row(children: [
                  Expanded(
                    child: Padding(padding: const EdgeInsets.only(left: 10.0),
                      child: Text("$reference \n($translation)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),), // Corrected: \n to 

                    ),
                  ),
                  Container(alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Share.share("$text\n$reference ($translation)"), // Corrected: \n to 

                      icon: const Icon(Icons.share),
                      iconSize: 30,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
              BlurPage(text: text),
            ]
        )
      ],
    );
  }
}
