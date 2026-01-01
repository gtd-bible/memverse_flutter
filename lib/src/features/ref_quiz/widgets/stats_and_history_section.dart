import 'package:flutter/material.dart';
import 'package:mini_memverse/src/features/ref_quiz/widgets/question_history_widget.dart';

class StatsAndHistorySection extends StatelessWidget {
  const StatsAndHistorySection({required this.pastQuestions, super.key});

  final List<String> pastQuestions;

  @override
  Widget build(BuildContext context) =>
      Column(children: <Widget>[QuestionHistoryWidget(pastQuestions: pastQuestions)]);
}
