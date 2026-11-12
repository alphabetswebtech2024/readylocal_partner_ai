// Every list here uses the exact format captured from the live server on
// 2026-11-06. The fake-format tests before this hid a Select Service failure.
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/network/api_client.dart';
import 'package:gotask_partner/core/network/api_service.dart';
import 'package:gotask_partner/core/network/catalog_cache.dart';
import 'package:gotask_partner/features/driver_setup/data/datasources/driver_setup_remote_datasource.dart';
import 'package:gotask_partner/features/medical_setup/data/datasources/medical_setup_remote_datasource.dart';
import 'package:gotask_partner/features/pandit_setup/data/datasources/pandit_setup_remote_datasource.dart';
import 'package:gotask_partner/features/select_categories/data/datasources/select_categories_remote_datasource.dart';
import 'package:gotask_partner/features/select_service/data/datasources/select_service_remote_datasource.dart';
import 'package:gotask_partner/features/withdraw/data/datasources/withdraw_remote_datasource.dart';

class _Client implements ApiClient {
  _Client(this.dio);
  @override
  final Dio dio;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers by API name and records what was sent.
ApiService server(Map<String, dynamic> replies, Map<String, dynamic> sent) {
  final dio = Dio(BaseOptions(baseUrl: 'https://x.test/prod/'))
    ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      final name = o.path.substring(o.path.lastIndexOf('/') + 1);
      sent[name] = o.data is String ? jsonDecode(o.data as String) : o.data;
      h.resolve(Response(requestOptions: o, statusCode: 200, data: replies[name]));
    }));
  return ApiService(_Client(dio));
}

void main() {
  setUp(CatalogCache.clear);

  test('Select Service shows active modules in server order', () async {
    final source = SelectServiceRemoteDataSourceImpl(server({
      'getModules': {
        'Status': 'SUCCESS',
        'StatusCode': 200,
        'modules': [
          {'_id': 'p', 'Code': 'PUROHIT', 'Name': 'Pandit / Purohit', 'Icon': 'https://x/p.png', 'Order': 6, 'isActive': true, 'has_category': true},
          {'_id': 'h', 'Code': 'HS', 'Name': 'Home Services', 'Icon': 'https://x/h.png', 'Order': 1, 'isActive': true, 'has_category': false},
          {'_id': 'o', 'Code': 'OLD', 'Name': 'Old', 'Order': 2, 'isActive': false},
        ],
      },
    }, {}));
    final list = await source.getModules();
    expect(list.map((m) => m.moduleCode), ['HS', 'PUROHIT']);
    expect(list.first.title, 'Home Services');
    expect(list.first.image, 'https://x/h.png');
    expect(list.first.hasCategory, isFalse);
    expect(list.last.hasCategory, isTrue);
  });

  test('Select Service reports a failed response so Retry appears', () async {
    final source = SelectServiceRemoteDataSourceImpl(server({
      'getModules': {'Status': 'FAILED', 'Message': 'Down'},
    }, {}));
    expect(source.getModules(), throwsA(isA<Exception>()));
  });

  test('categories flow sends the real names and reads the real lists', () async {
    final sent = <String, dynamic>{};
    final source = SelectCategoriesRemoteDataSourceImpl(server({
      'getCategories': {'categories': [{'_id': 'c', 'Name': 'Cat', 'isActive': true}, {'_id': 'x', 'Name': 'Off', 'isActive': false}]},
      'getSubCategoriesNew': {'subCategories': [{'_id': 's', 'Name': 'Sub', 'isActive': true, 'has_service_types': false}]},
      'getServiceTypesNew': {'ServiceTypes': [{'_id': 't', 'Name': 'Type', 'isActive': true}]},
      'getServicesNew': {'Status': 'SUCCESS', 'StatusCode': '200', 'Services': [{'_id': 'v', 'Name': 'Svc', 'isActive': true, 'price': '250'}]},
      'getPersonalCareServices': {'data': [{'SubCategoryID': 's', 'services': [{'_id': 'a', 'Name': 'Facial', 'isActive': true}, {'_id': 'b', 'Name': 'Off', 'isActive': false}]}]},
    }, sent));

    final cats = await source.getCategories('m');
    expect(cats.map((c) => c.name), ['Cat']);
    expect(sent['getCategories'], {'ModuleID': 'm'});

    final subs = await source.getSubcategories('c', 'm', moduleName: 'Mod');
    expect(subs.single.toJson()['has_service_types'], isFalse);
    expect(sent['getSubCategoriesNew'], {'ModuleID': 'm', 'ModuleName': 'Mod', 'isActive': true, 'CategoryID': 'c'});

    await source.getSubcategories('', 'm');
    expect((sent['getSubCategoriesNew'] as Map).containsKey('CategoryID'), isFalse);

    final types = await source.getServiceTypes('m', subCategoryId: 's');
    expect(types.single.name, 'Type');
    expect(sent['getServiceTypesNew'], {'ModuleID': 'm', 'SubCategoryID': 's', 'isActive': true});

    final services = await source.getServices('s', 'm', moduleName: 'Mod');
    expect(services.single.name, 'Svc');
    expect(services.single.price, 250);
    expect(sent['getServicesNew']['SubCategoryID'], 's');
    expect(sent['getServicesNew']['ModuleID'], 'm');

    final pc = await source.getPersonalCareServices('m', subCategoryIds: ['s', 's2']);
    expect(pc, hasLength(1));
    expect(pc.single['SubCategoryID'], 's');
    expect(sent['getPersonalCareServices'], {'ModuleID': 'm', 'SubCategoryID': 's,s2'});
  });

  test('Pandit services are flattened with their category', () async {
    final sent = <String, dynamic>{};
    final source = PanditSetupRemoteDataSourceImpl(server({
      'getPurohitServices': {'data': [{'CategoryID': 'c1', 'services': [{'_id': 'a', 'Name': 'Puja', 'isActive': true}]}]},
    }, sent));
    final list = await source.getServices('c1,c2', 'm');
    expect(list.single.categoryId, 'c1');
    expect(list.single.toJson()['CategoryID'], 'c1');
    expect(sent['getPurohitServices'], {'ModuleID': 'm', 'CategoryID': 'c1,c2'});
  });

  test('Medical services accept grouped and plain lists', () async {
    final row = {'_id': 'a', 'Name': 'Care', 'isActive': true};
    var source = MedicalSetupRemoteDataSourceImpl(server({
      'getServicesNew': {'data': [{'CategoryID': 'c1', 'services': [row]}]},
    }, {}));
    expect((await source.getServices('c1', 'm')).single.categoryId, 'c1');
    source = MedicalSetupRemoteDataSourceImpl(server({
      'getServicesNew': {'Services': [{...row, 'CategoryID': 'c9'}, {'_id': 'z', 'Name': 'Off', 'isActive': false}]},
    }, {}));
    expect((await source.getServices('c9', 'm')).single.categoryId, 'c9');
  });

  test('Driver setup loads its four separate lists', () async {
    final source = DriverSetupRemoteDataSourceImpl(server({
      'getDriverServiceTypes': {'driverServiceTypes': [{'_id': 's', 'Type': 'Hourly'}]},
      'getDriverLicenseTypes': {'drivigLicenseTypes': [{'_id': 'l', 'Type': 'LMV-NT', 'Description': 'Light'}]},
      'getVehicleTypes': {'vehicleTypes': [{'_id': 'v', 'Type': 'Manual Gare'}]},
      'getSafetySkills': {'safetySkills': [{'_id': 'k', 'Skill': 'Highway'}]},
    }, {}));
    final options = await source.getDriverSetupOptions();
    expect(options.serviceTypes.single.type, 'Hourly');
    expect(options.licenseTypes.single.description, 'Light');
    expect(options.vehicleTypes.single.type, 'Manual Gare');
    expect(options.safetySkills.single.skill, 'Highway');
  });

  test('bank list opens the string body', () async {
    final source = WithdrawRemoteDataSourceImpl(server({
      'listBankAccounts': {
        'statusCode': 200,
        'body': jsonEncode({'data': {'bankAccounts': [{'bankAccountId': 'b', 'bankName': 'SBI', 'accountName': 'A', 'accountNumber': '1', 'ifsc': 'I'}]}}),
      },
    }, {}));
    final list = await source.getBankAccounts('p');
    expect(list.single.bankName, 'SBI');
    expect(list.single.ifscCode, 'I');
  });

  test('translated text is never used as a field name sent to the server', () {
    final bad = <String>[];
    for (final file in Directory('lib/features').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final line in file.readAsLinesSync()) {
        if (RegExp(r'[{,]\s*context\.l10n\.\w+\s*:\s').hasMatch(line) ||
            RegExp(r'^\s*context\.l10n\.\w+\s*:\s*\w+,\s*$').hasMatch(line)) {
          bad.add('${file.path}: $line');
        }
      }
    }
    expect(bad, isEmpty);
  });
}
