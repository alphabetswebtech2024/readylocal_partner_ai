class DocumentUrlsEntity {
  String? profilePic;
  String? aadharPicFront;
  String? aadharPicBack;
  String? panPics;
  String? toolPhoto;
  String? addressProof;
  String? qualificationCert;
  String? experienceCert;
  String? selfie;
  String? drivingLicense;
  String? rc;
  String? policeCert;
  String? certificate;
  String? salonCert;
  List<String> workPhotos;
  List<String> workMedia;

  DocumentUrlsEntity({
    this.profilePic,
    this.aadharPicFront,
    this.aadharPicBack,
    this.panPics,
    this.toolPhoto,
    this.addressProof,
    this.qualificationCert,
    this.experienceCert,
    this.selfie,
    this.drivingLicense,
    this.rc,
    this.policeCert,
    this.certificate,
    this.salonCert,
    List<String>? workPhotos,
    List<String>? workMedia,
  })  : workPhotos = workPhotos ?? [],
        workMedia = workMedia ?? [];
}
