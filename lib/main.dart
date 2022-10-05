import 'package:flutter/material.dart';
import 'package:livraria/pages/alugueis/alugueis.dart';
import 'package:livraria/pages/editoras/editoras.dart';
import 'package:livraria/pages/home_page/home_page.dart';
import 'package:livraria/pages/livros/livros.dart';
import 'package:livraria/pages/usuarios/usuarios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livraria WDA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Livraria WDA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, this.pageId = 2}) : super(key: key);
  final String title;
  final int pageId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.pageId;
  }

  List<Widget>pages = const[
    usuariosPage(),
    editoras(),
    home_page(),
    livros(),
    alugueis(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(_currentIndex!=2){
          setState(() {
            _currentIndex=2;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Color(0xff306BAC),
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.grey.withOpacity(0.8),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap:(int newIndex){
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              label: 'usuarios',
              icon: Icon(Icons.person),
            ),
            BottomNavigationBarItem(
              label: 'editoras',
              icon: Icon(Icons.apartment_outlined),
            ),
            BottomNavigationBarItem(
              label: 'home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'livros',
              icon: Icon(Icons.menu_book_outlined),
            ),
            BottomNavigationBarItem(
              label: 'aluguel',
              icon: Icon(Icons.add_chart),
            ),
          ],
        ),
      ),
    );
  }
}
