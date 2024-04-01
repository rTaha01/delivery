class DeliveryData {
  final String name;
  final String phone;
  final String address;
  final String price;
  final String paymentStatus;
  final String additionalInfo;
  final String orderNO;

  DeliveryData({
    required this.orderNO,
    required this.name,
    required this.phone,
    required this.address,
    required this.price,
    required this.paymentStatus,
    required this.additionalInfo,
  });
}
