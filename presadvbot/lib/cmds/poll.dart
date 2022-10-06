import 'dart:convert';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:presadvbot/config.dart';
import 'package:presadvbot/managers/env.dart';
import 'package:presadvbot/managers/rest.dart';

final poll = SlashCommandBuilder("poll", "Poll something", [partyPoll, end]);

final end = CommandOptionBuilder(
    CommandOptionType.subCommandGroup, "end", "Ends a poll.",
    options: [endPartyPoll]);

final endPartyPoll = CommandOptionBuilder(
    CommandOptionType.subCommand, "party", "End a party poll.",
    options: [
      CommandOptionBuilder(CommandOptionType.string, "party_acronym",
          "Acronym of the polling party.",
          required: true)
    ])
  ..registerHandler((event) async {
    try {
      Map<String, dynamic> jsonMap = {
        "party": event.getArg("party_acronym").value,
        "key": Environment.getValue("DB_ACCESS_KEY")
      };

      final uri = Uri.parse("$restUrl/endPoll");

      Map<String, dynamic>? poll =
          await restPost(uri, jsonMap, "No running poll.", event);

      if (poll == null) return;

      final channels = event.interaction.guild!.getFromCache()!.channels;

      final channel = channels
              .firstWhere((element) => element.toString() == poll["channel"])
          as ITextGuildChannel;

      final msg = await channel
          .fetchMessage(Snowflake.value(int.parse(poll["message"])));

      Map<int, int> votes = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
      };

      for (int i = 0; i < msg.reactions.length; i++) {
        votes[i + 1] = msg.reactions[i].count - 1;
      }

      EmbedBuilder embed = EmbedBuilder();
      embed.addAuthor((author) {
        author.name = event.interaction.memberAuthor?.nickname ??
            event.interaction.userAuthor?.username;
        author.iconUrl = event.interaction.memberAuthor?.avatarURL() ??
            event.interaction.userAuthor?.avatarURL();
      });

      embed.title = poll["question"];
      for (int i = 0; i < poll["options"].length; i++) {
        embed.addField(
            name: poll["options"][i], content: votes[i + 1].toString());
      }

      await event.respond(MessageBuilder.embed(embed));
    } catch (ex) {
      await event.respond(MessageBuilder.content(
          "There has been an error, contact <@532297642559012884> with the steps to recreate it."));
    }
  });

final partyPoll = CommandOptionBuilder(
    CommandOptionType.subCommand, "party", "Poll something for your party.",
    options: [
      CommandOptionBuilder(
          CommandOptionType.string, "party_acronym", "The party acronym.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "question", "The question to ask.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_one", "The first option.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_two", "The second option.",
          required: true),
      CommandOptionBuilder(
          CommandOptionType.string, "option_three", "The third option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_four", "The fourth option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_five", "The fifth option.",
          required: false),
      CommandOptionBuilder(
          CommandOptionType.string, "option_six", "The sixth option.",
          required: false),
    ])
  ..registerHandler((event) async {
    try {
      final Uri uri =
          Uri.parse("$restUrl/getParty/${event.getArg("party_acronym").value}");

      Map<String, dynamic>? party =
          await restGet(uri, "Non-existent party.", event);

      if (party == null) {
        return;
      }

      var perm = event.interaction.memberAuthorPermissions;

      if ((perm != null &&
              perm.hasPermission(PermissionsConstants.administrator)) ||
          event.interaction.userAuthor?.id.id.toString() == party["leader"]) {
        final guild = event.interaction.guild!.getFromCache();
        final channel = guild!.channels
            .singleWhere((element) => element.id == party["channel"]);

        EmbedBuilder embed = EmbedBuilder();
        embed.addAuthor((author) {
          author.name = event.interaction.memberAuthor?.nickname ??
              event.interaction.userAuthor?.username;
          author.iconUrl = event.interaction.memberAuthor?.avatarURL() ??
              event.interaction.userAuthor?.avatarURL();
        });
        embed.title = event.getArg("question").value as String;
        embed.addField(
            name: "Option 1", content: event.getArg("option_one").value);
        embed.addField(
            name: "Option 2", content: event.getArg("option_two").value);
        try {
          embed.addField(
              name: "Option 3", content: event.getArg("option_three").value);
        } catch (exception) {}
        try {
          embed.addField(
              name: "Option 4", content: event.getArg("option_four").value);
        } catch (exception) {}
        try {
          embed.addField(
              name: "Option 5", content: event.getArg("option_five").value);
        } catch (exception) {}
        try {
          embed.addField(
              name: "Option 6", content: event.getArg("option_six").value);
        } catch (exception) {}

        final msg = await (channel as ITextGuildChannel)
            .sendMessage(MessageBuilder.embed(embed));

        List<String> options = [];
        options.add(event.getArg("option_one").value);
        options.add(event.getArg("option_two").value);

        await msg.createReaction(UnicodeEmoji('1️⃣'));
        await msg.createReaction(UnicodeEmoji('2️⃣'));
        try {
          event.getArg("option_three");
          options.add(event.getArg("option_three").value);
          await msg.createReaction(UnicodeEmoji('3️⃣'));
        } catch (exception) {}
        try {
          event.getArg("option_four");
          options.add(event.getArg("option_four").value);
          await msg.createReaction(UnicodeEmoji('4️⃣'));
        } catch (exception) {}
        try {
          event.getArg("option_five");
          options.add(event.getArg("option_five").value);
          await msg.createReaction(UnicodeEmoji('5️⃣'));
        } catch (exception) {}
        try {
          event.getArg("option_six");
          options.add(event.getArg("option_six").value);
          await msg.createReaction(UnicodeEmoji('6️⃣'));
        } catch (exception) {}

        await event.respond(
            MessageBuilder.content("Created poll in <#${party["channel"]}>."));

        Map<String, dynamic> jsonMap = {
          "party": event.getArg("party_acronym").value,
          "channel": channel.toString(),
          "message": msg.toString(),
          "question": event.getArg("question").value,
          "options": options,
          "key": Environment.getValue("DB_ACCESS_KEY")
        };

        final uri = Uri.parse("$restUrl/startPoll");

        await restPostStr(
            uri, jsonMap, "Poll creation failed internally.", event,
            followUp: true);

        return;
      }

      await event.respond(
          MessageBuilder.content("You are not the leader of the party."));
    } catch (ex) {
      await event.respond(MessageBuilder.content(
          "There has been an error, contact <@532297642559012884> with the steps to recreate it."));
    }
  });
