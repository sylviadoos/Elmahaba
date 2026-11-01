import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.config.dart';

final GetIt getIt = GetIt.instance;

/// Regenerate after adding/removing @injectable classes:
/// `dart run build_runner build`
@InjectableInit()
Future<void> configureDependencies() =>
    getIt.init(environment: DataEnv.current);
