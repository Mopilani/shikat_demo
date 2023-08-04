DateTime? stringOrDateTime(dynamic) {
  if (dynamic is String) {
    return DateTime.tryParse(dynamic);
  } else if (dynamic is DateTime) {
    return dynamic;
  }
  return null;
}
