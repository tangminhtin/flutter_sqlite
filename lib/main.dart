import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sqlite/car.dart';
import 'package:flutter_sqlite/dbhelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  List<Car> cars = [];
  List<Car> carsByName = [];

  /// Controllers used in insert operation UI
  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();

  /// Controllers used in update operation UI
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController milesUpdateController = TextEditingController();

  /// Controllers used in delete operation UI
  TextEditingController idDeleteController = TextEditingController();

  /// Controllers used in query operation UI
  TextEditingController queryController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _insert(name, miles) async {
    /// Row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles,
    };

    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold('Inserted row id: $id.');
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cars.clear();
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    _showMessageInScaffold('Query done.');
    setState(() {});
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    carsByName.clear();
    allRows.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  void _update(id, name, miles) async {
    /// Row to update
    Car car = Car(id, name, miles);
    final rowsAffected = await dbHelper.update(car);
    _showMessageInScaffold('Updated $rowsAffected row(s)');
  }

  void _delete(id) async {
    /// Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(id);
    _showMessageInScaffold('Deleted $rowsDeleted row(s): row $id');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Flutter SQLite'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Insert'),
              Tab(text: 'View'),
              Tab(text: 'Query'),
              Tab(text: 'Update'),
              Tab(text: 'Delete'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                children: [
                  /// Insert
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: milesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Miles',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String name = nameController.text;
                      int miles = int.parse(milesController.text);
                      _insert(name, miles);
                    },
                    child: const Text('Insert Car Details'),
                  ),
                ],
              ),
            ),

            /// View
            Container(
              child: ListView.builder(
                itemCount: cars.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cars.length) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _queryAll();
                        });
                      },
                      child: const Text('Refresh'),
                    );
                  }
                  return SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        '[${cars[index].id}] ${cars[index].name} - ${cars[index].miles}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Query
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: queryController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Name',
                      ),
                      onChanged: (text) {
                        if (text.length >= 2) {
                          setState(() {
                            _query(text);
                          });
                        } else {
                          setState(() {
                            carsByName.clear();
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: carsByName.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          margin: const EdgeInsets.all(2),
                          child: Center(
                              child: Text(
                            '[${carsByName[index].id}] ${carsByName[index].name} - ${carsByName[index].miles} miles',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// Update
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: idUpdateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car id',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameUpdateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: milesUpdateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Miles',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int id = int.parse(idUpdateController.text);
                      String name = nameUpdateController.text;
                      int miles = int.parse(milesUpdateController.text);
                      _update(id, name, miles);
                    },
                    child: const Text('Update Car Details'),
                  ),
                ],
              ),
            ),

            /// Delete
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: idDeleteController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car id',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int id = int.parse(idDeleteController.text);
                      _delete(id);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
