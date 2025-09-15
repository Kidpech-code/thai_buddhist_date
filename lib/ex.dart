import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _selectedRange;
  Set<DateTime> _multiSelected = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Set global defaults for demo consistency
    ThaiDateSettings.set(era: Era.be, language: ThaiLanguage.thai);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thai Buddhist Date'),
            Text(
              'Complete showcase for pub.dev',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.format_color_text), text: 'Formatting'),
            Tab(icon: Icon(Icons.data_object), text: 'Parsing'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.settings), text: 'Dialogs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormattingTab(),
          _buildParsingTab(),
          _buildCalendarTab(),
          _buildDialogsTab(),
        ],
      ),
    );
  }

  // Formatting examples tab
  Widget _buildFormattingTab() {
    final sample = DateTime(2025, 8, 25, 14, 30);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHighlightCard(),
        const SizedBox(height: 16),

        _buildExampleCard('Quick Start (format/parse)', Icons.play_arrow, [
          _codeExample(
            'Basic usage',
            '''import 'package:thai_buddhist_date/thai_buddhist_date.dart';

// Parse either BE or CE and get a DateTime (internally CE)
final dt = parse('2568-08-22'); // BE input -> CE internally (2025-08-22)

// Top-level format is synchronous
print(format(dt, pattern: 'yyyy-MM-dd', era: Era.ce)); // 2025-08-22''',
            {
              "parse('2568-08-22')": parse('2568-08-22').toString(),
              "format(dt, era: Era.ce)": format(
                sample,
                pattern: 'yyyy-MM-dd',
                era: Era.ce,
              ),
              "format(dt) // default BE": format(sample),
            },
          ),
        ]),

        _buildExampleCard(
          'Thai Full Date Format (วัน เดือน ปี)',
          Icons.calendar_today,
          [
            _codeExample(
              'Using preset pattern with BE or CE',
              '''final d = DateTime(2025, 8, 25);
print(format(d, pattern: 'dmy', era: Era.be)); // 25 สิงหาคม 2568
print(format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025''',
              {
                "pattern: 'dmy' (BE)": format(
                  sample,
                  pattern: 'dmy',
                  era: Era.be,
                ),
                "pattern: 'dmy' (CE)": format(
                  sample,
                  pattern: 'dmy',
                  era: Era.ce,
                ),
                "pattern: 'fullText' (BE)": format(
                  sample,
                  pattern: 'fullText',
                  era: Era.be,
                ),
                "pattern: 'fullText' (CE)": format(
                  sample,
                  pattern: 'fullText',
                  era: Era.ce,
                ),
              },
            ),
          ],
        ),

        _buildExampleCard('Custom Patterns', Icons.format_paint, [
          _codeExample(
            'Use any intl-style pattern',
            '''final d = DateTime(2025, 8, 25);
print(format(d, pattern: 'dd/MM/yyyy'));       // 25/08/2568 (BE)
print(format(d, pattern: 'MMMM yyyy'));        // สิงหาคม 2568 (BE)
print(format(d, pattern: 'MMMM yyyy', era: Era.ce)); // สิงหาคม 2025 (CE)''',
            {
              "dd/MM/yyyy (BE)": format(sample, pattern: 'dd/MM/yyyy'),
              "dd/MM/yyyy (CE)": format(
                sample,
                pattern: 'dd/MM/yyyy',
                era: Era.ce,
              ),
              "MMMM yyyy (BE)": format(sample, pattern: 'MMMM yyyy'),
              "MMMM yyyy (CE)": format(
                sample,
                pattern: 'MMMM yyyy',
                era: Era.ce,
              ),
              "d MMMM yyyy": format(sample, pattern: 'd MMMM yyyy'),
            },
          ),
        ]),

        _buildExampleCard('Multi-language Support', Icons.language, [
          _codeExample(
            'Pick any locale via the locale: parameter',
            '''final svc = ThaiDateService();
// Date only
final frDate = await svc.formatNow(pattern: 'yyyy-MM-dd', locale: 'fr');
// Override per call with another language
final esFull = await svc.formatNow(pattern: 'fullText', locale: 'es');''',
            {
              "fullText (Thai)": format(
                sample,
                pattern: 'fullText',
                locale: 'th_TH',
              ),
              "fullText (English)": format(
                sample,
                pattern: 'fullText',
                locale: 'en_US',
              ),
              "fullText (Japanese)": format(
                sample,
                pattern: 'fullText',
                locale: 'ja',
              ),
              "MMMM yyyy (Thai)": format(
                sample,
                pattern: 'MMMM yyyy',
                locale: 'th_TH',
              ),
            },
          ),
        ]),

        _buildExampleCard('Helpers & Extensions', Icons.extension, [
          _codeExample(
            'Quick helpers and extensions',
            '''// Today shortcuts
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.be));
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.ce));

// Extensions
print(DateTime(2025, 8, 22).toThaiStringSync(pattern: 'yyyy-MM-dd'));''',
            {
              "formatNow BE": formatNow(pattern: 'dd/MM/yyyy', era: Era.be),
              "formatNow CE": formatNow(pattern: 'dd/MM/yyyy', era: Era.ce),
              "toThaiStringSync": DateTime(
                2025,
                8,
                22,
              ).toThaiStringSync(pattern: 'yyyy-MM-dd'),
              "formatSync": ThaiDateService().formatSync(
                ThaiDate.fromDateTime(sample),
                pattern: 'iso',
              ),
            },
          ),
        ]),
      ],
    );
  }

  // Parsing examples tab
  Widget _buildParsingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExampleCard('Creative Parse/Format Helpers', Icons.transform, [
          _codeExample(
            'Flexible, ergonomic conversion between String and DateTime',
            '''// Parsing (String to DateTime) - BE formats
parseThaiDate('03092568');         // BE, compact
parseThaiDate('03-09-2568');       // BE, dash
parseThaiDate('03/09/2568');       // BE, slash
parseThaiDate('2568-09-03');       // BE, ISO

// Parsing CE formats
parseThaiDate('03092025', era: Era.ce); // CE, compact
parseThaiDate('2025-09-03', era: Era.ce); // CE, ISO''',
            {
              "parseThaiDate('03092568')": _safeParseThaiDate(
                '03092568',
              ).toString(),
              "parseThaiDate('03/09/2568')": _safeParseThaiDate(
                '03/09/2568',
              ).toString(),
              "parseThaiDate('2568-09-03')": _safeParseThaiDate(
                '2568-09-03',
              ).toString(),
              "parseThaiDate('2025-09-03', CE)": _safeParseThaiDate(
                '2025-09-03',
                era: Era.ce,
              ).toString(),
            },
          ),
        ]),

        _buildExampleCard('Format Examples', Icons.format_shapes, [
          _codeExample(
            'DateTime to String formatting',
            '''// Formatting (DateTime to String)
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'dd/MM/yyyy'); // '03/09/2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'dd/MM/yyyy'); // '03/09/2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'yyyy-MM-dd'); // '2568-09-03'

// Custom formats
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'ddMMyyyy'); // '03092568' ''',
            {
              "formatThaiDate BE dd/MM/yyyy": _formatThaiDate(
                DateTime(2568, 9, 3),
                era: Era.be,
                format: 'dd/MM/yyyy',
              ),
              "formatThaiDate CE dd/MM/yyyy": _formatThaiDate(
                DateTime(2025, 9, 3),
                era: Era.ce,
                format: 'dd/MM/yyyy',
              ),
              "formatThaiDate BE yyyy-MM-dd": _formatThaiDate(
                DateTime(2568, 9, 3),
                era: Era.be,
                format: 'yyyy-MM-dd',
              ),
              "formatThaiDate BE ddMMyyyy": _formatThaiDate(
                DateTime(2568, 9, 3),
                era: Era.be,
                format: 'ddMMyyyy',
              ),
            },
          ),
        ]),

        _buildExampleCard('Explicit-era Parsing', Icons.settings, [
          _codeExample(
            'When your input is known to be พ.ศ., parse with explicit era',
            '''final parsed = ThaiDateService().parseWithEra(
  '25 สิงหาคม 2568',
  era: Era.be,
  pattern: 'd MMMM yyyy',
);
print(parsed?.toDateTime()); // 2025-08-25 00:00:00.000''',
            {
              "Parsed date": (() {
                try {
                  final parsed = ThaiDateService().parseWithEra(
                    '25 สิงหาคม 2568',
                    era: Era.be,
                    pattern: 'd MMMM yyyy',
                  );
                  return parsed?.toDateTime().toString() ?? 'null';
                } catch (e) {
                  return 'Error: $e';
                }
              })(),
            },
          ),
        ]),

        _buildExampleCard('Common Recipes', Icons.receipt, [
          _codeExample(
            'Everyday patterns',
            '''// 1) Today in BE and CE (compat functions)
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.be));
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.ce));

// 2) Parsing
print(parse('22/08/2568', format: 'dd/MM/yyyy'));
print(parse('2025-08-22', format: 'yyyy-MM-dd'));''',
            {
              "Today BE": formatNow(pattern: 'dd/MM/yyyy', era: Era.be),
              "Today CE": formatNow(pattern: 'dd/MM/yyyy', era: Era.ce),
              "parse BE": parse('22/08/2568', format: 'dd/MM/yyyy').toString(),
              "parse CE": parse('2025-08-22', format: 'yyyy-MM-dd').toString(),
              "formatNow fullText": formatNow(pattern: 'fullText'),
            },
          ),
        ]),
      ],
    );
  }

  // Calendar widget tab
  Widget _buildCalendarTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExampleCard('Month Calendar Widget', Icons.calendar_view_month, [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                BuddhistGregorianCalendar(
                  era: Era.be,
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                  locale: 'th_TH',
                  firstDate: DateTime(1900, 1, 1),
                  lastDate: DateTime(2100, 12, 31),
                ),
                const SizedBox(height: 16),
                Card.filled(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.event),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${format(_selectedDate, pattern: 'fullText', era: Era.be)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),

        _buildExampleCard('Code Example', Icons.code, [
          _codeExample(
            'Using BuddhistGregorianCalendar',
            '''BuddhistGregorianCalendar(
  era: Era.be,                 // or Era.ce
  selectedDate: selectedDate,
  onDateSelected: (date) => setState(() => selectedDate = date),
  locale: 'th_TH',
  firstDate: DateTime(1900, 1, 1),
  lastDate: DateTime(2100, 12, 31),
  dayBuilder: customDay?,       // optional: build your own day cells
)''',
            {},
          ),
        ]),
      ],
    );
  }

  // Dialogs and pickers tab
  Widget _buildDialogsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExampleCard('Date Pickers', Icons.date_range, [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final picked = await showThaiDatePicker(
                    context,
                    initialDate: _selectedDate,
                    era: Era.be,
                    locale: 'th_TH',
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.today),
                label: const Text('Date Picker'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final picked = await showThaiDatePickerFullscreen(
                    context,
                    initialDate: _selectedDate,
                    era: Era.be,
                    locale: 'th_TH',
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.fullscreen),
                label: const Text('Fullscreen Picker'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final s = await showThaiDatePickerFormatted(
                    context,
                    initialDate: _selectedDate,
                    era: Era.be,
                    locale: 'th_TH',
                    formatString: 'dd/MM/yyyy',
                  );
                  if (!mounted) return;
                  if (s != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Formatted: $s')));
                  }
                },
                icon: const Icon(Icons.format_quote),
                label: const Text('Formatted Output'),
              ),
            ],
          ),
        ]),

        _buildExampleCard('Date-Time Picker', Icons.access_time, [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final dt = await showThaiDateTimePicker(
                    context,
                    initialDateTime: DateTime.now(),
                    era: Era.ce,
                    locale: 'th_TH',
                    formatString: 'dd/MM/yyyy HH:mm',
                  );
                  if (!mounted) return;
                  if (dt != null) {
                    final label = format(dt, pattern: 'fullText', era: Era.ce);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Picked: $label'),
                        action: SnackBarAction(
                          label: 'Copy',
                          onPressed: () =>
                              Clipboard.setData(ClipboardData(text: label)),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Date-Time Picker'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final s = await showThaiDateTimePickerFormatted(
                    context,
                    initialDateTime: DateTime.now(),
                    era: Era.be,
                    locale: 'th_TH',
                    formatString: 'dd/MM/yyyy HH:mm',
                  );
                  if (!mounted) return;
                  if (s != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Formatted DT: $s')));
                  }
                },
                icon: const Icon(Icons.format_quote),
                label: const Text('Formatted Date-Time'),
              ),
            ],
          ),
        ]),

        _buildExampleCard('Range & Multi Selection', Icons.date_range, [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () async {
                  final r = await showThaiDateRangePicker(
                    context,
                    era: Era.be,
                    locale: 'th_TH',
                  );
                  if (r != null) setState(() => _selectedRange = r);
                },
                icon: const Icon(Icons.date_range),
                label: const Text('Range Picker'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final m = await showThaiMultiDatePicker(
                    context,
                    era: Era.be,
                    locale: 'th_TH',
                  );
                  if (m != null) setState(() => _multiSelected = m);
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Multi-Date Picker'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedRange != null)
            Card.filled(
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Selected Range'),
                subtitle: Text(
                  '${format(_selectedRange!.start, pattern: 'dd/MM/yyyy')} - ${format(_selectedRange!.end, pattern: 'dd/MM/yyyy')}',
                ),
              ),
            ),
          if (_multiSelected.isNotEmpty)
            Card.filled(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Multi-Selected Dates'),
                subtitle: Text(
                  _multiSelected
                      .map((e) => format(e, pattern: 'dd/MM/yyyy'))
                      .join(', '),
                ),
              ),
            ),
        ]),

        _buildExampleCard('Code Examples', Icons.code, [
          _codeExample(
            'Basic picker usage',
            '''// Single date
final picked = await showThaiDatePicker(
  context,
  locale: 'th_TH',
);

// Date-time with preview (custom preview format)
final dt = await showThaiDateTimePicker(
  context,
  formatString: 'dd/MM/yyyy HH:mm',
);

// Range (dialog)
final range = await showThaiDateRangePicker(context, era: Era.be, locale: 'th_TH');

// Multi-date
final multiple = await showThaiMultiDatePicker(context, era: Era.be, locale: 'th_TH');''',
            {},
          ),
        ]),
      ],
    );
  }

  // Helper methods for building UI components
  Widget _buildHighlightCard() {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Highlights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Format with BE or CE: format(DateTime, era: ...) outputs the year in พ.ศ. (BE) or ค.ศ. (CE)\n'
              '• Parse both BE and CE seamlessly: parse(String) detects BE years (>= 2400)\n'
              '• Token-aware formatter: Only the year tokens are replaced when outputting BE\n'
              '• Clean Architecture service: High-level ThaiDateService with caching\n'
              '• Flutter extras: Calendar and date pickers with theming hooks',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _codeExample(String title, String code, Map<String, String> outputs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        if (outputs.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...outputs.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        entry.value,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: entry.value)),
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Helper methods for safe demo operations
  String _formatThaiDate(
    DateTime date, {
    required Era era,
    required String format,
  }) {
    try {
      // Use the service for consistent formatting
      return ThaiDateService().formatSync(
        ThaiDate.fromDateTime(date),
        pattern: format,
      );
    } catch (e) {
      return 'Error: $e';
    }
  }

  DateTime _safeParseThaiDate(String input, {Era? era}) {
    try {
      // Simple parsing for demo - detect format and parse accordingly
      if (input.contains('/')) {
        return parse(input, format: 'dd/MM/yyyy');
      } else if (input.contains('-')) {
        return parse(input, format: 'yyyy-MM-dd');
      } else if (input.length == 8) {
        return parse(input, format: 'ddMMyyyy');
      } else {
        return parse(input);
      }
    } catch (e) {
      return DateTime.now(); // fallback
    }
  }
}
