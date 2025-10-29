//
// import 'package:juurususer/utils/preferencesUtils.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// import '../../../utils/app_utils.dart';
//
// enum SocketEvents { joinRoom, chatMessage,
//   updateDriverStatus,driverAssignedSuccess,
//   driverRidesResponse,response, driverStatusUpdate }
//
// // updateDriverStatus
//
// class SocketKeys{
//   static const String roomId = 'roomId';
//   static const String message = 'message';
//   static const String statusType = 'statusType';
//   static const String coordinates = 'coordinates';
//   static const String rideId = 'rideId';
//   static const String previousRideStatus = 'previousStatus';
//   static const String speed = 'speed';
//
//
// }
//
// class SocketHelper {
//   String connectUrl;
//   late IO.Socket socket;
//
//   SocketHelper({required this.connectUrl});
//
//   void connect(Function() onConnection) {
//     AppUtils.log(Preferences.authToken);
//     socket = IO.io(connectUrl, <String, dynamic>{
//       'autoConnect': false,
//       'transports': ['websocket'],
//     });
//     socket.io.options?['extraHeaders'] = {
//       'Authorization': Preferences.authToken
//     };
//     socket.connect();
//     socket.onConnect((_) {
//       print('Connection established');
//       onConnection();
//     });
//     socket.onDisconnect((_) => print('Connection Disconnection'));
//     socket.onConnectError((err) => print(err));
//     socket.onError((err) => print(err));
//   }
//
//
//   void joinRoomEvent(String roomId) => callEvent(SocketEvents.joinRoom, {SocketKeys.roomId: roomId});
//
//   callEvent(SocketEvents event, dynamic data){
//     socket.emit(event.name,data);
//   }
//
//   listen(SocketEvents event,dynamic Function(dynamic) handler) async {
//     socket.on(event.name, handler);
//   }
//
//   bool hasListener(SocketEvents event)=>  socket.hasListeners(event.name);
// }
//
