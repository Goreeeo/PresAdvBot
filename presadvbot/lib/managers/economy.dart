import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/config.dart';
import 'package:presadvbot/managers/env.dart';
import 'package:presadvbot/managers/rest.dart';

Future<void> addMoney(
    String user, int amount, ISlashCommandInteractionEvent event) async {
  setMoney(user, await getMoney(user, event) + amount, event);
}

Future<void> setMoney(
    String user, int amount, ISlashCommandInteractionEvent event) async {
  Map<String, dynamic> jsonMap = {
    "user": user,
    "money": amount,
    "key": Environment.getValue("DB_ACCESS_KEY")
  };

  await restPostStr(
      Uri.parse("$restUrl/setMoney"), jsonMap, "Error adding money.", event);
}

Future<int> getMoney(String user, ISlashCommandInteractionEvent event) async {
  dynamic money = await restGetStr(
      Uri.parse("$restUrl/getMoney/$user"), "Error getting money.", event);

  return int.parse(money);
}
