import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/soda_repository.dart';
import 'data/services/local_storage_service.dart';
import 'ui/features/tracker/view_models/tracker_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge full-screen system UI on iOS & Android
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final LocalStorageService storageService = LocalStorageService(prefs);
  final SodaRepository repository = SodaRepository(storageService);

  runApp(
    ChangeNotifierProvider<TrackerViewModel>(
      create: (_) => TrackerViewModel(repository: repository),
      child: const JamalsAddictionApp(),
    ),
  );
}
