import 'package:equatable/equatable.dart';

class StatesModel extends Equatable{
  final String? state;
  final List<String>? list;

  const StatesModel({required this.state, required this.list});
  @override
  List<Object?> get props => [state, list];

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
    state: json["state"],
    list: json["cities"],
  );

  Map<String, dynamic> toJson() => {
    "state": state,
    "cities": list
  };

}