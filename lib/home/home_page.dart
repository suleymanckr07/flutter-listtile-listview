import 'package:flutter/material.dart';
import 'package:scapp/model/list_model.dart';
import 'package:scapp/model/model.dart';

import '../data/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseHelper dbHelper; // dbHelper değişkenini tanımlama

  final ListModeli listModeli = ListModeli();

  @override
  void initState() {
    dbHelper = DatabaseHelper(); // dbHelper değişkenini başlatma
    super.initState();
    _showAddPersonDialog(context);
    _showEditPersonDialog(context, Model());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List view & List tile'),
      ),
      body: FutureBuilder<List<Model>>(
        future: dbHelper.getPersons(),
        builder: (context, snapshot) {
          try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Kişi bulunamadı.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        snapshot.data![index].image ?? '',
                      ),
                    ),
                    title: Text(
                      snapshot.data![index].title ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(snapshot.data![index].description ?? ''),
                    onTap: () {
                      setState(() {
                        _showEditPersonDialog(context, snapshot.data![index]);
                      });
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _showEditPersonDialog(context, snapshot.data![index]);
                        });
                      },
                    ),
                  );
                },
              );
            }
          } catch (error) {
            return Center(child: Text('Hata: $error'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade100,
        onPressed: () {
          setState(() {
            _showAddPersonDialog(context);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _showAddPersonDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController imageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bilgi Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                textInputAction: TextInputAction.next,
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
              ),
              TextField(
                textInputAction: TextInputAction.next,
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Resim URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    imageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Boş kaydedilemez!')),
                  );
                } else {
                  Model newModel = Model(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    description: descriptionController.text,
                    image: imageController.text,
                  );
                  DatabaseHelper dbHelper = DatabaseHelper();
                  await dbHelper.insertPerson(newModel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.blue,
                      content: Text('Veri eklendi!'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
                setState(() {});
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  _showEditPersonDialog(BuildContext context, Model model) async {
    TextEditingController titleController =
        TextEditingController(text: model.title);
    TextEditingController descriptionController =
        TextEditingController(text: model.description);
    TextEditingController imageController =
        TextEditingController(text: model.image);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bilgi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                textInputAction: TextInputAction.next,
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
              ),
              TextField(
                textInputAction: TextInputAction.next,
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Resim URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper();
                await dbHelper.deletePerson(model.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.purple,
                        content: Text('Veri başarıyla silindi!')),
                  );
                setState(
                    () {}); // Ekranda anında güncelleme yapmak için setState kullanılıyor
                Navigator.of(context).pop();
              },
              child: const Text('Sil'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    imageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Boş kaydedilemez!')),
                  );
                } else {
                  Model updatedModel = Model(
                    id: model
                        .id, // Burada model nesnesinin id'sini kullanıyoruz.
                    title: titleController.text,
                    description: descriptionController.text,
                    image: imageController.text,
                  );
                  if (updatedModel.id != null) {
                    DatabaseHelper dbHelper = DatabaseHelper();
                    await (dbHelper).updatePerson(updatedModel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            'Veri başarıyla güncellendi',
                            style: TextStyle(fontSize: 14),
                          )),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Geçersiz kişi ID!')),
                    );
                  }
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }
}
