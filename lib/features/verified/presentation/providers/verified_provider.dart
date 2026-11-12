import 'package:flutter/foundation.dart';
import '../../domain/entities/verified_navigation_entity.dart';
import '../../domain/usecases/get_verified_destination_usecase.dart';

class VerifiedProvider extends ChangeNotifier {
  final GetVerifiedDestinationUseCase getVerifiedDestinationUseCase;

  VerifiedProvider({required this.getVerifiedDestinationUseCase});

  VerifiedNavigationEntity getDestination(bool navigateToProfile) {
    return getVerifiedDestinationUseCase(navigateToProfile);
  }
}
