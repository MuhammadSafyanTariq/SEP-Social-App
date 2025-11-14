import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/address_model.dart';
import 'package:sep/feature/data/models/dataModels/poll_item_model/poll_item_model.dart';
import 'package:sep/feature/presentation/Home/homeScreen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../components/styles/app_strings.dart';
import '../../../services/storage/preferences.dart';
import '../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../controller/createpost/createpost_ctrl.dart';

class AddPoll extends StatefulWidget {
  const AddPoll({super.key});

  @override
  State<AddPoll> createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  RxList<PollItemModel> pollOptions = RxList([
    PollItemModel(),
    PollItemModel(),
  ]);
  late TextEditingController questionCtrl = TextEditingController();

  List<Categories> categories = [];
  Categories? selectedCategory;

  // Advertisement category tracking
  bool showAdvertisementWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => fetchCategories(),
    );
  }

  @override
  void dispose() {
    questionCtrl.dispose();
    super.dispose();
  }

  // final sDate = TextEditingController();
  // final eDate = TextEditingController();
  // final sTime = TextEditingController();
  // final eTime = TextEditingController();

  RxBool formState = RxBool(false);
  RxBool isAutoValidationMode = RxBool(false);

  bool get _optionValid {
    List<PollItemModel> list = [...pollOptions];
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].updatedValidity;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pollOptions.assignAll([...list]);
      pollOptions.refresh();
    });

    return areAllValid(list);
  }

  // Helper method to sort categories in the specified order
  List<Categories> _sortCategories(List<Categories> categories) {
    // Define the desired order
    const order = [
      'sports',
      'entertainment',
      'perception',
      'politics',
      'advertisement',
      'others',
      'other',
    ];

    return categories..sort((a, b) {
      final aName = a.name?.toLowerCase() ?? '';
      final bName = b.name?.toLowerCase() ?? '';

      final aIndex = order.indexOf(aName);
      final bIndex = order.indexOf(bName);

      // If both are in the order list, sort by their position
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only a is in the order list, it comes first
      if (aIndex != -1) return -1;

      // If only b is in the order list, it comes first
      if (bIndex != -1) return 1;

      // If neither is in the order list, sort alphabetically
      return aName.compareTo(bName);
    });
  }

  Future<void> fetchCategories() async {
    try {
      // Show a loading spinner or some kind of loader before fetching
      await CreatePostCtrl.find.getPostCategories().applyLoaderWithOption(
        CreatePostCtrl.find.getCategories.isEmpty,
      );

      // After fetching, check if categories list is empty or null and handle accordingly
      setState(() {
        categories = _sortCategories(
          CreatePostCtrl.find.getCategories.isNotEmpty
              ? CreatePostCtrl.find.getCategories
              : [],
        );
      });

      // Check the fetched categories (you can use logging to ensure correct data)
      AppUtils.log("Fetched Categories: ${categories.toString()}");
    } catch (e) {
      // Handle error during fetching
      AppUtils.log("Error fetching categories: $e");
    }
  }
  //
  // Rx<TimeOfDay?> startTime = Rx(null);
  // Rx<TimeOfDay?> endTime = Rx(null);
  // Rx<DateTime?> startDate = Rx(null);
  // Rx<DateTime?> endDate = Rx(null);

  final _form = GlobalKey<FormState>();

  bool areAllValid(List<PollItemModel> items) {
    final result = items.every((item) => item.updatedValidity.isValid == true);
    AppUtils.log('🔍 Poll Options Validation:');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final updated = item.updatedValidity;
      AppUtils.log(
        '  Option ${i + 1}: name="${item.name}", valid=${updated.isValid}',
      );
    }
    AppUtils.log('  All options valid: $result');
    return result;
  }

  void validDateForm() {
    formState.value = _form.currentState?.validate() ?? false;
  }

  bool get isValidForm {
    final formValid = formState.isTrue;
    final optionsValid = _optionValid;
    final result = formValid && optionsValid;

    AppUtils.log('🔍 Poll Form Validation:');
    AppUtils.log('  - Form State Valid: $formValid');
    AppUtils.log('  - Options Valid: $optionsValid');
    AppUtils.log('  - Overall Valid: $result');
    AppUtils.log('  - Selected Category: ${selectedCategory?.name}');
    AppUtils.log('  - Local Selected Category: ${localSelectedCategory?.name}');

    return result;
  }

  final List<Categories> _categories = [
    Categories(name: '24 hrs'),
    Categories(name: '48 hrs'),
    Categories(name: '72 hrs'),
    Categories(name: '96 hrs'),
    Categories(name: '120 hrs'),
  ];

  Categories? localSelectedCategory;

  // Check if category is advertisement related
  // Payment logic removed - advertisements are now free
  bool _isAdvertisementCategory(String? categoryName) {
    return false; // Always return false to bypass payment logic
  }

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

  Future<bool> _showAdvertisementPaymentDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.campaign, color: Colors.orange),
                  SizedBox(width: 8),
                  TextView(
                    text: "Advertisement Boost",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text:
                        "You're about to boost your poll as an advertisement.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: "• Cost: \$5.00 USD",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextView(
                          text: "• Duration: 24 hours boost",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextView(
                          text: "• Benefits: Higher visibility and reach",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: TextView(
                    text: "Cancel",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextView(
                    text: "Pay \$5 & Boost",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildAdvertisementWarning() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.orange.shade600, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: "Advertisement Category",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 4),
                TextView(
                  text:
                      "Selecting advertisement as category will charge you \$5 and your poll will be boosted for 24 hours",
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: TextView(
          text: "Poll",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: !isValidForm
                    ? () {
                        AppUtils.log(
                          '❌ Upload button tapped but form is not valid',
                        );
                        AppUtils.toastError(
                          'Please fill in all required fields',
                        );
                      }
                    : () async {
                        AppUtils.log('✅ Upload button tapped - form is valid');
                        validDateForm();
                        _optionValid;

                        if (!isValidForm || selectedCategory == null) {
                          AppUtils.toastError(
                            'Please select a category before submitting the poll.',
                          );
                          return;
                        }

                        final categoryId = selectedCategory?.id ?? '';
                        final start = '';
                        final end = '';
                        final durationInHours =
                            int.tryParse(
                              localSelectedCategory?.name?.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  ) ??
                                  '24',
                            ) ??
                            24; // Default to 24 hours if parsing fails
                        final durationInMinutes = (durationInHours * 60)
                            .toString();

                        try {
                          await CreatePostCtrl.find
                              .createPosts(
                                Preferences.uid ?? '',
                                categoryId,
                                questionCtrl.getText,
                                AddressModel(),
                                null,
                                null,
                                pollOptions,
                                'poll',
                                start,
                                end,
                                durationInMinutes,
                              )
                              .applyLoader;

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(20),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageView(url: AppImages.Done),
                                    SizedBox(width: 10),
                                    Center(
                                      child: TextView(
                                        text: "Poll added successfully!",
                                        style: 26.txtboldBtncolor,
                                        textAlign: TextAlign.center,
                                        margin: 20.top + 20.bottom,
                                      ),
                                    ),
                                    TextView(
                                      text:
                                          "Thank you for adding the poll. Success! Go to home to continue your journey.",
                                      style: 20.txtregularBtncolor,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppButton(
                                      margin: 20.top,
                                      label: AppStrings.gotohome,
                                      labelStyle: 17.txtBoldWhite,
                                      buttonColor: AppColors.btnColor,
                                      onTap: () {
                                        context.pushAndClearNavigator(
                                          HomeScreen(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                              );
                            },
                          );
                        } catch (e) {
                          AppUtils.toastError('Failed to add poll: $e');
                        }
                      },
                child: Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isValidForm ? AppColors.greenlight : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextView(
                      text: "Upload",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _form,
          onChanged: () {
            validDateForm();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll Question Section
              TextView(
                text: "Poll question",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: questionCtrl,
                  decoration: InputDecoration(
                    hintText: "Write a question...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Poll Question';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 24),

              // Category Selection Section
              Row(
                children: [
                  Icon(Icons.grid_view, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  TextView(
                    text: "Select a Category",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Show category selection
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextView(
                            text: "Select Category",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          ...categories
                              .map(
                                (category) => ListTile(
                                  title: Text(
                                    _getCategoryDisplayName(category.name),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                      showAdvertisementWarning =
                                          _isAdvertisementCategory(
                                            category.name,
                                          );
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory != null
                            ? _getCategoryDisplayName(selectedCategory!.name)
                            : 'Select a Category',
                        style: TextStyle(
                          color: selectedCategory != null
                              ? Colors.black87
                              : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.greenlight,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              // Advertisement warning
              if (showAdvertisementWarning) ...[
                SizedBox(height: 16),
                _buildAdvertisementWarning(),
              ],

              SizedBox(height: 24),

              // Options Section
              TextView(
                text: "Options",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              // Add Options Field
              GestureDetector(
                onTap: () {
                  pollOptions.add(PollItemModel());
                  pollOptions.refresh();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.playlist_add,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Add Options...",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      Spacer(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.greenlight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Poll Options List
              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = pollOptions[index];
                    return PollItemView(
                      onRemove: index > 1
                          ? () {
                              pollOptions.removeAt(index);
                              pollOptions.refresh();
                            }
                          : null,
                      showError: item.isValid != null && item.isValid == false,
                      data: item,
                      updateCallBack: (value) {
                        pollOptions[index] = value;
                        if ((value.isValid ?? false) &&
                            pollOptions.length == 1) {
                          pollOptions.add(PollItemModel());
                        }
                        pollOptions.refresh();
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: pollOptions.length,
                ),
              ),
              SizedBox(height: 24),

              // Duration Section
              Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  TextView(
                    text: "Duration",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Show duration selection
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextView(
                            text: "Select Duration",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          ..._categories
                              .map(
                                (category) => ListTile(
                                  title: Text(
                                    _getCategoryDisplayName(category.name),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      localSelectedCategory = category;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localSelectedCategory?.name ?? 'Duration',
                        style: TextStyle(
                          color: localSelectedCategory != null
                              ? Colors.black87
                              : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.greenlight,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              // Start Date
              //                 EditText(
              //                   controller: sDate,
              //                   onTap: () async {
              //                     final DateTime today = DateTime.now();
              //                     final DateTime? selectedDate = await showDatePicker(
              //                       context: context,
              //                       initialDate: today,
              //                       firstDate: today,
              //                       lastDate: DateTime(
              //                           2100),
              //                     );
              //
              //                     if (selectedDate != null) {
              //                       startDate.value = selectedDate;
              //                       sDate.text = startDate.value?.MMs_dds_yy ??
              //                           ''; // Format the start date
              //                       validDateForm();
              //                     }
              //                   },
              //                   readOnly: true,
              //                   margin: EdgeInsets.only(top: 16),
              //                   label: 'Poll Start Date',
              //                   labelStyle: 14.txtMedgreen,
              //                   hint: 'MM/DD/YY',
              //                   validator: (value) {
              //                     if (startDate.value == null) {
              //                       return 'Please enter start date';
              //                     }
              //                     return null;
              //                   },
              //                 ),
              //
              // // End Date (conditionally enabled)
              //                 Obx(
              //                   () => EditText(
              //                     controller: eDate,
              //                     onTap: startDate.value != null
              //                         ? () async {
              //                             final DateTime today =
              //                                 DateTime.now(); // Get today's date
              //                             final DateTime? selectedDate = await showDatePicker(
              //                               context: context,
              //                               initialDate: today,
              //                               firstDate: today,
              //                               lastDate: DateTime(2100),
              //                             );
              //
              //                             if (selectedDate != null) {
              //                               if (startDate.value != null &&
              //                                   selectedDate.isBefore(startDate.value!)) {
              //                                 eDate.text = '';
              //                                 AppUtils.toastError(
              //                                     "End Date cannot be before Start Date");
              //                               } else {
              //                                 endDate.value = selectedDate;
              //                                 eDate.text = endDate.value?.MMs_dds_yy ??
              //                                     ''; // Format the end date
              //                                 validDateForm();
              //                               }
              //                             }
              //                           }
              //                         : null,
              //                     // Disable onTap if startDate is not selected
              //                     readOnly: true,
              //                     margin: EdgeInsets.only(top: 16),
              //                     label: 'Poll End Date',
              //                     labelStyle: 14.txtMedgreen,
              //                     hint: 'MM/DD/YY',
              //                     validator: (value) {
              //                       if (endDate.value == null) {
              //                         return 'Please enter end date'; // Ensure the user enters an end date
              //                       }
              //                       if (startDate.value != null &&
              //                           endDate.value!.isBefore(startDate.value!)) {
              //                         return 'End Date cannot be before Start Date'; // Error if end date is before start date
              //                       }
              //                       return null;
              //                     },
              //                     // enabled: startDate.value != null, // Enable only if start date is selected
              //                   ),
              //                 ),
              //
              //                 // Start Time
              //                 EditText(
              //                   controller: sTime,
              //                   onTap: () async {
              //                     final time = await context.timePicker;
              //                     if (time != null) {
              //                       setState(() {
              //                         startTime.value = time;
              //                         sTime.text = startTime.value?.HHmm ?? '';
              //                       });
              //                       validDateForm();
              //                     }
              //                   },
              //                   readOnly: true,
              //                   margin: EdgeInsets.only(top: 16),
              //                   label: 'Poll Start Time',
              //                   labelStyle: 14.txtMedgreen,
              //                   hint: '00:00',
              //                   validator: (value) {
              //                     if (!value.isNotNullEmpty) {
              //                       return 'Please enter start time';
              //                     }
              //                     return null;
              //                   },
              //                 ),
              //
              // // End Time
              //                 EditText(
              //                   controller: eTime,
              //                   onTap: startTime.value != null
              //                       ? () async {
              //                           final time = await context.timePicker;
              //
              //                           if (time != null) {
              //                             // Check if the selected end time is before the start time
              //                             if (startTime.value != null &&
              //                                 time.isBefore(startTime.value!)) {
              //                               AppUtils.toastError(
              //                                   "End Time cannot be before Start Time");
              //                               return; // Don't update end time if it's invalid
              //                             }
              //
              //                             setState(() {
              //                               endTime.value = time;
              //                               eTime.text = endTime.value?.HHmm ?? '';
              //                             });
              //
              //                             validDateForm();
              //                           }
              //                         }
              //                       : null,
              //                   // Disable end time field if start time is not selected
              //                   readOnly: true,
              //                   margin: EdgeInsets.only(top: 16),
              //                   label: 'Poll End Time',
              //                   labelStyle: 14.txtMedgreen,
              //                   hint: '00:00',
              //                   validator: (value) {
              //                     if (!value.isNotNullEmpty) {
              //                       return 'Please enter end time';
              //                     }
              //
              //                     // If start time is selected, make sure end time is not earlier than start time
              //                     if (startTime.value != null &&
              //                         endTime.value != null &&
              //                         endTime.value!.isBefore(startTime.value!)) {
              //                       return 'End Time cannot be before Start Time';
              //                     }
              //
              //                     return null;
              //                   },
              //                 ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class PollItemView extends StatefulWidget {
  final PollItemModel data;
  final Function(PollItemModel) updateCallBack;
  final bool showError;
  final Function()? onRemove;

  const PollItemView({
    super.key,
    required this.data,
    required this.updateCallBack,
    required this.showError,
    required,
    required this.onRemove,
  });

  @override
  State<PollItemView> createState() => _PollItemViewState();
}

class _PollItemViewState extends State<PollItemView> {
  Rx<PollItemModel> item = Rx(PollItemModel());
  final ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      item.value = widget.data;
      AppUtils.log(item.value.toJson());
      item.refresh();
      ctrl.text = item.value.name ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      item.value = item.value.copyWith(file: pickedFile.path);
      AppUtils.log(pickedFile.path);
      item.refresh();
      update();
    }
  }

  void update() {
    widget.updateCallBack(item.value.updatedValidity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Obx(
                    () => item.value.file.isNotNullEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(item.value.file ?? ''),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: Colors.grey[600],
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: "Add option text...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  onChanged: (text) {
                    item.value = item.value.copyWith(name: text);
                    update();
                  },
                ),
              ),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.grey[400], size: 16),
                  ),
                ),
            ],
          ),
          if (widget.showError)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please add required image and description',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// appBar: AppBar(
//   centerTitle: true,
//   leading: IconButton(
//     icon: const Icon(Icons.arrow_back_ios_new,
//         color: Colors.white, size: 20),
//     onPressed: () => Navigator.pop(context),
//   ),
//   title: TextView(
//     style: 20.txtBoldWhite,
//     text: AppStrings.craetepoll,
//   ),
//   backgroundColor: Colors.black,
//   actions: [
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       child:GestureDetector(
//         onTap: () async {
//           validDateForm();
//           _optionValid;
//
//           // Check if the form is valid and a category is selected
//           if (!isValidForm || selectedCategory == null) {
//
//             AppUtils.toastError('Please select a category before submitting the poll.');
//             return;
//           }
//
//           final start = startDate.value!
//               .copyWith(
//               hour: startTime.value!.hour,
//               minute: startTime.value!.minute)
//               .toIso8601String();
//           final end = endDate.value!
//               .copyWith(
//               hour: endTime.value!.hour,
//               minute: endTime.value!.minute)
//               .toIso8601String();
//           try {
//             final result = await CreatePostCtrl.find
//                 .createPosts(
//                 Preferences.uid ?? '',
//                 selectedCategory.toString(),
//                 questionCtrl.getText,
//                 AddressModel(),
//                 null,
//                 null,
//                 pollOptions,
//                 'poll',
//                 start,
//                 end)
//                 .applyLoader;
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   contentPadding: EdgeInsets.all(20),
//                   title: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ImageView(
//                         url: AppImages.Done,
//                       ),
//                       SizedBox(width: 10),
//                       TextView(
//                         text: "Poll added Success!",
//                         style: 26.txtboldBtncolor,
//                         margin: EdgeInsets.only(top: 20, bottom: 20),
//                       ),
//                       TextView(
//                         text:
//                         "Thank you for adding the poll. Success! Go to home to continue your journey.",
//                         style: 20.txtregularBtncolor,
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       AppButton(
//                         margin: 20.top,
//                         label: AppStrings.gotohome,
//                         labelStyle: 17.txtBoldWhite,
//                         buttonColor: AppColors.btnColor,
//                         onTap: () {
//                           context.pushNavigator(HomeScreen());
//                         },
//                       )
//                     ],
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20)),
//                   ),
//                 );
//               },
//             );
//           } catch (e) {
//
//           }
//         },
//         child: Obx(
//               () => Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             decoration: BoxDecoration(
//               color: isValidForm ? AppAppColors.greenlight : AppColors.Grey,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Center(
//               child: TextView(
//                 text: "Done",
//                 style: 15.txtMediumWhite,
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   ],
// ),
