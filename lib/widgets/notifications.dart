import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
Future<void> deleteDocumentByField(String collectionName, String fieldName, dynamic value) async {
  try {
    // Realizar una consulta para obtener el documento que coincide con el campo y valor proporcionados
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where(fieldName, isEqualTo: value)
        .get();

    // Verificar si se encontró algún documento
    if (querySnapshot.docs.isNotEmpty) {
      // Obtener el identificador del primer documento encontrado
      String documentId = querySnapshot.docs.first.id;

      // Eliminar el documento utilizando su identificador
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .delete();
    } else {
      print('No se encontró ningún documento con el campo $fieldName igual a $value');
    }
  } catch (e) {
    print('Error al eliminar el documento: $e');
  }
}
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late TextEditingController _modalController;
  List<Map<String, dynamic>> articles = [];

  @override
  void initState() {
    super.initState();
    _modalController = TextEditingController();
    getArticles().then((result) {
      setState(() {
        articles = result;
      });
    });
  }

  @override
  void dispose() {
    _modalController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> getArticles() async {
    List<Map<String, dynamic>> articles = [];
    CollectionReference collectionReferenceArticles = db.collection('calculations');
    QuerySnapshot queryArticles = await collectionReferenceArticles.get();
    articles = queryArticles.docs.map((DocumentSnapshot doc) {
      Timestamp timestamp = doc['timestamp'] ?? Timestamp(0, 0);
      DateTime dateTime = timestamp.toDate();
      
      return {
        'area': doc['area'] ?? '',
        'timestamp': dateTime,
        'id': doc['id'] ?? ''
      };
    }).toList();
    print(articles);
    return articles;
  }

  Future<void> deleteArea(int index) async {
    String areaId = articles[index]['id'];
    print(areaId);
    await deleteDocumentByField('calculations', 'id', areaId);
    setState(() {
      articles.removeAt(index);
    });
  }

  // Método para mostrar el modal
  void _showMapModal(String area) {
    // Agrega la lógica para mostrar el modal con el mapa correspondiente a 'area'
    // Puedes utilizar paquetes como 'google_maps_flutter' para integrar mapas en Flutter
    // Aquí un ejemplo sencillo usando un AlertDialog
    String areaTitle = area.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mapa de $areaTitle'),
          content: Text('Aquí puedes mostrar el mapa correspondiente a $areaTitle'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
        backgroundColor: const Color(0xFF171821),
      ),
      body: Center(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Area')),
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Timestamp')),
            DataColumn(label: Text('Actions')),
          ],
          rows: articles.map<DataRow>((article) {
            return DataRow(
              cells: [
                DataCell(Text('${article['area']}')),
                DataCell(Text('${article['id']}')),
                DataCell(Text('${article['timestamp']}')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteArea(articles.indexOf(article));
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Text('Contenido del Modal'),
                            );
                          },
                        );
                      },
                      child: Text('Mapa'),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: NotificationPage(),
  ));
}
