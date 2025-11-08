import 'package:uuid/uuid.dart';

class Generators {
  static String generatePaymentId() {
    var uuid = Uuid();
    return 'PAY-${uuid.v4()}';
  }
}
