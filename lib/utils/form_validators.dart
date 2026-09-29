String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter your email address';
  }
  final RegExp pattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
  if (!pattern.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}
