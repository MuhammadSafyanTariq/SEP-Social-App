 import 'package:sep/feature/data/models/dataModels/product_data_model/product_data_model.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/apiMethods.dart';
import '../../domain/respository/product_repository.dart';

class IProductRepository implements ProductRepository{
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<List<ProductDataModel>> getProducts({String search = '', int page = 1}) async{
    final result = await _apiMethod.get(url: Urls.getProducts,query: {
      'search': search,
      'page': '$page'
    });
    if(result.isSuccess){
      final list = result.data?['data']?['data'] ??[];
      return List<ProductDataModel>.from(list.map((json)=> ProductDataModel.fromJson(json)));
    }else{
      throw result.getError!;
    }
  }



}