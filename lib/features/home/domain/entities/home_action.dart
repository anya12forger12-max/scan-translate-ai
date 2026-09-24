import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class HomeAction extends Equatable {
  final String label;
  final IconData icon;
  final Color color;
  final String? route;

  const HomeAction({required this.label, required this.icon, required this.color, this.route});

  @override List<Object?> get props => [label, icon, color, route];
}
