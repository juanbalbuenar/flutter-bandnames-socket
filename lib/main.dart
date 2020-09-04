import 'package:bandapp/pages/home_page.dart';
import 'package:bandapp/pages/status.dart';
import 'package:bandapp/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
void main() => runApp( BandApp());
 
class BandApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => SocketService() )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (BuildContext context) => HomePage(),
          'status': (BuildContext context) => StatusPage()
        },
      ),
    );
  }
}