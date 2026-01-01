import 'package:flutter/material.dart';
// TODO: Add l10n import when localization is implemented/arb/app_localizations.dart';

class QuestionHistoryWidget extends StatelessWidget {
  const QuestionHistoryWidget({required this.pastQuestions, required this.l10n, super.key});

  final List<String> pastQuestions;
  final AppLocalizations l10n;

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
        Text(
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('past-questions'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pastQuestions.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
