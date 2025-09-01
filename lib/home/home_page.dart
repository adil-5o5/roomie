import 'package:flutter/material.dart';
import 'package:roomie/widgets/customappbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: "H O M E"));
  }
}
