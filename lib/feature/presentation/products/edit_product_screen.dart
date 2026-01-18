import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/products/widgets/product_edit_form.dart';

class EditProductScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic>? productData;

  const EditProductScreen({Key? key, required this.productId, this.productData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            AppBar2(
              title: "Edit Product",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
              backgroundColor: AppColors.white,
              hasTopSafe: true,
            ),

            // Edit Form
            Expanded(
              child: ProductEditForm(
                productId: productId,
                productData: productData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
