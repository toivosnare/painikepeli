import 'package:client/game_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _serverAddressTextController = TextEditingController(text: 'snare-painikepeli.herokuapp.com');
  TextEditingController _usernameTextController = TextEditingController(text: 'toivo');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _serverAddressTextController,
              decoration: InputDecoration(labelText: 'Palvelimen osoite'),
            ),
            TextFormField(
              controller: _usernameTextController,
              decoration: InputDecoration(labelText: 'Käyttäjänimi'),
            )
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
          onPressed: () {
            connect(context);
          },
          tooltip: 'Yhdistä',
          child: Icon(Icons.arrow_forward),
        )
      )
    );
  }

  void connect(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => GamePage(
        serverAddress: _serverAddressTextController.text,
        username: _usernameTextController.text,
      )
    ));
    if(result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Yhteyden muodostaminen epäonnistui')));
    }
  }

  @override
  void dispose() {
    _serverAddressTextController.dispose();
    _usernameTextController.dispose();
    super.dispose();
  }
}