enum Flavor { free, paid }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.free:
        return 'MyApp Free';
      case Flavor.paid:
        return 'MyApp Paid';
    }
  }
}

extension FlavorExtension on Flavor {
  bool get isFree => this == Flavor.free;
  bool get isPaid => this == Flavor.paid;
}
