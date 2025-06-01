class ContactModel {
  final String uid;
  final String fullName;
  final String message;
  final String time;
  final String profilePicture;
  final int unreadCount;

  ContactModel({
    required this.uid,
    required this.fullName,
    required this.message,
    required this.time,
    required this.profilePicture,
    required this.unreadCount,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? 'Unknown',
      message: map['message'] ?? '',
      time: map['time'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'message': message,
      'time': time,
      'profilePicture': profilePicture,
      'unreadCount': unreadCount,
    };
  }
}
