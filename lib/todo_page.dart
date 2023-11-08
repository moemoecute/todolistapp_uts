import 'package:flutter/material.dart';
import 'package:todolist_uts/database_helper.dart';
import 'package:todolist_uts/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
      theme: ThemeData(
        primarySwatch:
            Colors.green, // Ganti warna utama menggunakan primarySwatch
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    Key? key,
  });

  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList> {
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _deskripsiCtrl = TextEditingController();
  TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = [];
  List<Todo> completedTodoList = [];

  final dbHelper = DatabaseHelper();
  Todo? _selectedTodo;

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todoList = todos.where((todo) => !todo.done).toList();
      completedTodoList = todos.where((todo) => todo.done).toList();
    });
  }

  void addItem() async {
    await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    refreshList();

    _namaCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void updateItem(int index, bool done) async {
    todoList[index].done = done;
    await dbHelper.updateTodo(todoList[index]);

    if (done) {
      completedTodoList.add(todoList[index]);
      todoList.removeAt(index);
    }

    refreshList();
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty) {
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos.where((todo) => !todo.done).toList();
      completedTodoList = todos.where((todo) => todo.done).toList();
    });
  }

  void tampilForm({Todo? todo}) async {
    _selectedTodo = todo;
    _namaCtrl.text = todo?.nama ?? '';
    _deskripsiCtrl.text = todo?.deskripsi ?? '';

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text(
                  _selectedTodo == null ? "Tambah Catatan" : "Edit Catatan"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      if (_selectedTodo == null) {
                        addItem();
                      } else {
                        // Perbarui tugas yang ada
                        if (_selectedTodo != null) {
                          _selectedTodo!.nama = _namaCtrl.text;
                          _selectedTodo!.deskripsi = _deskripsiCtrl.text;
                          dbHelper.updateTodo(_selectedTodo!);
                        }
                        _selectedTodo = null;
                      }
                      refreshList();
                      Navigator.pop(context);
                    },
                    child: Text(_selectedTodo == null ? "Tambah" : "Simpan"))
              ],
              content: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _namaCtrl,
                      decoration: InputDecoration(hintText: 'Berikan Nama'),
                    ),
                    TextField(
                      controller: _deskripsiCtrl,
                      decoration:
                          InputDecoration(hintText: 'Kata-kata hari ini bang'),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Elite Global'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilForm();
        },
        child: Icon(Icons.add_box),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) {
                  cariTodo();
                },
                decoration: InputDecoration(
                  hintText: 'Ketik disini kalau ingin mencari sesuatu ygy',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todoList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: todoList[index].done
                          ? IconButton(
                              icon: const Icon(Icons.check_circle),
                              onPressed: () {
                                updateItem(index, false);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.radio_button_unchecked),
                              onPressed: () {
                                updateItem(index, true);
                              },
                            ),
                      title: Text(
                        todoList[index].nama,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        todoList[index].deskripsi,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              tampilForm(todo: todoList[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(todoList[index].id ?? 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Tugas Selesai',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: completedTodoList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.check_circle),
                        onPressed: () {
                          updateItem(index, false);
                        },
                      ),
                      title: Text(
                        completedTodoList[index].nama,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        completedTodoList[index].deskripsi,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              tampilForm(todo: completedTodoList[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(completedTodoList[index].id ?? 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(
              height: 65.0,
            ),
          ],
        ),
      ),
    );
  }
}
