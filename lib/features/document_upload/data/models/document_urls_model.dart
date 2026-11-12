import '../../domain/entities/document_urls_entity.dart';

class DocumentUrlsModel extends DocumentUrlsEntity {
  DocumentUrlsModel({
    super.profilePic,
    super.aadharPicFront,
    super.aadharPicBack,
    super.panPics,
    super.toolPhoto,
    super.addressProof,
    super.qualificationCert,
    super.experienceCert,
    super.selfie,
    super.drivingLicense,
    super.rc,
    super.policeCert,
    super.certificate,
    super.salonCert,
    super.workPhotos,
    super.workMedia,
  });

  factory DocumentUrlsModel.fromJson(Map<String, dynamic> json) {
    return DocumentUrlsModel(
      profilePic: json['ProfilePic']?.toString(),
      aadharPicFront: json['AadharPicFront']?.toString(),
      aadharPicBack: json['AadharPicBack']?.toString(),
      panPics: json['PanPics']?.toString(),
      toolPhoto: json['ToolPhoto']?.toString(),
      addressProof: json['AddressProof']?.toString(),
      qualificationCert: json['QualificationCertificate']?.toString(),
      experienceCert: json['ExperienceCertificate']?.toString(),
      selfie: json['Selfie']?.toString(),
      drivingLicense: json['DrivingLicense']?.toString(),
      rc: json['RC']?.toString(),
      policeCert: json['PoliceCert']?.toString(),
      certificate: json['Certificate']?.toString(),
      salonCert: json['SalonCert']?.toString(),
      workPhotos: (json['WorkPhotos'] as List?)?.map((e) => e.toString()).toList(),
      workMedia: (json['WorkMedia'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ProfilePic': profilePic ?? '',
    'AadharPicFront': aadharPicFront ?? '',
    'AadharPicBack': aadharPicBack ?? '',
    'PanPics': panPics ?? '',
    'ToolPhoto': toolPhoto ?? '',
    'AddressProof': addressProof ?? '',
    'QualificationCertificate': qualificationCert ?? '',
    'ExperienceCertificate': experienceCert ?? '',
    'Selfie': selfie ?? '',
    'DrivingLicense': drivingLicense ?? '',
    'RC': rc ?? '',
    'PoliceCert': policeCert ?? '',
    'Certificate': certificate ?? '',
    'SalonCert': salonCert ?? '',
    'WorkPhotos': workPhotos,
    'WorkMedia': workMedia,
  };
}
