import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('task_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleConroller = TextEditingController();
  final TextEditingController _subtitleConroller = TextEditingController();

  List<Map<String, dynamic>> _taskList = [];

  final _fameBox = Hive.box('task_box');

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    final data = _fameBox.keys.map((key) {
      final item = _fameBox.get(key);
      return {"key": key, 'Task': item['Task'], 'do': item['do']};
    }).toList();

    setState(() {
      _taskList = data.reversed.toList();
      print(_taskList.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newTask) async {
    await _fameBox.add(newTask);
    _refreshList();
    print("amount data ${_fameBox.length}");
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _fameBox.put(itemkey, item);
    _refreshList();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _fameBox.delete(itemkey);
    _refreshList();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Item Has deleted")));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _taskList.firstWhere((element) => element['key'] == itemKey);
      _titleConroller.text = existingItem['Task'];
      _subtitleConroller.text = existingItem['do'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: ctx,
        builder: (_) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 15,
                right: 15,
                left: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleConroller,
                    decoration: InputDecoration(hintText: "Enter Task"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _subtitleConroller,
                    decoration: InputDecoration(hintText: "Do so"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null) {
                        _createItem({
                          "Task": _titleConroller.text,
                          "do": _subtitleConroller.text,
                        });
                      }

                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          "Task": _titleConroller.text.trim(),
                          "do": _subtitleConroller.text.trim(),
                        });
                      }

                      _titleConroller.text = "";
                      _subtitleConroller.text = "";

                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? "Create New" : 'Update'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              itemCount: _taskList.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (_, index) {
                final currentList = _taskList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(currentList['Task'].toString()),
                      subtitle: Text(
                        currentList['do'].toString(),
                        maxLines: 4,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showForm(context, currentList['key']),
                            icon: Icon(
                              Icons.edit,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteItem(currentList['key']),
                            icon: Icon(
                              Icons.delete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
