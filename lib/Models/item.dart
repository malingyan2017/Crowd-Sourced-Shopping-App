class ListItem {

  String itemId;
  String barcode;
  String name;
  String pictureUrl;
  List<String> tags = [];

  ListItem(
    {
      this.itemId,
      this.barcode, 
      this.name,  
      this.pictureUrl,
      this.tags
    }
  );
}