class Review {
  String id;
  String userId;
  int rating;
  DateTime dateCreated;
  String body;
  DateTime dateEdited;

  Review(
      {this.id,
      this.userId,
      this.rating,
      this.dateCreated,
      this.body,
      this.dateEdited});
}
