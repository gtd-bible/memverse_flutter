import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';

class ScriptureForm extends ConsumerStatefulWidget {
  const ScriptureForm({super.key});

  @override
  ScriptureFormState createState() => ScriptureFormState();
}

class ScriptureFormState extends ConsumerState<ScriptureForm> {
  final _formKey = GlobalKey<FormState>();
  final referenceController = TextEditingController();
  late TextEditingController collectionController;

  @override
  void initState() {
    super.initState();
    collectionController = TextEditingController();
  }

  @override
  void dispose() {
    referenceController.dispose();
    collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync with current list provider
    final currentList = ref.watch(currentListProvider);
    if (collectionController.text.isEmpty) {
       collectionController.text = currentList;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('scriptureToAdd'),
            controller: referenceController,
            decoration: const InputDecoration(
              labelText: "Enter comma-separated list of Scriptures",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            key: const Key('collectionName'),
            controller: collectionController,
            decoration: const InputDecoration(
              labelText: "Collection name",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ref.read(getResultProvider.call(referenceController.text, collectionController.text).future);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(display)),
                    );
                    context.pop(); // Close dialog/screen
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
