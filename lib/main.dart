import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setSize(Size(350, 450));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider()..loadSettings(),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return MaterialApp(
            title: 'Chat App',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: chatProvider.backgroundColor,
            ),
            home: ChatScreen(),
          );
        },
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  List<Map<String, String>> messages = [
    {
      "role": "system",
      "content":
          "你是一个简洁的助理，回答问题请尽量简短，避免过于冗长."
    }
  ];
  String apiKey = "";
  String apiUrl = "";
  String model = "";
  String? errorMessage;
  bool isAlwaysOnTop = false;

  Color backgroundColor = Colors.white;
  Color userBubbleColor = Colors.blueAccent;
  Color aiBubbleColor = Colors.grey[300]!;

  Future<void> sendMessage(String message) async {
  if (message.isEmpty) return;

  print("API URL: $apiUrl");
  print("API Key: ${apiKey.isNotEmpty ? '********' : 'Missing API Key'}");
  print("Model: $model");

  if (apiKey.isEmpty || apiUrl.isEmpty || model.isEmpty) {
    errorMessage = "API Key, URL, 或 Model 未输入.";
    notifyListeners();
    return;
  }

  messages.add({"role": "user", "content": message});
  notifyListeners();

  messages.add({"role": "assistant", "content": ""});
  int aiMessageIndex = messages.length - 1;
  notifyListeners();

  // 🚀 **自动适配 OpenAI / 阿里云兼容模式**
  Map<String, dynamic> requestBody;
  if (apiUrl.contains("openai.com") || apiUrl.contains("dashscope.aliyuncs.com/compatible-mode")) {
    // **OpenAI 兼容 API**
    requestBody = {
      "model": model,
      "messages": [
        {"role": "system", "content": "You are a concise assistant."},
        {"role": "user", "content": message}
      ],
      "temperature": 0.3
    };
  } else {
    // **阿里云 DashScope 原生 API**
    requestBody = {
      "model": model,
      "input": {"prompt": message},
      "parameters": {"temperature": 0.3}
    };
  }

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        errorMessage = "Empty response from API.";
      } else {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        print("Decoded API Response: $decodedResponse");

        // 🚀 **自动解析不同 API 返回格式**
        final chatResponse = decodedResponse["output"]?["text"] ??
            decodedResponse["choices"]?[0]?["message"]?["content"];

        if (chatResponse != null) {
          messages[aiMessageIndex]["content"] = chatResponse;
          errorMessage = null;
        } else {
          errorMessage = "Invalid API response format.";
        }
      }
    } else {
      errorMessage = "Error: ${response.statusCode} - ${response.body}";
      print("Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    errorMessage = "Network Error: $e";
    print("Network Error: $e");
  }
  notifyListeners();
  }

  void clearChat() {
    messages.clear();
    notifyListeners();
  }

  void toggleAlwaysOnTop() {
    isAlwaysOnTop = !isAlwaysOnTop;
    windowManager.setAlwaysOnTop(isAlwaysOnTop);
    notifyListeners();
  }

  void updateTheme(Color bg, Color userBubble, Color aiBubble) {
    backgroundColor = bg;
    userBubbleColor = userBubble;
    aiBubbleColor = aiBubble;
    notifyListeners();
  }

  bool isDark(Color color) {
    return (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) < 128;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('apiUrl', apiUrl);
    await prefs.setString('model', model);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('apiKey') ?? "";
    apiUrl = prefs.getString('apiUrl') ?? "";
    model = prefs.getString('model') ?? "";
    notifyListeners();
  }
}

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController apiKeyController;
  late TextEditingController apiUrlController;
  late TextEditingController modelController;

  @override
  void initState() {
    super.initState();
    var chatProvider = context.read<ChatProvider>();
    apiKeyController = TextEditingController(text: chatProvider.apiKey);
    apiUrlController = TextEditingController(text: chatProvider.apiUrl);
    modelController = TextEditingController(text: chatProvider.model);
  }

  @override
  Widget build(BuildContext context) {
    var chatProvider = context.read<ChatProvider>();
    return AlertDialog(
      title: Text("API Settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: apiKeyController,
            decoration: InputDecoration(labelText: "API Key"),
          ),
          TextField(
            controller: apiUrlController,
            decoration: InputDecoration(labelText: "API URL"),
          ),
          TextField(
            controller: modelController,
            decoration: InputDecoration(labelText: "Model"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            chatProvider.apiKey = apiKeyController.text.trim();
            chatProvider.apiUrl = apiUrlController.text.trim();
            chatProvider.model = modelController.text.trim();
            chatProvider.saveSettings();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}


class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var chatProvider = context.watch<ChatProvider>();
    bool isDarkBackground = chatProvider.isDark(chatProvider.backgroundColor);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: chatProvider.backgroundColor,
        title: Text('Easy Work',
            style: TextStyle(
                color: isDarkBackground ? Colors.white : Colors.black)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
              height: 1, color: isDarkBackground ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens,
                color: isDarkBackground ? Colors.white : Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ThemeDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings,
                color: isDarkBackground ? Colors.white : Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SettingsDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.push_pin,
                color: chatProvider.isAlwaysOnTop ? Colors.red : Colors.grey),
            onPressed: () => chatProvider.toggleAlwaysOnTop(),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => chatProvider.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (chatProvider.errorMessage != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                chatProvider.errorMessage!,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                bool isUser = chatProvider.messages[index]["role"] == "user";
                Color bubbleColor = isUser
                    ? chatProvider.userBubbleColor
                    : chatProvider.aiBubbleColor;
                bool isDarkBubble = chatProvider.isDark(bubbleColor);
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      chatProvider.messages[index]["content"]!,
                      style: TextStyle(
                          color: isDarkBubble ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: chatProvider.backgroundColor,
                      hintStyle: TextStyle(
                          color:
                              isDarkBackground ? Colors.white : Colors.black),
                    ),
                    style: TextStyle(
                        color: isDarkBackground ? Colors.white : Colors.black),
                    onSubmitted: (value) {
                      chatProvider.sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    chatProvider.sendMessage(_controller.text);
                    _controller.clear();
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chatProvider = context.read<ChatProvider>();

    return AlertDialog(
      title: Text("Customize Theme"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              chatProvider.updateTheme(
                  Colors.black, Colors.green, Colors.purple);
              Navigator.pop(context);
            },
            child: Text("Dark Theme"),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.updateTheme(
                  Colors.white, Colors.blueAccent, Colors.grey[300]!);
              Navigator.pop(context);
            },
            child: Text("Light Theme"),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => RGBColorPickerDialog(),
              );
            },
            child: Text("Custom RGB"),
          ),
        ],
      ),
    );
  }
}

class RGBColorPickerDialog extends StatefulWidget {
  @override
  _RGBColorPickerDialogState createState() => _RGBColorPickerDialogState();
}

class _RGBColorPickerDialogState extends State<RGBColorPickerDialog> {
  double bgRed = 255, bgGreen = 255, bgBlue = 255;
  double userRed = 0, userGreen = 122, userBlue = 255;
  double aiRed = 200, aiGreen = 200, aiBlue = 200;

  @override
  Widget build(BuildContext context) {
    var chatProvider = context.read<ChatProvider>();

    return AlertDialog(
      title: Text("Custom RGB Theme"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildColorSliders("Background Color", (r, g, b) {
              setState(() {
                bgRed = r;
                bgGreen = g;
                bgBlue = b;
              });
              chatProvider.updateTheme(
                Color.fromRGBO(
                    bgRed.toInt(), bgGreen.toInt(), bgBlue.toInt(), 1),
                chatProvider.userBubbleColor,
                chatProvider.aiBubbleColor,
              );
            }, bgRed, bgGreen, bgBlue),
            _buildColorSliders("User Chat Bubble", (r, g, b) {
              setState(() {
                userRed = r;
                userGreen = g;
                userBlue = b;
              });
              chatProvider.updateTheme(
                chatProvider.backgroundColor,
                Color.fromRGBO(
                    userRed.toInt(), userGreen.toInt(), userBlue.toInt(), 1),
                chatProvider.aiBubbleColor,
              );
            }, userRed, userGreen, userBlue),
            _buildColorSliders("AI Chat Bubble", (r, g, b) {
              setState(() {
                aiRed = r;
                aiGreen = g;
                aiBlue = b;
              });
              chatProvider.updateTheme(
                chatProvider.backgroundColor,
                chatProvider.userBubbleColor,
                Color.fromRGBO(
                    aiRed.toInt(), aiGreen.toInt(), aiBlue.toInt(), 1),
              );
            }, aiRed, aiGreen, aiBlue),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Done"),
        ),
      ],
    );
  }

  Widget _buildColorSliders(
      String title,
      Function(double, double, double) onChange,
      double red,
      double green,
      double blue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: red,
                min: 0,
                max: 255,
                activeColor: Colors.red,
                onChanged: (value) {
                  onChange(value, green, blue);
                },
              ),
            ),
            Text("${red.toInt()}"),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: green,
                min: 0,
                max: 255,
                activeColor: Colors.green,
                onChanged: (value) {
                  onChange(red, value, blue);
                },
              ),
            ),
            Text("${green.toInt()}"),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: blue,
                min: 0,
                max: 255,
                activeColor: Colors.blue,
                onChanged: (value) {
                  onChange(red, green, value);
                },
              ),
            ),
            Text("${blue.toInt()}"),
          ],
        ),
      ],
    );
  }
}
