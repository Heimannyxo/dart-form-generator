String? notEmpty(String? value, String ctx) {
  return value == null || value.trim().isEmpty
      ? "$ctx should not be empty"
      : null;
}
