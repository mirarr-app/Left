int dateDifference(DateTime targetDate, DateTime startDate) {
  final difference = targetDate.difference(startDate);
  return difference.inDays;
}

int getDaysUntilNextYear() {
  final now = DateTime.now();
  final nextYear = DateTime(now.year + 1, 1, 1);
  final difference = nextYear.difference(now);
  return difference.inDays;
}

int getDaysInYear(int year) {
  int days = DateTime(year + 1, 1, 1).difference(DateTime(year, 1, 1)).inDays;
  return days;
}

bool isLeapYear(int year) {
  if (getDaysInYear(year) == 366) {
    return true;
  }
  return false;
}
