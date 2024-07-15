import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/wishlist.dart';

class ProfileController extends Controller {
  Future<Response> addWishList(Request request) async {
    try {
      final id = request.input("id");

      if (id == null) {
        return Response.json(
            {"code": 401, "data": "", "msg": "Not authorized"}, 401);
      }

      final userId = Auth().id();

      final wishlist = await Wishlist()
          .query()
          .where("user_id", "=", userId)
          .where("product_id", "=", id)
          .first();

      //cancel the item from the wish list
      if (wishlist != null) {
        await Wishlist()
            .query()
            .where("product_id", "=", id)
            .where("user_id", "=", userId)
            .delete();
        return Response.json({
          "code": 200,
          "data": "",
          "msg": "Wishlist canceled for this product"
        }, 200);
      }

      await Wishlist().query().insert({
        "user_id": userId,
        "product_id": id,
        "created_at": DateTime.now(),
        "updated_at": DateTime.now()
      });

      return Response.json(
          {"code": 200, "data": "", "msg": "Wishlist added for this product"},
          200);
    } catch (e) {
      return Response.json({
        "code": 500,
        "data": "",
        "msg": "Something wrong went with the wish list"
      }, 500);
    }
  }

  Future<Response> myWishList(Request request) async {
    try {
      final userId = Auth().id();
      final wishList = await Wishlist()
          .query()
          .join('products', 'products.id', '=', 'wishlists.product_id')
          .select(['products.*'])
          .where('wishlists.user_id', '=', userId)
          .get();

      return Response.json(
          {"code": 200, "data": wishList, "msg": "Returned  wishlist"}, 500);
    } catch (e) {
      return Response.json(
          {"code": 500, "data": "", "msg": "Could not return a wishlist"}, 500);
    }
  }
}

final ProfileController profileController = ProfileController();
