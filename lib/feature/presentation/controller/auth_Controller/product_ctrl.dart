import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/product_data_model/product_data_model.dart';
import 'package:sep/feature/data/repository/i_product_repository.dart';
import 'package:sep/feature/domain/respository/product_repository.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

class ProductCtrl extends GetxController{
  static get find => Get.add<ProductCtrl>(()=>ProductCtrl());

  final ProductRepository _repo = IProductRepository();

  RxList<ProductDataModel> productListing = RxList([]);

  Future getProducts({
    String search = '',
    int page = 1,
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async{
    int pageNo = page;
    if(isRefresh) pageNo = 1;
    if(isLoadMore) pageNo = pageNo + 1;


    try{
      final result = await _repo.getProducts(
          page: pageNo,
          search: search
      );
      if(result.isNotEmpty){
        page = pageNo;
      }
      if(pageNo == 1){
        productListing.assignAll(result);
      }else{
        productListing.addAll(result);
      }
      productListing.refresh();

    }catch(e){
      AppUtils.toastError(e);
    }

  }
}