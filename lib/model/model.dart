// ignore_for_file: public_member_api_docs, sort_constructors_first
class Model {
  String? id;
  String? title;
  String? description;
  String? image;

  Model({this.id, this.title, this.description, this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
    };
  }
}
