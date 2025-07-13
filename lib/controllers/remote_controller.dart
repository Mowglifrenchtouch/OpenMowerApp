import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_mower_app/controllers/settings_controller.dart';
import 'package:open_mower_app/io/mqtt_connection.dart';
import 'package:open_mower_app/models/joystick_command.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemoteController extends GetxController {
  final SettingsController settingsController = Get.find();
  final MqttConnection _mqttConnection = Get.find();

  WebSocketChannel? channel;
  final joystickCommand = const JoystickCommand(0, 0, 0, 0).obs;

  @override
  void onInit() {
    super.onInit();

    // Mise à jour régulière du message joystick
    interval(joystickCommand, (cmd) {
      sendMessage(cmd);
    }, time: const Duration(milliseconds: 20));

    // for safety, if joystick command wasnt changed for some time, send a 0
    debounce(joystickCommand, (_) {
      sendMessage(const JoystickCommand(0, 0, 0, 0));
    }, time: const Duration(milliseconds: 100));

    // listen on hostname changes, then invalidate the channel
    ever(settingsController.hostname, (_) {
      debugPrint("settings changed, resetting websocket");
      channel = null;
    });
  }

  void connectWebsocket() {
    if (kIsWeb && kReleaseMode) {
      // Release and web, we can just connect to the root of the current URL
      channel = WebSocketChannel.connect(
        Uri.parse('ws://${Uri.base.host}:9002'),
      );
    } else {
      // Connect according to settings
      channel = WebSocketChannel.connect(
        Uri.parse('ws://${settingsController.hostname}:9002'),
      );
    }
  }

  void sendMessage(JoystickCommand cmd) {
    if (channel == null || channel?.closeCode != null) {
      // reconnect
      connectWebsocket();
    }
    if (channel != null) {
      final map = {"lx": cmd.lx, "ly": cmd.ly, "rx": cmd.rx, "ry": cmd.ry};
      final binary = BsonCodec.serialize(map);
      channel?.sink.add(binary.byteList);
    }
  }

  void callAction(String action) {
    _mqttConnection.callAction(action);
  }
}
