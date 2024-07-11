import 'dart:io';

import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/products.dart';

class HomeController extends Controller {
  //home page product list
 Future<Response> productList(Request request) async {
    try{
    final categoryId = request.input("id");
    //in this case -1 means get all the products

    if(categoryId == "-1"){
      final productList = await Products().query().get();
      return Response.json({
        "code":200,
        "data":productList,
        "msg":"Success getting all products list"
      },200);
    }

    final specificProductList = await Products().query().where("category_id", "=", categoryId).get();

    if(specificProductList.isNotEmpty){
      return Response.json({
        "code":200,
        "data":specificProductList,
        "msg":"Success getting a specific product list"
      }, 200);
    }else{
      return Response.json({
        "code":204,
        "data":"",
        "msg":"Nothing found in the database"
      }, 204);
    }

    }catch(e){
    return Response.json({
        "code":500,
        "data":"",
        "msg":"Error getting data"
      },500);
    }
  }


}

final HomeController homeController = HomeController();
