import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_screen.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  bool _isDeviceOn = false;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    getUsers().then((people) {
      setState(() {
        users = people;
      });
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    List<Map<String, dynamic>> users = [];
    CollectionReference collectionReferenceUsers = db.collection('user');
    QuerySnapshot queryUsers = await collectionReferenceUsers.get();
    users = queryUsers.docs.map((DocumentSnapshot doc) {
      return {
        'uid': doc['uid'] ?? '',
        'name': doc['name'] ?? '',
        'email': doc['email'] ?? '',
        'latitud': doc['latitud'] ?? '',
        'longitud': doc['longitud'] ?? '',
        'isActive': doc['isActive'] ?? false,
        'imageUrl': doc['imageUrl'] ?? '',
        'mobileNumber': doc['mobileNumber'] ?? '',
        'userType': doc['userType'] ?? '',
      };
    }).toList();
    print(users);
    return users;
  }

  void _toggleDevicePower() {
    setState(() {
      _isDeviceOn = !_isDeviceOn;
    });
    // Implementa la lógica para enviar comandos de encendido/apagado al dispositivo remoto
  }

  void _onButtonPressed(String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(buttonText: action),
      ),
    );
  }

  void _toggleUserActiveStatus(int index) async {
    setState(() {
      users[index]['isActive'] = !users[index]['isActive'];
    });

    // Actualiza el estado activo/inactivo del usuario en la base de datos
    await db.collection('user').doc(users[index]['uid']).update({
      'isActive': users[index]['isActive'],
    });
  }

  void _deleteUser(int index) async {
    // Lógica para eliminar el usuario
    await db.collection('user').doc(users[index]['uid']).delete();
    setState(() {
      users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width * 0.25;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            const SizedBox(height: 20),
            // Renderiza la lista de usuarios
            for (var i = 0; i < users.length; i++)
              ListTile(
                title: Text(users[i]['name'] ?? ''),
                subtitle: Text(users[i]['email'] ?? ''),
                // Agrega botones de acciones (por ejemplo, editar o eliminar) según sea necesario
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteUser(i),
                    ),
                    ElevatedButton(
                      onPressed: () => _toggleUserActiveStatus(i),
                      child:
                          Text(users[i]['isActive'] ? 'Desactivar' : 'Activar'),
                    ),
                  ],
                ),
              ),
            // ... Puedes agregar más usuarios aquí
          ],
        ),
      ),
    );
  }
}
