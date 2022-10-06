import "package:nyxx/nyxx.dart";
import 'package:nyxx_commands/nyxx_commands.dart';
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:dotenv/dotenv.dart";

import "package:presadvbot/cmds/commands.dart";

import "dart:io";

import 'package:presadvbot/managers/env.dart';

void main() {
  final bot = NyxxFactory.createNyxxWebsocket(Environment.getValue("BOT_TOKEN"),
      GatewayIntents.allUnprivileged | GatewayIntents.guildMembers);
  bot
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions());

  IInteractions.create(WebsocketInteractionBackend(bot))
    ..registerSlashCommand(register)
    ..registerSlashCommand(party)
    ..registerSlashCommand(poll)
    ..registerSlashCommand(money)
    ..registerSlashCommand(economy)
    ..syncOnReady();

  bot.connect();

  ProcessSignal.sigint.watch().listen((signal) {
    exit(0);
  });
}
