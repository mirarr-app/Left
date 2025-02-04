import 'package:flutter/material.dart';
import 'package:Left/services/days.dart';
import 'package:Left/UI/dot_pattern.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Left/models/user_data.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late Box<UserData> userDataBox;
  UserData? userData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userDataBox = await Hive.openBox<UserData>('userData');
    setState(() {
      userData = userDataBox.get('user');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysUntilNextYear = getDaysUntilNextYear();
    final daysPassed = dateDifference(now, DateTime(now.year, 1, 1));
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dayOfMonth = now.day;

    // Calculate age and lifespan if birthday is available
    final age = userData?.birthday != null
        ? ((now.difference(userData!.birthday!).inDays) / 365).floor()
        : 24;
    final lifespan = userData?.expectedLifespan ?? 80;
    final yearsLeft = lifespan - age;

    final List<Widget> pages = [
      _buildYearView(daysUntilNextYear, daysPassed),
      _buildMonthView(dayOfMonth, daysInMonth),
      if (userData?.birthday != null) _buildBirthdayView(),
      _buildLifeViewMonths(age, lifespan),
      _buildLifeViewYears(yearsLeft, lifespan),
      ...(userData?.importantDates ?? [])
          .map((date) => _buildImportantDateView(date))
          .toList(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: pages,
      ),
    );
  }

  Widget _buildYearView(int daysUntilNextYear, int daysPassed) {
    final now = DateTime.now();
    final daysLeft = isLeapYear(now.year) ? 366 : 365 - daysPassed;
    final persentLeftTillNextYear =
        (daysLeft / (isLeapYear(now.year) ? 366 : 365)) * 100;
    final currentYear = DateFormat('yyyy').format(now);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: isLeapYear(now.year) ? 366 : 365,
          startDay: daysPassed,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                '$currentYear: $daysUntilNextYear days / ${persentLeftTillNextYear.round()}% Left',
                style: TextStyle(
                    fontSize: 18, color: Colors.white.withOpacity(0.4)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(int dayOfMonth, int daysInMonth) {
    final now = DateTime.now();
    final persentLeftTillNextMonth =
        (daysInMonth - dayOfMonth) / daysInMonth * 100;
    final currentMonthName = DateFormat('MMMM').format(now);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: daysInMonth,
          startDay: dayOfMonth,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                'Day ${now.day} of $currentMonthName / ${persentLeftTillNextMonth.round()}% Left',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayView() {
    final now = DateTime.now();
    final nextBirthday = DateTime(
      now.year +
          (now.month > userData!.birthday!.month ||
                  (now.month == userData!.birthday!.month &&
                      now.day >= userData!.birthday!.day)
              ? 1
              : 0),
      userData!.birthday!.month,
      userData!.birthday!.day,
    );
    final daysUntilBirthday = nextBirthday.difference(now).inDays;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: 365,
          startDay: 365 - daysUntilBirthday,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                '${userData!.birthday!.day}/${userData!.birthday!.month}: $daysUntilBirthday days Left',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantDateView(ImportantDate date) {
    final now = DateTime.now();
    final nextOccurrence = DateTime(
      now.year +
          (now.month > date.date.month ||
                  (now.month == date.date.month && now.day >= date.date.day)
              ? 1
              : 0),
      date.date.month,
      date.date.day,
    );
    final daysUntil = nextOccurrence.difference(now).inDays;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: 365,
          startDay: 365 - daysUntil,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                '${date.title}: $daysUntil Left',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLifeViewMonths(int age, int lifespan) {
    final currentAgeMonths = age * 12;
    final expectedLifespanMonths = lifespan * 12;
    final monthsLeft = expectedLifespanMonths - currentAgeMonths;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: expectedLifespanMonths,
          startDay: currentAgeMonths,
          isYearView: false,
          isMonthView: true,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                'life: $monthsLeft months Left',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLifeViewYears(int yearsLeft, int lifespan) {
    final age = lifespan - yearsLeft;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DotPattern(
          days: lifespan,
          startDay: age,
          isYearView: true,
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _addNewImportantDate(context),
                icon: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                'life: $yearsLeft years Left',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addNewImportantDate(BuildContext context) async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    final bool? shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add important date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Anniversary',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                selectedDate != null
                    ? DateFormat('MMM d').format(selectedDate!)
                    : 'Select date',
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate = DateTime(
                    DateTime.now().year,
                    picked.month,
                    picked.day,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedDate != null) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (shouldAdd == true && selectedDate != null) {
      final newDate = ImportantDate(
        title: titleController.text,
        date: selectedDate!,
      );

      setState(() {
        userData?.importantDates.add(newDate);
      });

      await userDataBox.put('user', userData!);
    }
  }
}
