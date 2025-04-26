import 'package:plat_number_detection/database/mobil_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> killSwitch() async {
  await MobilDatabase.instance.deleteAllRecords();
  await deleteDatabase(join(await getDatabasesPath(), 'platNomor.db'));
}

main() async {
  await killSwitch();
}
