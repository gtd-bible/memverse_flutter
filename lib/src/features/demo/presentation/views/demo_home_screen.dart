import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:isar/isar.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'package:memverse_flutter/src/services/database.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/future_item_tile.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/scripture_form.dart';

var log = Logger();

class DemoHomeScreen extends ConsumerStatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  ConsumerState<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends ConsumerState<DemoHomeScreen> {
  Future<List<Scripture>>? scriptureList;

  Isar get isar => ref.read(databaseProvider).isar;
  Database get database => ref.read(databaseProvider);

  @override
  void initState() {
    super.initState();
    // Initialize list after first frame to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initScriptureList();
    });
  }

  void initScriptureList() {
    // Initialize DB and default list
    database.init().then((_) async {
       final String currentList = ref.read(currentListProvider);
       // Check if default list exists or needs populating
       int count = await database.getScriptureCount();
       if (count == 0) {
         // Default verses
         await ref.read(getResultProvider.call('Col 1:17, Matt 6:33, Phil 4:13', 'My List').future);
       }
       
       switchCollections(currentList);
    });
  }

  Future<List<Scripture>> getScriptureList(String listName) async {
    return await isar.scriptures.filter()
        .listNameMatches(listName)
        .findAll();
  }

  void refreshScriptureList() {
    scriptureList = getScriptureList(ref.watch(currentListProvider));
    setState(() {});
  }

  Future<List<String>> getCollections() async {
    return await isar.scriptures.where()
        .distinctByListName()
        .listNameProperty()
        .findAll();
  }

  void switchCollections(String newList) {
    scriptureList = getScriptureList(newList);
    ref.read(currentListProvider.notifier).setCurrentList(newList);
    setState(() {});
  }

  Future<void> renameList(String newName) async {
    String oldName = ref.read(currentListProvider);
    await database.renameList(oldName, newName);
    ref.read(currentListProvider.notifier).setCurrentList(newName);
    refreshScriptureList();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController newNameController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scripture App (Demo)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Main',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushCollectionsScreen,
            tooltip: 'Your Collections',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Text(
                      ref.watch(currentListProvider),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 30,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Navigator.pop(
                                            context, newNameController.text.trim());
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ));
                        if (newName != null && newName.isNotEmpty) {
                          await renameList(newName);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: scriptureWidget()),
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
                      });
                   refreshScriptureList();
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

  Future<void> _pullRefresh() async {
    refreshScriptureList();
  }

  Future<void> _pushCollectionsScreen() async {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      return collectionWidget();
    }));
  }

  Widget collectionWidget() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      body: FutureBuilder<List<String>>(
        future: getCollections(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                    enabled: (snapshot.data![index] !=
                        ref.watch(currentListProvider)),
                    onTap: () async {
                      switchCollections(snapshot.data![index]);
                      Navigator.of(context).pop();
                    },
                  );
                });
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget scriptureWidget() {
    return FutureBuilder<List<Scripture>>(
      future: scriptureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error loading verses: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Text("No verses in this list.");
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Slidable(
                  key: Key(snapshot.data![index].reference),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await isar.writeTxn(() async {
                            await isar.scriptures.delete(
                                snapshot.data![index].scriptureId);
                          });
                          refreshScriptureList();
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: FutureItemTile(data: snapshot.data![index]),
                );
              });
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
