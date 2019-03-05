import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

const String _name = "John Doe";
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light
);
final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400]
);

void main() => runApp(FrendlychatApp());

// FrendlychatApp Widget (never changes/stateless)
class FrendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Frendly Chat",
      theme: defaultTargetPlatform == TargetPlatform.iOS?
      kIOSTheme : kDefaultTheme,
      home: new ChatScreen(),
    );
  }
}

// ChatScreen Widget (changed when internal state changes/stateful)
class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Frendly Chat")),
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
            padding: new EdgeInsets.all(8),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          )),
          new Divider(
            height: 1,
          ),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose (){
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                onChanged: (String txt) {
                  setState((){
                    _isComposing = txt.length > 0;
                  });
                },
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing ?
                      () => _handleSubmitted(_textController.text):
                      null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String txt) {
    ChatMessage message = new ChatMessage(
      text: txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 700)),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});

  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16),
              child: new CircleAvatar(child: new Text(_name[0])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(_name, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: new Text(text),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
