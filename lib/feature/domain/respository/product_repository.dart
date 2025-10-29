import 'package:sep/feature/data/models/dataModels/product_data_model/product_data_model.dart';

abstract class ProductRepository{
  Future<List<ProductDataModel>> getProducts({String search = '', int page = 1});
}