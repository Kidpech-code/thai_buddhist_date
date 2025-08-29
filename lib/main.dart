import 'package:flutter/material.dart';

import 'widgets/buddhist_gregorian_calendar.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart'
    show
        showThaiDatePicker,
        showThaiDateTimePicker,
        showThaiMultiDatePicker,
        showThaiDatePickerFullscreen,
        showThaiDatePickerFormatted,
        showThaiDateTimePickerFormatted;

Future<void> main() async {
  // Ensure Thai locale data is loaded for month/weekday names
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Buddhist Date Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MyHomePage(title: 'Calendar (พ.ศ./ค.ศ.)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  tbd.Era _era = tbd.Era.be;
  DateTime? _selected;
  DateTimeRange? _range;
  Set<DateTime>? _multi;
  String? _formattedOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          DropdownButton<tbd.Era>(
            value: _era,
            underline: const SizedBox.shrink(),
            onChanged: (e) => setState(() => _era = e ?? tbd.Era.be),
            items: const [
              DropdownMenuItem(value: tbd.Era.be, child: Text('พ.ศ.')),
              DropdownMenuItem(value: tbd.Era.ce, child: Text('ค.ศ.')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuddhistGregorianCalendar(
              era: _era,
              selectedDate: _selected,
              onDateSelected: (d) => setState(() => _selected = d),
              locale: 'th_TH',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('เลือกวันที่:'),
                const SizedBox(width: 8),
                Text(
                  _selected == null
                      ? '-'
                      : _selected!.toThaiStringSync(
                          pattern: 'dd/MM/yyyy',
                          era: _era,
                          locale: 'th_TH',
                        ),
                ),
              ],
            ),
            if (_range != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('ช่วงวันที่:'),
                  const SizedBox(width: 8),
                  Text(
                    '${_range!.start.toThaiStringSync(pattern: 'dd/MM/yyyy', era: _era, locale: 'th_TH')} - '
                    '${_range!.end.toThaiStringSync(pattern: 'dd/MM/yyyy', era: _era, locale: 'th_TH')}',
                  ),
                ],
              ),
            ],
            if (_multi != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('หลายวันที่:'),
                  const SizedBox(width: 8),
                  Text(_multi!.isEmpty ? '-' : '${_multi!.length} รายการ'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 88),
                child: Text(
                  _multi!.isEmpty
                      ? ''
                      : (() {
                          final sorted = _multi!.toList()
                            ..sort((a, b) => a.compareTo(b));
                          final shown = sorted
                              .take(3)
                              .map(
                                (d) => d.toThaiStringSync(
                                  pattern: 'dd/MM',
                                  era: _era,
                                  locale: 'th_TH',
                                ),
                              )
                              .join(', ');
                          final more = sorted.length > 3
                              ? ' (+${sorted.length - 3} more)'
                              : '';
                          return '$shown$more';
                        })(),
                ),
              ),
            ],
            if (_formattedOut != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Formatted:'),
                  const SizedBox(width: 8),
                  Text(_formattedOut!),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final picked = await showThaiDatePicker(
                      context,
                      initialDate: _selected ?? DateTime.now(),
                      era: _era,
                      locale: 'th_TH',
                    );
                    if (picked != null) setState(() => _selected = picked);
                  },
                  icon: const Icon(Icons.event),
                  label: const Text('เลือกวันที่ (Dialog)'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final picked = await showThaiDateTimePicker(
                      context,
                      initialDateTime: _selected ?? DateTime.now(),
                      era: _era,
                      locale: 'th_TH',
                      formatString: 'dd MMM yyyy HH:mm',
                    );
                    if (picked != null) setState(() => _selected = picked);
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('เลือกวันและเวลา (Dialog)'),
                ),

                FilledButton.icon(
                  onPressed: () async {
                    final m = await showThaiMultiDatePicker(
                      context,
                      era: _era,
                      locale: 'th_TH',
                    );
                    if (m != null) setState(() => _multi = m);
                  },
                  icon: const Icon(Icons.event_repeat),
                  label: const Text('หลายวันที่ (Dialog)'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final picked = await showThaiDatePickerFullscreen(
                      context,
                      initialDate: _selected ?? DateTime.now(),
                      era: _era,
                      locale: 'th_TH',
                    );
                    if (picked != null) setState(() => _selected = picked);
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('เลือกวันที่ (Fullscreen)'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final out = await showThaiDatePickerFormatted(
                      context,
                      initialDate: _selected ?? DateTime.now(),
                      era: _era,
                      locale: 'th_TH',
                      formatString: 'dd/MM/yyyy',
                    );
                    if (out != null) setState(() => _formattedOut = out);
                  },
                  icon: const Icon(Icons.output),
                  label: const Text('ผลลัพธ์เป็น String (วันที่)'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final out = await showThaiDateTimePickerFormatted(
                      context,
                      initialDateTime: _selected ?? DateTime.now(),
                      era: _era,
                      locale: 'th_TH',
                      formatString: 'dd/MM/yyyy HH:mm',
                    );
                    if (out != null) setState(() => _formattedOut = out);
                  },
                  icon: const Icon(Icons.text_fields),
                  label: const Text('ผลลัพธ์เป็น String (วันเวลา)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
