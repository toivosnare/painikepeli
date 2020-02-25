import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

// A page where user can earn point by pressing a button
class GamePage extends StatefulWidget {

  final String serverAddress;
  final String username;

  GamePage({this.serverAddress, this.username});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  int score = 0;
  IOWebSocketChannel channel;
  bool loading = true;
  String tapsUntilPrize = '';
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>(); // To get a reference to widget scaffold

  @override
  void initState() {
    super.initState();
    initChannel();
  }

  // Tries to initialize connection to server
  void initChannel() async {
    try {
      channel = IOWebSocketChannel(await WebSocket.connect('ws://' + widget.serverAddress).timeout(Duration(seconds: 5)));
      setState(() {
        loading = false;
      });
      sendMessage('join');
      channel.stream.listen(receiveMessage); // Register message receive callback
    } catch(e) {
      print(e);
      Navigator.pop(context, true); // Return to home page with error status
    }
  }

  // Sends a message via a websocket tagged with user's identifier
  void sendMessage(String action) {
    channel.sink.add(jsonEncode({
      'action' : action,
      'player' : widget.username,
    }));
  }

  // Decodes received message and performs needed actions
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

  // Updates UI score text
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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to home page
              },
            ),
            FlatButton(
              child: Text('Kyllä'),
              onPressed: () {
                sendMessage('reset');
                Navigator.pop(context); // Close dialog
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
      // Show progress indicator if loading
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