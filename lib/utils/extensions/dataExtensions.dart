// import 'package:kioski/components/constants.dart';
// import 'package:kioski/feature/domain/entities/dataEntities/chatItemDataEntity.dart';
//
// import '../../feature/presentation/controller/postPropertyCtrl.dart';

import '../../components/constants.dart';

extension userRoleExtn on UserRole{
  String get getId{
    if(this == UserRole.Agent){
      return 'agent';
    }else if (this == UserRole.Builder){
      return 'builder';
    }else{
      return 'buyer';
    }
  }
}

// extension propertyTypeExtn on PropertyTypeEnum?{
//
// }


// extension getMsgType on String{
//   ChatMessageType get chatMsgType{
//     if(ChatMessageType.property.name == this){
//       return ChatMessageType.property;
//     }else if(ChatMessageType.image.name == this){
//       return ChatMessageType.image;
//     }else{
//       return ChatMessageType.text;
//     }
//   }
// }


// extension propertyTypeString on String?{
//   PropertyTypeEnum? get getPropertyType{
//     if(ListClass.propertyTypeList[0].idString?.toLowerCase() == this?.toLowerCase()){
//       return PropertyTypeEnum.Residential;
//     }else if(ListClass.propertyTypeList[1].idString?.toLowerCase() == this?.toLowerCase()){
//       return PropertyTypeEnum.Commercial;
//   }else{
//       return null;
//   }
//   }
// }

extension MapExt<T,V> on Map<T,V>{
  Map<T,V> get removeNullValues {
  removeWhere((key, value) => value == null);
  return this;
  }

  Map<T,V> merge(Map? value){
    if(value == null ){
      return this;
    }else{
      return {
        ...this,
        ...value
      };
    }
  }
}
