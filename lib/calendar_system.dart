import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';

class CalendarEvent {
  final int? id;
  final String title;
  final DateTime date;
  final String time;
  final String description;
  final String location;
  final String repeating;
  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
    required this.location,
    required this.repeating,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      repeating: map['repeating'] as String? ?? '',
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, List<CalendarEvent>>((ref) => CalendarNotifier());

class CalendarNotifier extends StateNotifier<List<CalendarEvent>> {
  CalendarNotifier() : super([]) {
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventMaps = await DatabaseHelper.instance.getEvents();
    state = eventMaps.map((e) => CalendarEvent.fromMap(e)).toList();
  }

  Future<void> addEvent(CalendarEvent event) async {
    await DatabaseHelper.instance.insertEvent(
      event.title,
      event.date,
      event.time,
      event.description,
      event.location,
      event.repeating,
    );
    await _fetchEvents();
  }

  Future<void> removeEvent(CalendarEvent event) async {
    if (event.id != null) {
      await DatabaseHelper.instance.deleteEvent(event.id!);
      await _fetchEvents();
    }
  }
}

class CalendarSystemPage extends StatelessWidget {
  const CalendarSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar System'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const UpcomingEventsWidget(),
      ),
    );
  }
}

class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
              tooltip: 'Add Event',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddEventDialog(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2F3136),
              borderRadius: BorderRadius.circular(12),
            ),
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No events yet.',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event.title, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(event.date.toString(), style: const TextStyle(color: Colors.white70)),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class AddEventDialog extends ConsumerStatefulWidget {
  const AddEventDialog({super.key});

  @override
  ConsumerState<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<AddEventDialog> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  String _time = '09:00 AM';
  String _description = '';
  String _location = '';
  String _repeating = 'None';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF36393F),
      title: const Text('Create Event', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _selectedDate == null
                    ? 'No date chosen'
                    : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: const Text('Pick Date'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _location = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Location',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _repeating,
            onChanged: (value) {
              setState(() {
                _repeating = value!;
              });
            },
            items: <String>['None', 'Daily', 'Weekly', 'Monthly']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Repeating',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            dropdownColor: const Color(0xFF2F3136),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _time = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Time (e.g., 09:00 AM)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _selectedDate != null) {
              ref.read(calendarProvider.notifier).addEvent(
                CalendarEvent(
                  title: _titleController.text,
                  date: _selectedDate!,
                  time: _time,
                  description: _description,
                  location: _location,
                  repeating: _repeating,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Event'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
