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

      final String apiKey =
          "sk_test_51NDjUSDcNOyMHK5HXM82Vp9SmGNrUbu4wTpn4KsvytjoVxnJXo6243K262SqdHHypMIloirm1xSVEnqW0edTSH1N00h9q3RWf3";
      final Uri url = Uri.https('api.stripe.com', '/v1/checkout/sessions');

      final Map<String, String> body = {
        'payment_method_types[]': 'card',
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
          'line_items[$i][price_data][unit_amount]': priceInt.toString(),
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

      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: body);

      if (response.statusCode == 200) {
        final session = json.decode(response.body);
        print('Checkout session url: ${session['url']}');
        print('Checkout session id: ${session['id']}');
        return Response.json(
            {"code": 200, "data": session['id'], "msg": "Payment successfull"});
      } else {
        print('Checkout session failed');
        return Response.json(
          {
            "code": response.statusCode,
            "data": "",
            "msg": "Payment successfull"
          },
          response.statusCode,
        );
      }

      // return Response.json({"code": 200, "data": "", "msg": "Payment success"});
    } catch (e) {
      return Response.json({"code": 500, "data": "", "msg": e.toString()}, 500);
    }
  }

  //app-> post
  //app-> get
  //webook
  //app-> third party server -> register a hook (webhook)
  //there's a session
  //store data info
  //go back to stripe
  Future<Response> webhook(Request request) async {
    final event = request.all();
    if (event['type'] == 'checkout.session.completed') {
      final session = event['data']['object'];
      final orderId = session['metadata']['order_id'];
      print("Checkout session completed for order ID: $orderId");
      Order().query().where('order_num', orderId).update({'status': 1});
    }
    return Response.json('Event received');
  }

  Future<Response> getOrderList(Request request) async {
    final userId = Auth().id();
    final status = request.input('status');

    if (status == "canceled") {
      final orderList = await Order()
          .query()
          .where('user_id', "=", userId)
          .where("status", "=", 3)
          .get();

      return Response.json({
        "code": 200,
        "data": orderList,
        "msg": "Success returning the cancel order list"
      }, 200);
    } else if (status == "delivered") {
      final orderList = await Order()
          .query()
          .where('user_id', "=", userId)
          .where("status", "=", 2)
          .get();

      return Response.json({
        "code": 200,
        "data": orderList,
        "msg": "Success returning the delivered order list"
      }, 200);
    } else if (status == "paid") {
      final orderList =
          await Order().query().where('user_id', "=", userId).where("status","=",1).get();

      return Response.json({
        "code": 200,
        "data": orderList,
        "msg": "Success returning the order list"
      }, 200);
    } else if (status == "all") {
      final orderList =
          await Order().query().where('user_id', "=", userId).get();

      return Response.json({
        "code": 200,
        "data": orderList,
        "msg": "Success returning the order list"
      }, 200);
    }else{

        return Response.json({
        "code": 403,
        "data": [],
        "msg": "No matching found"
      }, 403);
    }

  }
}

final OrderController orderController = OrderController();
