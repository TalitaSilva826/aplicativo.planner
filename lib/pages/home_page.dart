import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Task {
  final DateTime date;
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;

  Task(this.date, this.time, this.title, this.subtitle, this.icon);
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  DateTime? _filterDate;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Task> get _visibleTasks {
    if (_filterDate == null) return _tasks;
    return _tasks.where((t) => _isSameDay(t.date, _filterDate!)).toList();
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  void _clearFilter() => setState(() => _filterDate = null);

  Future<void> _openAddTaskSheet() async {
    final titleCtl = TextEditingController();
    final subtitleCtl = TextEditingController();
    DateTime selectedDate = _filterDate ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: subtitleCtl,
                decoration: const InputDecoration(labelText: 'Detalhes'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(selectedDate.year - 5),
                          lastDate: DateTime(selectedDate.year + 5),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          selectedTime = picked;
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(selectedTime.format(ctx)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtl.text.trim();
                  final subtitle = subtitleCtl.text.trim();
                  if (title.isEmpty) return;
                  final timeStr = selectedTime.format(ctx);
                  final task = Task(
                    DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                    timeStr,
                    title,
                    subtitle,
                    Icons.check_circle_outline,
                  );
                  setState(() {
                    _tasks.add(task);
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5F7),
            Color(0xFFFFEBF0),
            Color(0xFFFFE1E8),
          ],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Hoje'),
          actions: [
            IconButton(
              onPressed: _pickFilterDate,
              icon: const Icon(Icons.calendar_today_outlined),
              tooltip: 'Filtrar por data',
            ),
            if (_filterDate != null)
              IconButton(
                onPressed: _clearFilter,
                icon: const Icon(Icons.clear),
                tooltip: 'Limpar filtro',
              ),
          ],
        ),

        body: _visibleTasks.isEmpty
            ? Center(
                child: Text(
                  _filterDate == null
                      ? 'Nenhuma tarefa criada'
                      : 'Nenhuma tarefa para ${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}',
                  style: const TextStyle(color: kDarkText),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: _visibleTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = _visibleTasks[index];
                  return _TaskCard(task: task);
                },
              ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          onPressed: _openAddTaskSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.time,
                style: const TextStyle(
                  color: kDarkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${task.date.day}/${task.date.month}/${task.date.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withAlpha((0.15 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    task.icon,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: kDarkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
