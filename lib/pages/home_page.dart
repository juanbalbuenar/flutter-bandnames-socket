import 'dart:io';

import 'package:bandapp/models/band.dart';
import 'package:bandapp/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
   // Band(id: '1',name: 'Metallica', votes: 5),
   // Band(id: '2',name: 'Queen', votes: 1),
   // Band(id: '3',name: 'Heroes del Silencio', votes: 2),
   // Band(id: '4',name: 'Bon Jovi', votes: 5),
  ];

  @override
  void initState() {

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List)
      .map( (banda) => Band.fromMap(banda) )
      .toList(); 
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('BandNames', style: TextStyle(color:Colors.black87) ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: ( socketService.serverStatus == ServerStatus.Online )
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red),

          )
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
          future: _showGraph(),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if( !snapshot.hasData ){
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data;
              }
            },
          ),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>  _bandTile(bands[index])
            ),
          ),
          
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewBand,
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
          key: Key( band.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            socketService.socket.emit('delete-band', { 'id': band.id } );
          },
          background: Container(
            padding: EdgeInsets.only(left: 8.0),
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Delete Band', style: TextStyle(color: Colors.white),)
              ),
          ),
          child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0,2) ),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text('${band.votes}', style: TextStyle(fontSize: 20.0),),
          onTap: () {
            socketService.socket.emit('vote-band', { 'id': band.id });
          },
        ),
    );
  }
  addNewBand() {

    final textController = new TextEditingController();

    if(Platform.isAndroid) {
        return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
               onPressed: () => addBandToList(textController.text),
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Add'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
      );
  }

    

  void addBandToList( String name ) {
    final socketService = Provider.of<SocketService>(context,listen: false);
    if( name.length > 1 ) {
      socketService.socket.emit('add-band', {'name': name});
      
    }

    Navigator.pop(context);
  }

  Future<Widget> _showGraph() async {
    Map<String, double> dataMap = {};
    if( bands.isNotEmpty ){
      await Future.forEach(bands, ( band )=> dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));
      return PieChart(dataMap: dataMap);
    } else {
      return null;
    }
  }
}