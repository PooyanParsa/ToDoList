import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'db_helper.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool _showTaskInput = false;
  DateTime? _selectedDate;
  String selectedPriority = 'متوسط';
  bool _isEditing = false;
  Map<String, dynamic>? _editingTask;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
      _filteredTasks = tasks;
    });
  }

  Future<void> _addOrEditTask(String title, String description,
      DateTime dueDate, String priority) async {
    if (_isEditing && _editingTask != null) {
      await dbHelper.updateTaskCompletion(_editingTask!['id'], false);
    } else {
      await dbHelper.addTask(title, description, dueDate, priority);
    }

    _loadTasks();
    setState(() {
      _showTaskInput = false;
      _isEditing = false;
    });
  }

  Future<void> _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
  }

  Future<void> _toggleTaskCompletion(int id, bool isCompleted) async {
    await dbHelper.updateTaskCompletion(id, isCompleted);
    _loadTasks();
  }

  void _filterTasks(String filterType) {
    if (filterType == 'completed') {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task['isCompleted'] == 1).toList();
      });
    } else if (filterType == 'incomplete') {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task['isCompleted'] == 0).toList();
      });
    } else if (filterType == 'high') {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task['priority'] == 'بالا').toList();
      });
    } else if (filterType == 'medium') {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task['priority'] == 'متوسط').toList();
      });
    } else if (filterType == 'low') {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task['priority'] == 'پایین').toList();
      });
    } else {
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('لیست کارها',
                style: TextStyle(
                    fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _filteredTasks.length,
            itemBuilder: (context, index) {
              final task = _filteredTasks[index];
              final bool isCompleted = task['isCompleted'] == 1 ? true : false;
              final DateTime dueDate = DateTime.parse(task['dueDate']);
              final Jalali jalaliDate = Jalali.fromDateTime(dueDate);
              final String priority = task['priority'];

              Color priorityColor;
              if (isCompleted) {
                priorityColor = Colors.green;
              } else {
                switch (priority) {
                  case 'بالا':
                    priorityColor = Colors.red;
                    break;
                  case 'متوسط':
                    priorityColor = Colors.orange;
                    break;
                  case 'پایین':
                    priorityColor = Colors.yellow;
                    break;
                  default:
                    priorityColor = Colors.grey;
                }
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: priorityColor,
                    radius: 12,
                  ),
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      fontFamily: 'Peyda',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isCompleted ? Colors.grey : Colors.black,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['description'],
                        style: TextStyle(fontFamily: 'Peyda', fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'تاریخ انجام این تسک: ${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}',
                          style: TextStyle(fontFamily: 'Peyda', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editTask(task);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteTask(task['id']);
                        },
                      ),
                      Switch(
                        value: isCompleted,
                        onChanged: (value) {
                          _toggleTaskCompletion(task['id'], value);
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_showTaskInput)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildTaskInputContainer(),
            ),
        ],
      ),
      floatingActionButton: _showTaskInput
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showTaskInput = true;
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 10,
            ),
    );
  }

  Widget _buildTaskInputContainer() {
    final TextEditingController titleController = TextEditingController(
        text: _isEditing && _editingTask != null ? _editingTask!['title'] : '');
    final TextEditingController descriptionController = TextEditingController(
        text: _isEditing && _editingTask != null
            ? _editingTask!['description']
            : '');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'عنوان وظیفه',
              labelStyle: TextStyle(fontWeight: FontWeight.w500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  _addOrEditTask(
                    titleController.text,
                    descriptionController.text,
                    _selectedDate ?? DateTime.now(),
                    selectedPriority,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          SizedBox(height: 3),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'توضیحات',
              labelStyle: TextStyle(fontWeight: FontWeight.w500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_selectedDate != null)
                Text(
                  'تاریخ: ${Jalali.fromDateTime(_selectedDate!).year}/${Jalali.fromDateTime(_selectedDate!).month}/${Jalali.fromDateTime(_selectedDate!).day}',
                  style: TextStyle(fontFamily: 'Peyda', fontSize: 14),
                ),
              TextButton(
                onPressed: () async {
                  Jalali? pickedDate = await showPersianDatePicker(
                    context: context,
                    initialDate: Jalali.now(),
                    firstDate: Jalali(1300, 1),
                    lastDate: Jalali(1450, 12),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate.toDateTime();
                    });
                  }
                },
                child: Text('انتخاب تاریخ'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: 'بالا',
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              Text('بالا'),
              Radio<String>(
                value: 'متوسط',
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              Text('متوسط'),
              Radio<String>(
                value: 'پایین',
                groupValue: selectedPriority,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              Text('پایین'),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showTaskInput = false;
              });
            },
            child: Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('فیلتر تسک‌ها'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('تسک‌های انجام‌شده'),
                onTap: () {
                  Navigator.of(context).pop();
                  _filterTasks('completed');
                },
              ),
              ListTile(
                title: Text('تسک‌های انجام‌نشده'),
                onTap: () {
                  Navigator.of(context).pop();
                  _filterTasks('incomplete');
                },
              ),
              ListTile(
                title: Text('اولویت بالا'),
                onTap: () {
                  Navigator.of(context).pop();
                  _filterTasks('high');
                },
              ),
              ListTile(
                title: Text('اولویت متوسط'),
                onTap: () {
                  Navigator.of(context).pop();
                  _filterTasks('medium');
                },
              ),
              ListTile(
                title: Text('اولویت پایین'),
                onTap: () {
                  Navigator.of(context).pop();
                  _filterTasks('low');
                },
              ),
              ListTile(
                title: Text('نمایش همه'),
                onTap: () {
                  Navigator.of(context).pop();
                  _loadTasks();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editTask(Map<String, dynamic> task) {
    setState(() {
      _editingTask = task;
      _isEditing = true;
      _showTaskInput = true;
      selectedPriority = task['priority'];
      _selectedDate = DateTime.parse(task['dueDate']);
    });
  }
}
