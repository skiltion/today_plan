Duration calculateOverlap(
  DateTime start1,
  DateTime end1,
  DateTime start2,
  DateTime end2,
) {
  final start = start1.isAfter(start2) ? start1 : start2;
  final end = end1.isBefore(end2) ? end1 : end2;

  if (start.isAfter(end)) return Duration.zero;

  return end.difference(start);
}