import 'package:plat_number_detection/database/mobil_db.dart';

Future<void> killSwitch() async {
  await MobilDatabase.instance.deleteAllRecords();
}

main() async {
  await killSwitch();
}
