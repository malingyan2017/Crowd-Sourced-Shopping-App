class ListItem {

  String listItemId;
  String itemId;
  String barcode;
  String name;
  String pictureUrl;
  int quantity;

  ListItem(
    {
      this.listItemId,
      this.itemId,
      this.barcode, 
      this.name,  
      this.pictureUrl,
      this.quantity
    }
  );
}