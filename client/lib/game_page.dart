import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class GamePage extends StatefulWidget {

  String serverAddress;
  String username;

  GamePage({this.serverAddress, this.username});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  int score = 0;
  IOWebSocketChannel channel;
  bool loading = true;
  String tapsUntilPrize = '';
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initChannel();
  }

  void initChannel() async {
    try {
      channel = IOWebSocketChannel(await WebSocket.connect('ws://' + widget.serverAddress).timeout(Duration(seconds: 5)));
      setState(() {
        loading = false;
      });
      sendMessage('join');
      channel.stream.listen(receiveMessage);
    } catch(e) {
      print(e);
      Navigator.pop(context, true);
    }
  }

  void sendMessage(String action) {
    channel.sink.add(jsonEncode({
      'action' : action,
      'player' : widget.username,
    }));
  }

  void receiveMessage(dynamic message) {
      dynamic decodedMessage = jsonDecode(message);
      switch(decodedMessage['action']) {
        case 'updateScore': {
            updateScore(decodedMessage['score']);
        }
        break;
        case 'tapResult': {
          updateScore(decodedMessage['newScore']);
          setState(() {
            tapsUntilPrize = 'Painalluksia seuraavaan voittoon: ${decodedMessage["tapsUntilPrize"]}';
          });
          int prize = decodedMessage['prize'];
          if(prize > 0) {
            scaffoldState.currentState
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Voitit $prize pistettä!')));
          }   
        }
        break;
        default: {
          print('Unknown response :(');
        }
        break;
      }
  }

  void updateScore(int newScore) {
    if(newScore > 0) {
      setState(() {
        score = newScore;
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Pisteesi loppuivat'),
          content: Text('Haluatko aloittaa alusta?'),
          actions: <Widget>[
            FlatButton(
              child: Text('En'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Kyllä'),
              onPressed: () {
                sendMessage('reset');
                Navigator.pop(context);
              },
            ),
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(title: Text(widget.serverAddress),),
      body: loading ? Center(child: CircularProgressIndicator()) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(tapsUntilPrize),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Paina'),
              onPressed: () => sendMessage('tap'),
            ),
            SizedBox(height: 10.0),
            Text('Pisteet: $score'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel?.sink?.close();
    super.dispose();
  }
}