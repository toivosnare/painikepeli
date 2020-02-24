import 'package:client/game_page.dart';
import 'package:flutter/material.dart';

// A page where user can input preferred username and server to connect to
class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _serverAddressTextController = TextEditingController(text: 'snare-painikepeli.herokuapp.com');
  TextEditingController _usernameTextController = TextEditingController(text: 'toivo'); // Default values
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>(); // To get a reference to widget scaffold

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => connect(),
        tooltip: 'Yhdistä',
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  // Pushes the game page on top and displays exit annotation if needed
  void connect() async {
    final result = await Navigator.push(context, MaterialPageRoute( // Pass user entered values to game page
      builder: (context) => GamePage(
        serverAddress: _serverAddressTextController.text,
        username: _usernameTextController.text,
      )
    ));
    if(result != null) { // If game page exited with error status
      scaffoldState.currentState
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