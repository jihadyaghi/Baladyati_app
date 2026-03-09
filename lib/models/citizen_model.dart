class CitizenModel {
    final int id;
    final String firstname;
    final String lastname;
    final String phone;
    final String? zone;
    final bool isverified;
    final String? memberSince;
    const CitizenModel({
        required this.id,
        required this.firstname,
        required this.lastname,
        required this.phone,
        this.zone,
        required this.isverified,
        this.memberSince
    });
    String get fullName => '$firstname $lastname';
    factory CitizenModel.fromJson(Map<String, dynamic> json){
        return CitizenModel(
            id: json['id'] as int,
            firstname: json['firstName'] as String,
            lastname: json['lastName'] as String,
            phone: json['phone'] as String,
            zone: json['zone'] as String?,
            isverified: json['isVerified'] as bool? ?? false,
            memberSince: json['memberSince'] as String?
            );
    }
    Map<String, dynamic> toJson()=>{
        'id':id,
        'firstName':firstname,
        'lastName':lastname,
        'phone':phone,
        'zone':zone,
        'isVerified':isverified,
        'memberSince':memberSince
    };
}
//hyda object ymasel l citizen li byji mn API(backend)
//yaani hyda l file ymasel chakel l citizen jwa l app