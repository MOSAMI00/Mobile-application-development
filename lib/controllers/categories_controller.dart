import '../models/category.dart';
import '../services/database_service.dart';

class CategoriesController {
  final _db = DatabaseService.I;

  Future<List<CategoryModel>> listCategories({bool? enabled}) =>
      _db.getCategories(enabled: enabled);

  Future<int> addCategorie(String name) =>
      _db.createCategory(CategoryModel(name: name));

  //Future<int> toggle(int id, bool enabled) => _db.toggleCategory(id, enabled);
}
