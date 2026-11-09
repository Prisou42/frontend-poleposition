import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/drivers.dart';

class DriverRow extends StatelessWidget {
  final Driver driver;

  const DriverRow({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(driver.firstName),
      subtitle: Text(driver.lastName),
      trailing: Icon(driver.isFavorite ? Icons.star : Icons.star_border),
    );
  }
}