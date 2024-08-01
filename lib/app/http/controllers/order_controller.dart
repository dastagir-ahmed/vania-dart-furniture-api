import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/order.dart';
import 'package:vania_furniture_api/app/models/order_detail.dart';
import 'package:vania_furniture_api/app/models/product_bin.dart';
import 'package:http/http.dart' as http;

class OrderController extends Controller {
  Future<Response> placeOrder(Request request) async {
    try {
      final userId = Auth().id();

      //json format data "id":1, "address":"shanghai"
      final data = request.input("order");

      if (data == null) {
        return Response.json(
            {"code": 401, "data": "", "msg": "You are not authorized"}, 401);
      }

      //Map format data id:1, address:shanghai
      // final cartList = jsonDecode(data);
      final cartList = data;
      var dataList = <ProductBin>[];
      for (var element in cartList) {
        dataList.add(ProductBin.fromJson(element));
      }

      final orderNum = DateTime.now().millisecondsSinceEpoch;
      double amountTotal = 0;

      final String apiKey = "stripe secret key";
      final Uri url = Uri.https('api.stripe.com', '/v1/checkout/sessions');

      final Map<String, String> body = {
        'payment_methods_types[]': 'card',
        'mode': 'payment',
        'success_url': env('APP_URL') + '/success.html',
        'cancel_url': env('APP_URL') + '/cancel.html',
        'metadata[order_id]': "${orderNum}"
      };

      for (int i = 0; i < dataList.length; i++) {
        final element = dataList.elementAt(i);
        final price = Decimal.parse(element.price!);
        //12.30
        var priceDouble = price.floor(scale: 2).toDouble();
        //1230 send to stripe
        final priceInt = (priceDouble * 100).toInt();
        //keep for ourself in the database
        var amountSum = priceDouble * element.cartNumber!;
        // total amount for all the items in the cart
        amountTotal = amountTotal + amountSum;

        body.addAll({
          'line_items[$i][price_data][currency]': 'usd',
          'line_items[$i][price_data][product_data][name]': '${element.title}',
          'line_items[$i][price_data][unit_price]': priceInt.toString(),
          'line_items[$i][quantity]': element.cartNumber.toString(),
        });

        await OrderDetail().query().insert({
          "user_id": userId,
          "amount": amountSum,
          "order_num": orderNum,
          "product_id": element.id,
          "title": element.title,
          "price": element.price,
          "num": element.cartNumber,
          "pic": element.thumbnail,
          "created_at": DateTime.now(),
          "updated_at": DateTime.now(),
        });
      }

      await Order().query().insert({
        "user_id": userId,
        "amount_total": amountTotal.toStringAsFixed(2),
        "order_num": orderNum,
        "created_at": DateTime.now(),
        "updated_at": DateTime.now(),
      });

      final response = await http.post(url,headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: body
      );

      if(response.statusCode == 200){
        final session = json.decode(response.body);
        print('Checkout session url: ${session['url']}');
        return Response.json({
          "code":200,
          "data":session['id'],
          "msg":"Payment successfull"
        });
      }else{
        print('Checkout session failed');
        return Response.json({
          "code":response.statusCode,
          "data":"",
          "msg":"Payment successfull"
        },response.statusCode,);
      }

     // return Response.json({"code": 200, "data": "", "msg": "Payment success"});
    } catch (e) {
      return Response.json({"code": 500, "data": "", "msg": e.toString()}, 500);
    }
  }

  Future<Response> webhook(Request request) {
    //print("0");
    final event = request.all();
    //print("1 ${event}");
    print(event);
    if (event['type'] == 'checkout.session.completed') {
      print("2");
      final session = event['data']['object'];
      final orderId = session['metadata']['order_id'];
      Order().query().where("order_num", orderId).update({"status": 1});
      print("3");
      return Response.json("Payment success");
    }
    print("4");
    return Response.json("Unknown events");
  }
}

final OrderController orderController = OrderController();
