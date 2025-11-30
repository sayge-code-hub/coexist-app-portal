class AppConfigModel {
  final String id;
  final String key;
  final String? value;
  final String? title;
  final String? message;
  final String? buttonAction;
  final String? buttonText;

  const AppConfigModel({
    required this.id,
    required this.key,
    this.value,
    this.title,
    this.message,
    this.buttonAction,
    this.buttonText,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      buttonAction: json['button_action'] as String?,
      buttonText: json['button_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'title': title,
      'message': message,
      'button_action': buttonAction,
      'button_text': buttonText,
    };
  }

  bool get isEnabled => value?.toLowerCase() == 'true';

  @override
  String toString() {
    return 'AppConfigModel(id: $id, key: $key, value: $value, title: $title, message: $message, buttonAction: $buttonAction, buttonText: $buttonText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfigModel &&
        other.id == id &&
        other.key == key &&
        other.value == value &&
        other.title == title &&
        other.message == message &&
        other.buttonAction == buttonAction &&
        other.buttonText == buttonText;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        key.hashCode ^
        value.hashCode ^
        title.hashCode ^
        message.hashCode ^
        buttonAction.hashCode ^
        buttonText.hashCode;
  }
}
