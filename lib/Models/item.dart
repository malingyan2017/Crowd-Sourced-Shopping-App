class Item {

  String itemId;
  int barcode;
  String name;
  String pictureUrl;
  List<String> tags = [];

  Item(
    {
      this.itemId,
      this.barcode, 
      this.name,  
      this.pictureUrl,
      this.tags
    }
  );
}