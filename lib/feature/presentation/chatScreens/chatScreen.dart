import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/coreComponents/appBar2.dart';
import '../../../components/coreComponents/EditText.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../utils/extensions/dateTimeUtils.dart';
import '../../data/models/dataModels/recent_chat_model/recent_chat_model.dart';
import 'Messages_Screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = ChatCtrl.find;

  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  List<RecentChatModel> filteredChatList = [];

  // Toggle between Slidable and Dismissible modes
  bool useSlidableMode = true;

  @override
  void initState() {
    super.initState();

    ctrl.fireRecentChatEvent();
    filteredChatList = ctrl.recentChat;
    searchController.addListener(_applySearchFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        filteredChatList = ctrl.recentChat;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _applySearchFilter() {
    String searchText = searchController.text.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        filteredChatList = ctrl.recentChat;
      } else {
        filteredChatList = ctrl.recentChat.where((chat) {
          final user = chat.userDetails?.firstWhereOrNull(
            (element) => element.id != Preferences.uid,
          );
          final userName = user?.name?.toLowerCase() ?? '';
          return userName.contains(searchText);
        }).toList();
      }
    });
  }

  String formatToCustomDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateTimeUtils.getChatTimeFormat(parsedDate);
      // final relativeTime = timeago.format(parsedDate);
      // final formattedDate = DateFormat('d MMM yyyy').format(parsedDate);
      // return '$relativeTime • $formattedDate';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              AppBar2(
                prefixImage: AppImages.backBtn,
                leadIconSize: 16,
                onPrefixTap: () => Navigator.pop(context),
                title: 'Chats',
                titleAlign: TextAlign.center,
                titleStyle: 20.txtSBoldprimary,
                backgroundColor: AppColors.white,
                suffixWidget: IconButton(
                  icon: Icon(
                    useSlidableMode ? Icons.swipe : Icons.delete_sweep,
                    color: AppColors.btnColor,
                  ),
                  onPressed: () {
                    setState(() {
                      useSlidableMode = !useSlidableMode;
                    });
                  },
                  tooltip: useSlidableMode
                      ? 'Switch to Swipe to Delete'
                      : 'Switch to Slidable Actions',
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sdp,
                  vertical: 16.sdp,
                ),
                child: EditText(
                  controller: searchController,
                  hint: 'Search Chat',
                  hintStyle: 14.txtMediumgrey,
                  radius: 20,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.sdp),
                    child: ImageView(
                      url: AppImages.search,
                      size: 20.sdp,
                      tintColor: AppColors.grey,
                    ),
                  ),
                ),
              ),
              Obx(
                () => ctrl.recentChat.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 180),
                          ImageView(url: AppImages.nomessages, size: 110),
                          TextView(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            text: "No Messages Yet",
                            style: 30.txtSBoldprimary,
                          ),
                        ],
                      )
                    : Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final estimatedItemHeight = 90.0;
                            final totalContentHeight =
                                filteredChatList.length * estimatedItemHeight;

                            final shouldScroll =
                                totalContentHeight > constraints.maxHeight;

                            if (shouldScroll) {
                              return ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredChatList.length,
                                itemBuilder: (context, index) {
                                  final data = filteredChatList[index];
                                  final user = data.userDetails?.firstWhere(
                                    (element) => element.id != Preferences.uid,
                                  );
                                  final int unread =
                                      data.unreadCount?[Preferences.uid] ?? 0;
                                  return useSlidableMode
                                      ? Slidable(
                                          // Specify a key if the Slidable is dismissible.
                                          key: const ValueKey(0),

                                          // The start action pane is the one at the left or the top side.
                                          startActionPane: ActionPane(
                                            // A motion is a widget used to control how the pane animates.
                                            motion: const ScrollMotion(),

                                            // A pane can dismiss the Slidable.
                                            dismissible: DismissiblePane(
                                              onDismissed: () {},
                                            ),

                                            // All actions are defined in the children parameter.
                                            children: [
                                              // A SlidableAction can have an icon and/or a label.
                                              SlidableAction(
                                                onPressed: (context) {
                                                  // TODO: Implement delete functionality
                                                  print(
                                                    'Delete chat: ${data.id}',
                                                  );
                                                },
                                                backgroundColor: Color(
                                                  0xFFFE4A49,
                                                ),
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: 'Delete',
                                              ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  // TODO: Implement share functionality
                                                  print(
                                                    'Share chat: ${data.id}',
                                                  );
                                                },
                                                backgroundColor: Color(
                                                  0xFF21B7CA,
                                                ),
                                                foregroundColor: Colors.white,
                                                icon: Icons.share,
                                                label: 'Share',
                                              ),
                                            ],
                                          ),

                                          // The end action pane is the one at the right or the bottom side.
                                          endActionPane: ActionPane(
                                            motion: ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                // An action can be bigger than the others.
                                                flex: 2,
                                                onPressed: (context) {
                                                  // TODO: Implement archive functionality
                                                  print(
                                                    'Archive chat: ${data.id}',
                                                  );
                                                },
                                                backgroundColor: Color(
                                                  0xFF7BC043,
                                                ),
                                                foregroundColor: Colors.white,
                                                icon: Icons.archive,
                                                label: 'Archive',
                                              ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  // TODO: Implement save functionality
                                                  print(
                                                    'Save chat: ${data.id}',
                                                  );
                                                },
                                                backgroundColor: Color(
                                                  0xFF0392CF,
                                                ),
                                                foregroundColor: Colors.white,
                                                icon: Icons.save,
                                                label: 'Save',
                                              ),
                                            ],
                                          ),

                                          // The child of the Slidable is what the user sees when the
                                          // component is not dragged.
                                          child: const ListTile(
                                            title: Text('Slide me'),
                                          ),
                                        )
                                      : Dismissible(
                                          key: Key(data.id ?? ''),

                                          direction:
                                              DismissDirection.endToStart,
                                          onDismissed: (direction) async {
                                            final shouldDelete = await showDialog<bool>(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Stack(
                                                  children: [
                                                    BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 5,
                                                        sigmaY: 5,
                                                      ),
                                                      child: Container(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                      ),
                                                    ),
                                                    AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              40,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      insetPadding:
                                                          40.horizontal,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      titlePadding:
                                                          EdgeInsets.zero,
                                                      title: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          TextView(
                                                            text:
                                                                "Delete Chat?",
                                                            style: 24
                                                                .txtSBoldprimary,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          SizedBox(height: 15),
                                                          Divider(
                                                            color:
                                                                AppColors.Grey,
                                                            thickness: 1,
                                                            height: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      content: Padding(
                                                        padding: 14.top,
                                                        child: TextView(
                                                          text:
                                                              "Are you sure you want to delete ${user?.name} chat?",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: 16
                                                              .txtRegularprimary,
                                                        ),
                                                      ),
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      actions: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              AppButton(
                                                                radius: 25.sdp,
                                                                width: 110.sdp,
                                                                label: "Cancel",
                                                                labelStyle: 14
                                                                    .txtMediumbtncolor,
                                                                buttonColor:
                                                                    AppColors
                                                                        .white,
                                                                buttonBorderColor:
                                                                    AppColors
                                                                        .btnColor,
                                                                margin:
                                                                    EdgeInsets.only(
                                                                      right: 20,
                                                                    ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false);
                                                                },
                                                              ),
                                                              AppButton(
                                                                radius: 25.sdp,
                                                                width: 110.sdp,
                                                                label: "Delete",
                                                                labelStyle: 14
                                                                    .txtMediumWhite,
                                                                buttonColor:
                                                                    AppColors
                                                                        .btnColor,
                                                                onTap: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            // Handle deletion result
                                            if (shouldDelete == true) {
                                              // TODO: Implement actual chat deletion logic
                                              // ctrl.deleteChat(data.id);
                                              print('Chat deleted: ${data.id}');
                                              ctrl.fireRecentChatEvent();
                                            }
                                          },
                                          background: Container(
                                            // color: Colors.green,
                                            color: Colors.red,
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 8,
                                                    ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    await context
                                                        .pushNavigator(
                                                          MessageScreen(
                                                            chatId: data.id,
                                                            data:
                                                                ProfileDataModel(
                                                                  id: user?.id,
                                                                  name: user
                                                                      ?.name,
                                                                  image: user
                                                                      ?.image,
                                                                ),
                                                          ),
                                                        )
                                                        .then((value) {
                                                          if (value == true) {
                                                            ChatCtrl.find
                                                                .fireRecentChatEvent();
                                                          }
                                                        });
                                                    ctrl.fireRecentChatEvent();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      ImageView(
                                                        url:
                                                            AppUtils.configImageUrl(
                                                              user?.image ?? '',
                                                            ),
                                                        imageType:
                                                            ImageType.network,
                                                        radius: 22.5,
                                                        size: 45,
                                                        fit: BoxFit.cover,
                                                        defaultImage: AppImages
                                                            .dummyProfile,
                                                        borderColor:
                                                            AppColors.yellow,
                                                        hasBorder: true,
                                                        radiusWidth: 2,
                                                      ),
                                                      8.width,
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: TextView(
                                                                    text:
                                                                        user?.name ??
                                                                        '',
                                                                    color: AppColors
                                                                        .white,
                                                                    style: 15
                                                                        .txtSBoldprimary,
                                                                    margin:
                                                                        const EdgeInsets.only(
                                                                          top:
                                                                              5,
                                                                        ),
                                                                    maxlines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    TextView(
                                                                      text: formatToCustomDate(
                                                                        data.latestMessage?.senderTime ??
                                                                            "",
                                                                      ),
                                                                      color: AppColors
                                                                          .white,
                                                                      style: 12
                                                                          .txtMediumgrey,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            5.height,
                                                            Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: TextView(
                                                                            text: _getMessagePreview(
                                                                              data.latestMessage?.content ??
                                                                                  '',
                                                                            ),
                                                                            style:
                                                                                14.txtRegularbtncolor,
                                                                            color:
                                                                                AppColors.grey,
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            maxlines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    if (unread >
                                                                        0)
                                                                      Positioned(
                                                                        right:
                                                                            0,
                                                                        top: 0,
                                                                        child: Container(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                2,
                                                                              ),
                                                                          constraints: const BoxConstraints(
                                                                            minWidth:
                                                                                16,
                                                                            minHeight:
                                                                                16,
                                                                          ),
                                                                          decoration: const BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child: Text(
                                                                            unread >
                                                                                    100
                                                                                ? '100+'
                                                                                : unread.toString(),
                                                                            style: const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: AppColors.divider
                                                    .withValues(alpha: 0.5),
                                                thickness: 1,
                                              ),
                                            ],
                                          ),
                                        );
                                },
                              );
                            } else {
                              return SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                child: Column(
                                  children: List.generate(filteredChatList.length, (
                                    index,
                                  ) {
                                    final data = filteredChatList[index];
                                    final user = data.userDetails?.firstWhere(
                                      (element) =>
                                          element.id != Preferences.uid,
                                    );

                                    final int unread =
                                        data.unreadCount?[Preferences.uid] ?? 0;

                                    return useSlidableMode
                                        ? Slidable(
                                            endActionPane: ActionPane(
                                              motion: ScrollMotion(),
                                              extentRatio: 0.2,
                                              children: [
                                                SlidableAction(
                                                  flex: 1,
                                                  onPressed: (context) async {
                                                    final shouldDelete = await showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext context) {
                                                        return Stack(
                                                          children: [
                                                            BackdropFilter(
                                                              filter:
                                                                  ImageFilter.blur(
                                                                    sigmaX: 5,
                                                                    sigmaY: 5,
                                                                  ),
                                                              child: Container(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                              ),
                                                            ),
                                                            AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      40,
                                                                    ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors.white,
                                                              insetPadding:
                                                                  40.horizontal,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              titlePadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              title: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  TextView(
                                                                    text:
                                                                        "Delete Chat?",
                                                                    style: 24
                                                                        .txtSBoldprimary,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Divider(
                                                                    color:
                                                                        AppColors
                                                                            .Grey,
                                                                    thickness:
                                                                        1,
                                                                    height: 1,
                                                                  ),
                                                                ],
                                                              ),
                                                              content: Padding(
                                                                padding: 14.top,
                                                                child: TextView(
                                                                  text:
                                                                      "Are you sure you want to delete ${user?.name} chat?",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: 16
                                                                      .txtRegularprimary,
                                                                ),
                                                              ),
                                                              actionsAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              actions: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        8.0,
                                                                      ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      AppButton(
                                                                        radius:
                                                                            25.sdp,
                                                                        width: 110
                                                                            .sdp,
                                                                        label:
                                                                            "Cancel",
                                                                        labelStyle:
                                                                            14.txtMediumbtncolor,
                                                                        buttonColor:
                                                                            AppColors.white,
                                                                        buttonBorderColor:
                                                                            AppColors.btnColor,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              20,
                                                                        ),
                                                                        onTap: () {
                                                                          Slidable.of(
                                                                            context,
                                                                          )?.close();
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            false,
                                                                          );
                                                                        },
                                                                      ),
                                                                      AppButton(
                                                                        radius:
                                                                            25.sdp,
                                                                        width: 110
                                                                            .sdp,
                                                                        label:
                                                                            "Delete",
                                                                        labelStyle:
                                                                            14.txtMediumWhite,
                                                                        buttonColor:
                                                                            AppColors.btnColor,
                                                                        onTap: () {
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            true,
                                                                          );
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    // Handle deletion result
                                                    if (shouldDelete == true) {
                                                      // TODO: Implement actual chat deletion logic
                                                      // ctrl.deleteChat(data.id);
                                                      print(
                                                        'Chat deleted: ${data.id}',
                                                      );
                                                      ctrl.fireRecentChatEvent();
                                                    }
                                                  },
                                                  backgroundColor:
                                                      AppColors.red,
                                                  foregroundColor:
                                                      AppColors.white,
                                                  icon: Icons.delete,
                                                  // label: 'Delete',
                                                ),
                                              ],
                                            ),

                                            // The child of the Slidable is what the user sees when the
                                            // component is not dragged.
                                            child: Builder(
                                              builder: (slideableContext) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 20.sdp,
                                                            vertical: 8.sdp,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 8.sdp,
                                                            height: 70.sdp,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius: BorderRadius.only(
                                                                topLeft:
                                                                    Radius.circular(
                                                                      12.sdp,
                                                                    ),
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      12.sdp,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16.sdp,
                                                                    vertical:
                                                                        16.sdp,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .grey
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12.sdp,
                                                                    ),
                                                              ),
                                                              child: InkWell(
                                                                onTap: () async {
                                                                  Slidable.of(
                                                                    slideableContext,
                                                                  )?.close();

                                                                  await context
                                                                      .pushNavigator(
                                                                        MessageScreen(
                                                                          chatId:
                                                                              data.id,
                                                                          data: ProfileDataModel(
                                                                            id: user?.id,
                                                                            name:
                                                                                user?.name,
                                                                            image:
                                                                                user?.image,
                                                                          ),
                                                                        ),
                                                                      )
                                                                      .then(
                                                                        (
                                                                          value,
                                                                        ) => ChatCtrl
                                                                            .find
                                                                            .fireRecentChatEvent(),
                                                                      );

                                                                  ctrl.fireRecentChatEvent();
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    ImageView(
                                                                      url: AppUtils.configImageUrl(
                                                                        user?.image ??
                                                                            '',
                                                                      ),
                                                                      imageType:
                                                                          ImageType
                                                                              .network,
                                                                      radius: 25
                                                                          .sdp,
                                                                      size: 50
                                                                          .sdp,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      defaultImage:
                                                                          AppImages
                                                                              .dummyProfile,
                                                                    ),
                                                                    16.width,
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextView(
                                                                                  text:
                                                                                      user?.name ??
                                                                                      '',
                                                                                  style: 16.txtSBoldprimary,
                                                                                  maxlines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                              TextView(
                                                                                text: formatToCustomDate(
                                                                                  data.latestMessage?.senderTime ??
                                                                                      "",
                                                                                ),
                                                                                style: 12.txtMediumgrey,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          6.height,
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextView(
                                                                                  text: _getMessagePreview(
                                                                                    data.latestMessage?.content ??
                                                                                        '',
                                                                                  ),
                                                                                  style: 14.txtMediumgrey,
                                                                                  maxlines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),

                                                                              Visibility(
                                                                                visible:
                                                                                    unread >
                                                                                    0,
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(
                                                                                    6.sdp,
                                                                                  ),
                                                                                  constraints: BoxConstraints(
                                                                                    minWidth: 20.sdp,
                                                                                    minHeight: 20.sdp,
                                                                                  ),
                                                                                  decoration: const BoxDecoration(
                                                                                    color: Colors.green,
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                  alignment: Alignment.center,
                                                                                  child: Text(
                                                                                    unread.toString(),
                                                                                    style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 10,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          )
                                        : Dismissible(
                                            key: Key(data.id ?? ''),
                                            direction:
                                                DismissDirection.endToStart,
                                            onDismissed: (direction) async {
                                              final shouldDelete = await showDialog<bool>(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (BuildContext context) {
                                                  return Stack(
                                                    children: [
                                                      BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                              sigmaX: 5,
                                                              sigmaY: 5,
                                                            ),
                                                        child: Container(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                40,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.white,
                                                        insetPadding:
                                                            40.horizontal,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        titlePadding:
                                                            EdgeInsets.zero,
                                                        title: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            TextView(
                                                              text:
                                                                  "Delete Chat?",
                                                              style: 24
                                                                  .txtSBoldprimary,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            Divider(
                                                              color: AppColors
                                                                  .Grey,
                                                              thickness: 1,
                                                              height: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        content: Padding(
                                                          padding: 14.top,
                                                          child: TextView(
                                                            text:
                                                                "Are you sure you want to delete ${user?.name} chat?",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: 16
                                                                .txtRegularprimary,
                                                          ),
                                                        ),
                                                        actionsAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        actions: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                AppButton(
                                                                  radius:
                                                                      25.sdp,
                                                                  width:
                                                                      110.sdp,
                                                                  label:
                                                                      "Cancel",
                                                                  labelStyle: 14
                                                                      .txtMediumbtncolor,
                                                                  buttonColor:
                                                                      AppColors
                                                                          .white,
                                                                  buttonBorderColor:
                                                                      AppColors
                                                                          .btnColor,
                                                                  margin:
                                                                      EdgeInsets.only(
                                                                        right:
                                                                            20,
                                                                      ),
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    );
                                                                  },
                                                                ),
                                                                AppButton(
                                                                  radius:
                                                                      25.sdp,
                                                                  width:
                                                                      110.sdp,
                                                                  label:
                                                                      "Delete",
                                                                  labelStyle: 14
                                                                      .txtMediumWhite,
                                                                  buttonColor:
                                                                      AppColors
                                                                          .btnColor,
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              // Handle deletion result
                                              if (shouldDelete == true) {
                                                // TODO: Implement actual chat deletion logic
                                                // ctrl.deleteChat(data.id);
                                                print(
                                                  'Chat deleted: ${data.id}',
                                                );
                                                ctrl.fireRecentChatEvent();
                                              }
                                            },
                                            // background: Container(
                                            //   color: Colors.red,
                                            //   alignment: Alignment.centerRight,
                                            //   padding: const EdgeInsets.symmetric(
                                            //       horizontal: 20),
                                            //   child: const Icon(Icons.delete,
                                            //       color: Colors.white),
                                            // ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 8,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await context
                                                          .pushNavigator(
                                                            MessageScreen(
                                                              chatId: data.id,
                                                              data:
                                                                  ProfileDataModel(
                                                                    id: user
                                                                        ?.id,
                                                                    name: user
                                                                        ?.name,
                                                                    image: user
                                                                        ?.image,
                                                                  ),
                                                            ),
                                                          )
                                                          .then(
                                                            (value) => ChatCtrl
                                                                .find
                                                                .fireRecentChatEvent(),
                                                          );

                                                      ctrl.fireRecentChatEvent();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        ImageView(
                                                          url:
                                                              AppUtils.configImageUrl(
                                                                user?.image ??
                                                                    '',
                                                              ),
                                                          imageType:
                                                              ImageType.network,
                                                          radius: 22.5,
                                                          size: 45,
                                                          fit: BoxFit.cover,
                                                          defaultImage:
                                                              AppImages
                                                                  .dummyProfile,
                                                          borderColor:
                                                              AppColors.yellow,
                                                          hasBorder: true,
                                                          radiusWidth: 2,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: TextView(
                                                                      text:
                                                                          user?.name ??
                                                                          '',
                                                                      color: AppColors
                                                                          .white,
                                                                      style: 15
                                                                          .txtSBoldprimary,
                                                                      margin:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                5,
                                                                          ),
                                                                      maxlines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  TextView(
                                                                    text: formatToCustomDate(
                                                                      data.latestMessage?.senderTime ??
                                                                          "",
                                                                    ),
                                                                    color: AppColors
                                                                        .white,
                                                                    style: 12
                                                                        .txtMediumgrey,
                                                                    margin:
                                                                        const EdgeInsets.only(
                                                                          top:
                                                                              5,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: TextView(
                                                                      text: _getMessagePreview(
                                                                        data.latestMessage?.content ??
                                                                            '',
                                                                      ),
                                                                      style:
                                                                          unread >
                                                                              0
                                                                          ? 14.txtExBoldBtncolor
                                                                          : 14.txtRegularbtncolor,
                                                                      color: AppColors
                                                                          .grey,
                                                                      margin: EdgeInsets
                                                                          .zero,
                                                                      maxlines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),

                                                                  Visibility(
                                                                    visible:
                                                                        unread >
                                                                        0,
                                                                    child: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            2,
                                                                          ),
                                                                      constraints: const BoxConstraints(
                                                                        minWidth:
                                                                            16,
                                                                        minHeight:
                                                                            16,
                                                                      ),
                                                                      decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Text(
                                                                        unread
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  color: AppColors.divider
                                                      .withValues(alpha: 0.5),
                                                  thickness: 1,
                                                ),
                                              ],
                                            ),
                                          );
                                  }),
                                ),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMessagePreview(String content) {
    final lowerContent = content.toLowerCase();
    final isImage =
        lowerContent.endsWith(".jpg") ||
        lowerContent.endsWith(".jpeg") ||
        lowerContent.endsWith(".png") ||
        lowerContent.endsWith(".gif");

    final isVideo =
        lowerContent.endsWith(".mp4") ||
        lowerContent.endsWith(".mov") ||
        lowerContent.endsWith(".avi");

    if (isImage) {
      return "📷 Image";
    } else if (isVideo) {
      return "🎥 Video";
    } else {
      return content;
    }
  }
}
