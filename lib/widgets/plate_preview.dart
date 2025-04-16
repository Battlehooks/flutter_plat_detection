import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:plat_number_detection/database/mobil_db.dart';
import 'package:plat_number_detection/models/data_mobil.dart';
import 'package:plat_number_detection/page/add_edit_plate.dart';
import 'package:plat_number_detection/theme.dart';

class PlatePreview extends StatelessWidget {
  const PlatePreview(
      {super.key, required this.dataMobil, required this.callBackFunction});
  final DataMobil dataMobil;
  final callBackFunction;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().format(dataMobil.timestamp);
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 6),
      height: 150,
      // width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEditPlate(mobil: dataMobil)));
          callBackFunction();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: dataMobil.image.startsWith('https://')
                      ? Image.network(
                          dataMobil.image,
                          width: 161,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Image.file(File(dataMobil.image),
                          width: 161, height: 90, fit: BoxFit.cover),
                ),
                const SizedBox(
                  width: 24.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dataMobil.platDaerah} ${dataMobil.platNomor} ${dataMobil.platRegional}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      time.toString(),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w200),
                    )
                  ],
                )
              ],
            ),
            Row(
              children: [
                GestureDetector(
                    onTap: () async {
                      await MobilDatabase.instance.deleteDataById(dataMobil.id!);
                      callBackFunction();
                    },
                    child: const Icon(Icons.delete, color: primaryColor))
              ],
            )
          ],
        ),
      ),
    );
  }
}
