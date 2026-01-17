import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/features/ref_quiz/widgets/verse_card.dart';
import 'package:mini_memverse/src/features/ref_quiz/widgets/verse_reference_form.dart';
import 'package:mini_memverse/src/features/verse/domain/verse.dart';

// TODO: Implement proper localization (l10n) using flutter_localizations
// Reference: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization

class QuestionSection extends HookConsumerWidget {
  const QuestionSection({
    required this.versesAsync,
    required this.currentVerseIndex,
    required this.answerController,
    required this.answerFocusNode,
    required this.hasSubmittedAnswer,
    required this.isAnswerCorrect,
    required this.onSubmitAnswer,
    super.key,
  });

  final AsyncValue<List<Verse>> versesAsync;
  final int currentVerseIndex;
  final TextEditingController answerController;
  final FocusNode answerFocusNode;
  final bool hasSubmittedAnswer;
  final bool isAnswerCorrect;
  final void Function(String) onSubmitAnswer;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 50,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: versesAsync.when(
            data: (verses) => VerseCard(verse: verses[currentVerseIndex]),
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stackTrace) => Center(
              child: Text(
                'Error loading verses: $error',
                style: const TextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      versesAsync.maybeWhen(
        data: (verses) => VerseReferenceForm(
          expectedReference: verses[currentVerseIndex].reference,
          answerController: answerController,
          answerFocusNode: answerFocusNode,
          hasSubmittedAnswer: hasSubmittedAnswer,
          isAnswerCorrect: isAnswerCorrect,
          onSubmitAnswer: onSubmitAnswer,
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    ],
  );
}
