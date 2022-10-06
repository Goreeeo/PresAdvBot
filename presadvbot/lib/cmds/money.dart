import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/managers/economy.dart';

final money = SlashCommandBuilder(
    "money", "Does something with money.", [moneySet, moneyAdd, moneyRemove],
    requiredPermissions: PermissionsConstants.administrator);

final moneySet = CommandOptionBuilder(
    CommandOptionType.subCommand, "set", "Sets a users money.",
    options: [
      CommandOptionBuilder(
          CommandOptionType.user, "user", "The user to change the money of.",
          required: true),
      CommandOptionBuilder(CommandOptionType.integer, "money", "The amount.",
          required: true)
    ])
  ..registerHandler((event) async {
    await setMoney(
        event.getArg("user").value, event.getArg("money").value, event);
    await event.respond(MessageBuilder.content(
        "Set <@${event.getArg("user").value}>'s money to ${event.getArg("money").value} dollars."));
  });

final moneyAdd = CommandOptionBuilder(
    CommandOptionType.subCommand, "add", "Adds to a users money.",
    options: [
      CommandOptionBuilder(
          CommandOptionType.user, "user", "The user to change the money of.",
          required: true),
      CommandOptionBuilder(CommandOptionType.integer, "money", "The amount.",
          required: true)
    ])
  ..registerHandler((event) async {
    await addMoney(
        event.getArg("user").value, event.getArg("money").value, event);
    await event.respond(MessageBuilder.content(
        "<@${event.getArg("user").value}>'s money is now ${await getMoney(event.getArg("user").value, event)} dollars."));
  });

final moneyRemove = CommandOptionBuilder(
    CommandOptionType.subCommand, "remove", "Removes from a users money.",
    options: [
      CommandOptionBuilder(
          CommandOptionType.user, "user", "The user to change the money of.",
          required: true),
      CommandOptionBuilder(CommandOptionType.integer, "money", "The amount.",
          required: true)
    ])
  ..registerHandler((event) async {
    await addMoney(
        event.getArg("user").value, -event.getArg("money").value, event);
    await event.respond(MessageBuilder.content(
        "<@${event.getArg("user").value}>'s money is now ${await getMoney(event.getArg("user").value, event)} dollars."));
  });

final economy = SlashCommandBuilder(
    "economy", "Get the status of the economy.", [moneyGet]);

final moneyGet = CommandOptionBuilder(
    CommandOptionType.subCommand, "get", "Gets a users money.", options: [
  CommandOptionBuilder(CommandOptionType.user, "user", "The user.")
])
  ..registerHandler((event) async {
    int money = await getMoney(event.getArg("user").value, event);
    await event.respond(MessageBuilder.content(
        "<@${event.getArg("user")}>'s money is $money dollars."));
  });
