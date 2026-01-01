import 'package:flutter/material.dart';

class QuestionHistoryWidget extends StatelessWidget {
  const QuestionHistoryWidget({required this.pastQuestions, super.key});

  final List<String> pastQuestions;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          key: const Key('past-questions'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pastQuestions.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('No questions yet', style: TextStyle(color: Colors.grey)),
                    ),
                  ]
                : pastQuestions
                      .map(
                        (feedback) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: feedback.contains(' Correct!') ? Colors.green : Colors.orange,
                              fontWeight:
                                  pastQuestions.indexOf(feedback) == pastQuestions.length - 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
      ],
    ),
  );
}
