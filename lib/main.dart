import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_main.dart';
import 'flavors.dart';

void main() {
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );

  runApp(const MyApp());
}
