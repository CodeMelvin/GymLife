import 'package:intl/intl.dart';

String formatRupiah(int amount) =>
    'Rp ${NumberFormat.decimalPattern().format(amount)}';
