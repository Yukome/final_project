class Validators {
  static String? required(String? value, [String message = 'Обязательное поле']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? length(String? value, int min, int max, [String? message]) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    if (value.length < min) return message ?? 'Минимум $min символов';
    if (value.length > max) return message ?? 'Максимум $max символов';
    return null;
  }

  static String? number(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    final num = double.tryParse(value.replaceAll(',', '.'));
    if (num == null) return 'Введите число';
    if (min != null && num < min) return 'Не меньше $min';
    if (max != null && num > max) return 'Не больше $max';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите Email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Некорректный формат Email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите телефон';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Некорректный номер телефона';
    }
    return null;
  }

  static String? dateNotInFuture(String? value) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    final date = DateTime.tryParse(value);
    if (date == null) return 'Некорректная дата';
    if (date.isAfter(DateTime.now())) return 'Дата не может быть в будущем';
    return null;
  }
}