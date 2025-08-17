import 'package:flutter/services.dart';

class DateFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String text = newValue.text.replaceAll(r'[^0-9]', '');

    if (text.length > 8) {
      return oldValue;
    }

    String formatted = '';

    if (text.length >= 2) {
      formatted += '${text.substring(0,2)}/';
      if (text.length >= 4) {
        formatted += '${text.substring(2,4)}/';
        if (text.length > 4) {
          formatted += text.substring(4);
        }
      } else {
        formatted += text.substring(2);
      }
    } else {
      formatted = text;
    }

    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length)
    );
  }
}