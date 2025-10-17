//
// import 'package:bumbaja/feature/data/dataSource/remoteDataSource/authApiServices.dart';
// import 'package:get_it/get_it.dart';
//
// import '../../../feature/data/repository/iAuthRepository.dart';
// import '../../../feature/domain/respository/authRepository.dart';
//
// final sl = GetIt.I;
//
// void setupLocator() async{
//
//   final instance = sl.registerSingleton<ApiInstance>(ApiInstance.build());
//   sl.registerLazySingleton<AuthApiServices>(()=>AuthApiServices.create(instance.client));
//
//   //repository
//   sl.registerLazySingleton<AuthRepository>(() => IAuthRepository(),);
//
//
//   // // controllers
//   // sl.registerFactory<AuthCtrl>(() => AuthCtrl(sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl()),);
//   // sl.registerFactory<HomeCtrl>(() => HomeCtrl(sl(),sl(),sl()),);
//   // sl.registerFactory<BTabsCtrl>(() => BTabsCtrl(),);
//   // sl.registerFactory<LanguageCtrl>(() => LanguageCtrl(),);
//   // sl.registerFactory<PostPropertyCtrl>(() => PostPropertyCtrl(sl(),sl(),sl()),);
//   // sl.registerFactory<PropertyCtrl>(() => PropertyCtrl(sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl(),sl()),);
//   // sl.registerFactory<MyPostsCtrl>(() => MyPostsCtrl(),);
//   // sl.registerFactory<TeamCtrl>(() => TeamCtrl(sl(),sl(),sl(),sl(),sl()),);
//   // sl.registerFactory<ChatCtrl>(() => ChatCtrl(sl(),sl(),sl(),sl()),);
//   // sl.registerFactory<SettingsCtrl>(() => SettingsCtrl(sl()),);
//   //
//   // // useCases
//   // sl.registerLazySingleton<LoginUseCase>(()=>LoginUseCase(sl()));
//   // sl.registerLazySingleton<VerifyOtpUseCase>(()=>VerifyOtpUseCase(sl()));
//   // sl.registerLazySingleton<CreateAccountUseCase>(()=>CreateAccountUseCase(sl()));
//   // sl.registerLazySingleton<AgentRegisterUseCase>(()=>AgentRegisterUseCase(sl()));
//   // sl.registerLazySingleton<BuilderRegisterUseCase>(()=>BuilderRegisterUseCase(sl()));
//   // sl.registerLazySingleton<UploadImageVideoUseCase>(()=>UploadImageVideoUseCase(sl()));
//   // sl.registerLazySingleton<GetAddressByCordsUseCase>(()=>GetAddressByCordsUseCase(sl()));
//   // sl.registerLazySingleton<GetRawPostFormDataUseCase>(()=>GetRawPostFormDataUseCase(sl()));
//   // sl.registerLazySingleton<CreatePostRequestUseCase>(()=>CreatePostRequestUseCase(sl()));
//   // sl.registerLazySingleton<GetPostsUseCase>(()=>GetPostsUseCase(sl()));
//   // sl.registerLazySingleton<AddBookMarkUseCase>(()=>AddBookMarkUseCase(sl()));
//   // sl.registerLazySingleton<GetBookMarkListUseCase>(()=>GetBookMarkListUseCase(sl()));
//   // sl.registerLazySingleton<GetSinglePostUseCase>(()=>GetSinglePostUseCase(sl()));
//   // sl.registerLazySingleton<AddProjectUseCase>(()=>AddProjectUseCase(sl()));
//   // sl.registerLazySingleton<GetProjectsUseCase>(()=>GetProjectsUseCase(sl()));
//   // sl.registerLazySingleton<GetAutoCompleteAddressUseCase>(()=>GetAutoCompleteAddressUseCase(sl()));
//   // sl.registerLazySingleton<GetCordsByPlaceIdUseCase>(()=>GetCordsByPlaceIdUseCase(sl()));
//   // sl.registerLazySingleton<GetMyRequirementListUseCase>(()=>GetMyRequirementListUseCase(sl()));
//   //
//   // sl.registerLazySingleton<CreateTeamUseCase>(()=>CreateTeamUseCase(sl()));
//   // sl.registerLazySingleton<UpdateTeamUseCase>(()=>UpdateTeamUseCase(sl()));
//   // sl.registerLazySingleton<FetchTeamUseCase>(()=>FetchTeamUseCase(sl()));
//   // sl.registerLazySingleton<RemoveTeamUseCase>(()=>RemoveTeamUseCase(sl()));
//   // sl.registerLazySingleton<UpdateProfileUseCase>(()=>UpdateProfileUseCase(sl()));
//   // sl.registerLazySingleton<GetOtpOldPhoneNumberUseCase>(()=>GetOtpOldPhoneNumberUseCase(sl()));
//   // sl.registerLazySingleton<VerifyOldPhoneNumberUseCase>(()=>VerifyOldPhoneNumberUseCase(sl()));
//   // sl.registerLazySingleton<VerifyNewPhoneNumberUseCase>(()=>VerifyNewPhoneNumberUseCase(sl()));
//   //
//   // sl.registerLazySingleton<GetRecentChatUseCase>(()=>GetRecentChatUseCase(sl()));
//   // sl.registerLazySingleton<GetSingleChatUseCase>(()=>GetSingleChatUseCase(sl()));
//   // sl.registerLazySingleton<SendMessageUseCase>(()=>SendMessageUseCase(sl()));
//   // sl.registerLazySingleton<LeaveChatRoomUseCase>(()=>LeaveChatRoomUseCase(sl()));
//   // sl.registerLazySingleton<GetMyPropertiesListUseCase>(()=>GetMyPropertiesListUseCase(sl()));
//
//
//   //storage
//   // sl.registerLazySingleton<LocaleDataSource>(()=>ILocaleDataSource(sl()));
//   // sl.registerSingleton<Box<PostRequestEntity>>(postBox);
// }