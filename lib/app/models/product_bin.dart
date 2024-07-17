class ProductBin {
  int? id;
  String? title;
  String? thumbnail;
  String? description;
  int? categoryId;
  String? price;
  int? review;
  int? cartNumber;
  double? score;
  bool? isWishlist;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  ProductBin(
      {this.id,
        this.title,
        this.thumbnail,
        this.description,
        this.categoryId,
        this.price,
        this.review,
        this.cartNumber,
        this.score,
        this.isWishlist,
        this.createdAt,
        this.updatedAt,
        this.deletedAt});

  ProductBin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    description = json['description'];
    categoryId = json['category_id'];
    price = json['price'];
    review = json['review'];
    cartNumber = json['cart_number'];
    score = json['score'];
    isWishlist = json['is_wishlist'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['thumbnail'] = this.thumbnail;
    data['description'] = this.description;
    data['category_id'] = this.categoryId;
    data['price'] = this.price;
    data['review'] = this.review;
    data['cart_number'] = this.cartNumber;
    data['score'] = this.score;
    data['is_wishlist'] = this.isWishlist;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}