import 'package:intl/intl.dart';

class DateFormatters {
  static final DateFormat _headerFormatter = DateFormat('EEEE, MMM d');
  static final DateFormat _cardFormatter = DateFormat('MMM d');
  static final DateFormat _detailFormatter = DateFormat('MMMM d, y');
  static final DateFormat _formFormatter = DateFormat('MM/dd/yyyy');

  static String header(DateTime date) =>
      _headerFormatter.format(date).toUpperCase();
  static String card(DateTime date) =>
      _cardFormatter.format(date).toUpperCase();
  static String detail(DateTime date) => _detailFormatter.format(date);
  static String form(DateTime date) => _formFormatter.format(date);
}
