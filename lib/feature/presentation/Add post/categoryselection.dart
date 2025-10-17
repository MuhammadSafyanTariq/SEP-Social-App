import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Add%20post/polladd.dart';
import 'package:sep/feature/presentation/controller/createpost/createpost_ctrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import '../../../components/styles/app_strings.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/Createpost/getcategory_model.dart';
import 'CreatePost.dart';

class CategorySelection extends StatefulWidget {
  final bool isPoll;
  const CategorySelection({super.key, this.isPoll = false});

  @override
  State<CategorySelection> createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  int _selectedIndex = -1;

  // bool isLoading = true;
  Categories? selectedCategory;

  // Helper function to capitalize category names
  String _getCategoryDisplayName(String? categoryName) {
    if (categoryName == null) return 'No Category Available';
    // Map "Politics" to "Perception" for display
    if (categoryName == 'Politics') return 'Perception';

    // Capitalize category names that start with lowercase
    if (categoryName.isNotEmpty &&
        categoryName[0].toLowerCase() == categoryName[0]) {
      return categoryName[0].toUpperCase() + categoryName.substring(1);
    }

    return categoryName;
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      await CreatePostCtrl.find.getPostCategories().applyLoaderWithOption(
        CreatePostCtrl.find.getCategories.isEmpty,
      );
    } catch (e) {
      AppUtils.log("Error fetching categories: $e");
    }
  }

  void _handleSubmit() {
    if (_selectedIndex == -1 || CreatePostCtrl.find.getCategories.isEmpty) {
      AppUtils.toastError("Please select a category");
      return;
    }

    selectedCategory = CreatePostCtrl.find.getCategories[_selectedIndex];

    AppUtils.log("Selected Category: ${selectedCategory?.id}");

    // context.pushNavigator(widget.isPoll ? AddPoll(categoryid: selectedCategory!.id.toString()) :
    //     CreatePost(categoryid: selectedCategory!.id.toString()));
    //
    context.pushNavigator(
      widget.isPoll
          ? AddPoll()
          : CreatePost(categoryid: selectedCategory!.id.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: widget.isPoll
          ? AppBar(
              centerTitle: true,

              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.black,
              leading: null,

              title: TextView(text: "", style: 20.txtBoldWhite),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => CreatePostCtrl.find.getCategories.isEmpty
              ? const Center(child: Text("No categories available"))
              : Column(
                  children: [
                    ...CreatePostCtrl.find.getCategories.asMap().entries.map((
                      entry,
                    ) {
                      int index = entry.key;
                      Categories category = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            selectedCategory = category;
                          });
                          AppUtils.log("Selected category ID: ${category.id}");
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? Colors.black
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedIndex == index
                                  ? Colors.green
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: TextView(
                              text: _getCategoryDisplayName(category.name),
                              style: _selectedIndex == index
                                  ? 16.txtCategory
                                  : 16.txtMediumBlack,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    AppButton(
                      buttonColor: AppColors.btnColor,
                      labelStyle: 17.txtRegularWhite,
                      margin: 32.horizontal + 50.vertical,
                      label: AppStrings.next.tr,
                      onTap: _handleSubmit,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
