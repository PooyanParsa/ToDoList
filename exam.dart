import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'db_helper.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  int completedTasks = 0;
  int incompleteTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
      completedTasks = tasks.where((task) => task['isCompleted'] == 1).length;
      incompleteTasks = tasks.where((task) => task['isCompleted'] == 0).length;
    });
  }

  List<charts.Series<TaskData, String>> _createChartData() {
    final data = [
      TaskData('انجام‌شده', completedTasks),
      TaskData('انجام‌نشده', incompleteTasks),
    ];

    return [
      charts.Series<TaskData, String>(
        id: 'Tasks',
        domainFn: (TaskData taskData, _) => taskData.status,
        measureFn: (TaskData taskData, _) => taskData.count,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('آمار و گزارش‌ها'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'تعداد تسک‌ها',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: charts.BarChart(
                _createChartData(),
                animate: true,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'جزئیات تسک‌ها',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: Text(task['description']),
                      trailing: Icon(
                        task['isCompleted'] == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: task['isCompleted'] == 1
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskData {
  final String status;
  final int count;

  TaskData(this.status, this.count);
}
