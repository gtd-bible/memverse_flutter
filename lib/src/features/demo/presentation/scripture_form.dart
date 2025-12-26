import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/demo/data/demo_providers.dart'; // Changed import
import 'package:memverse_flutter/src/features/demo/data/demo_repository.dart';

class ScriptureForm extends ConsumerStatefulWidget {
  const ScriptureForm({super.key});

  @override
  ConsumerState<ScriptureForm> createState() => _ScriptureFormState();
}

class _ScriptureFormState extends ConsumerState<ScriptureForm> {
  final _formKey = GlobalKey<FormState>();
  final referenceController = TextEditingController();
  late TextEditingController collectionController;
  String display = "";

  @override
  void initState() {
    super.initState();
    display = "Running";
  }

  @override
  void dispose() {
    referenceController.dispose();
    collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    collectionController =
        TextEditingController(text: ref.watch(currentListProvider));

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
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
                  final repo = ref.read(demoRepositoryProvider);
                  final references = referenceController.text.split(',');

                  try {
                    for (var refStr in references) {
                      await repo.addScripture(
                          refStr.trim(), collectionController.text);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Added ${referenceController.text}")),
                      );
                      Navigator.of(context).pop();
                      // Force refresh of the list
                      ref.invalidate(scriptureListProvider);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
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
