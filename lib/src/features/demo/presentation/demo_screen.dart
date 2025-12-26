import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/demo/data/demo_repository.dart'; // Added import
import 'package:memverse_flutter/src/features/demo/data/demo_providers.dart'; // Keep this import
import 'package:memverse_flutter/src/features/demo/domain/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/scripture_form.dart';
import 'package:memverse_flutter/src/features/demo/presentation/verse_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key, this.title = 'Demo Scripture App'});

  final String title;

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  // TODO: maybe use shared_preferences to store the last list opened whenever app is closed

  @override
  void initState() {
    super.initState();
    // Initialize some default scriptures for the demo
    final repo = ref.read(demoRepositoryProvider);
    if (repo.getScriptures('My List').isEmpty) {
      repo.addScripture("John 3:16", "My List");
      repo.addScripture("Romans 8:28", "My List");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Scripture>> scriptureListAsync =
        ref.watch(scriptureListProvider);
    final String currentList = ref.watch(currentListProvider);
    final TextEditingController newNameController =
        TextEditingController(text: currentList);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _pushCollectionsScreen(context),
            tooltip: 'Your Collections',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(scriptureListProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentList,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit collection name',
                      onPressed: () async {
                        String? newName = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Edit List Name?'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('New name:'),
                                      TextField(
                                        controller: newNameController,
                                      )
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context,
                                            newNameController.text.trim());
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ));
                        if (newName != null &&
                            newName.isNotEmpty &&
                            newName != currentList) {
                          ref
                              .read(demoRepositoryProvider)
                              .renameList(currentList, newName);
                          ref.read(currentListProvider.notifier).state =
                              newName;
                          ref.invalidate(scriptureListProvider);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: scriptureListAsync.when(
                  data: (scriptures) {
                    if (scriptures.isEmpty) {
                      return const Center(
                          child: Text("No scriptures yet. Add some!"));
                    }
                    return ListView.builder(
                      itemCount: scriptures.length,
                      itemBuilder: (context, index) {
                        final scripture = scriptures[index];
                        return Slidable(
                          key: ValueKey(scripture.id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await ref
                                      .read(demoRepositoryProvider)
                                      .deleteScripture(scripture);
                                  ref.invalidate(scriptureListProvider);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(scripture.reference),
                            onTap: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  VerseDialog(scripture: scripture),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.lightBlue,
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        title: Text("Add a Scripture"),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: ScriptureForm(),
                          )
                        ],
                      );
                    },
                  );
                },
                tooltip: 'Add a verse',
                child: const Icon(Icons.add),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pushCollectionsScreen(BuildContext context) async {
    final repo = ref.read(demoRepositoryProvider);
    final collections = repo.getCollections();

    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Collections'),
          ),
          body: ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collectionName = collections[index];
              return ListTile(
                title: Text(collectionName),
                enabled: (collectionName != ref.watch(currentListProvider)),
                onTap: () {
                  ref.read(currentListProvider.notifier).state = collectionName;
                  ref.invalidate(scriptureListProvider);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    ));
  }
}
