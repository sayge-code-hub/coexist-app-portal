class CustomerCareConfig {
  final String? number;
  final String? email;

  CustomerCareConfig({this.number, this.email});

  factory CustomerCareConfig.fromList(List<dynamic> data) {
    String? number;
    String? email;

    for (final item in data) {
      if (item['key'] == 'customer_care_number') {
        number = item['value'] as String?;
      } else if (item['key'] == 'customer_care_email') {
        email = item['value'] as String?;
      }
    }

    return CustomerCareConfig(number: number, email: email);
  }
}
