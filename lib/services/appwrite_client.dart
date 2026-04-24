import 'package:appwrite/appwrite.dart';
import '../config/app_config.dart';

class AppwriteClient {
  static final AppwriteClient _instance = AppwriteClient._internal();
  factory AppwriteClient() => _instance;

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final Realtime realtime;

  AppwriteClient._internal() {
    client = Client()
        .setEndpoint(AppConfig.appwriteEndpoint)
        .setProject(AppConfig.appwriteProjectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }

  String get databaseId => AppConfig.appwriteDatabaseId;
  String get bucketId => AppConfig.appwriteDocumentsBucketId;
}
