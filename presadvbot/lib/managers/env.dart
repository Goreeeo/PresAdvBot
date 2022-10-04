import 'package:dotenv/dotenv.dart';

class Environment {
  static final env = DotEnv(includePlatformEnvironment: true)..load();

  static String getValue(String value) {
    return env[value] as String;
  }
}
