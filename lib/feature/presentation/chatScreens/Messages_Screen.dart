import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appColors.dart';
import '../../../services/storage/preferences.dart';
import '../profileScreens/friend_profile_screen.dart';
import 'Chat_Sample.dart';
import 'ImagePreviewScreen.dart';
import 'VideoPreviewScreen.dart';
import 'package:path/path.dart' as path;

class MessageScreen extends StatefulWidget {
  final ProfileDataModel? data;
  final String? chatId;

  const MessageScreen({super.key, this.data, this.chatId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  ProfileDataModel? data;
  final ctrl = ChatCtrl.find;

  final msgCtrl = TextEditingController();
  bool isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();

  bool _isEmojiVisible = false;

  void _toggleEmojiKeyboard() {
    if (_isEmojiVisible) {
      FocusScope.of(context).requestFocus(_focusNode);
    } else {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  void _hideEmojiKeyboard() {
    if (_isEmojiVisible) {
      setState(() {
        _isEmojiVisible = false;
      });
      FocusScope.of(context).unfocus();
    }
  }

  final List<String> emojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '🤗',
    '🤭',
    '🤫',
    '🤔',
    '🤐',
    '🤨',
    '😐',
    '😑',
    '😶',
    '🙄',
    '😏',
    '😣',
    '😥',
    '😮',
    '😯',
    '😲',
    '😳',
    '🥺',
    '😦',
    '😧',
    '😨',
    '😰',
    '😢',
    '😭',
    '😱',
    '😤',
    '😠',
    '😡',
    '🤬',
    '🤯',
    '😬',
    '😓',
    '😞',
    '😟',
    '😔',
    '😕',
    '🙃',
    '🫠',
    '🥴',
    '😵',
    '😵‍💫',
    '🤕',
    '🤒',
    '🤢',
    '🤮',
    '🤧',
    '😷',
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🤎',
    '🖤',
    '🤍',
    '💖',
    '💗',
    '💘',
    '💝',
    '💓',
    '💞',
    '💕',
    '💌',
    '💟',
    '❣️',
    '💔',
    '❤️‍🔥',
    '❤️‍🩹',
    '🙋‍♂️',
    '🙋‍♀️',
    '🙌',
    '👋',
    '🤚',
    '🖐️',
    '✋',
    '🖖',
    '👌',
    '🤌',
    '🤏',
    '✌️',
    '🤞',
    '🫰',
    '🤟',
    '🤘',
    '🤙',
    '👈',
    '👉',
    '👆',
    '🖕',
    '👇',
    '☝️',
    '👍',
    '👎',
    '👊',
    '🤛',
    '🤜',
    '👏',
    '🫶',
    '🤝',
    '🙏',
    '🫡',
    '🧑',
    '👨',
    '👩',
    '👶',
    '🧒',
    '👦',
    '👧',
    '👵',
    '👴',
    '🧓',
    '👩‍🦳',
    '👨‍🦳',
    '🧔‍♂️',
    '👨‍🦰',
    '👩‍🦰',
    '👨‍🦱',
    '👩‍🦱',
    '👨‍🦲',
    '👩‍🦲',
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
    '🐧',
    '🐦',
    '🐤',
    '🐣',
    '🐥',
    '🦆',
    '🦅',
    '🦉',
    '🐝',
    '🪲',
    '🦋',
    '🐛',
    '🐌',
    '🐞',
    '🐜',
    '🐢',
    '🐍',
    '🦎',
    '🐙',
    '🦑',
    '🍏',
    '🍎',
    '🍐',
    '🍊',
    '🍋',
    '🍌',
    '🍉',
    '🍇',
    '🍓',
    '🫐',
    '🥝',
    '🥑',
    '🍍',
    '🍒',
    '🥭',
    '🥥',
    '🥦',
    '🥬',
    '🧄',
    '🧅',
    '🥔',
    '🥕',
    '🌽',
    '🌶️',
    '🍞',
    '🥐',
    '🥖',
    '🥨',
    '🧀',
    '🥚',
    '🍳',
    '🥞',
    '🧇',
    '🥓',
    '🍔',
    '🍟',
    '🍕',
    '🌭',
    '🌮',
    '🌯',
    '🥙',
    '🥗',
    '🍿',
    '🧈',
    '🍰',
    '🎂',
    '🍪',
    '🍩',
    '🍫',
    '🍬',
    '🍭',
    '☕',
    '🧃',
    '🧋',
    '🥤',
    '🍺',
    '🍻',
    '🍷',
    '🍹',
    '🥂',
    '🚗',
    '🚕',
    '🚙',
    '🚌',
    '🚎',
    '🏎️',
    '🚓',
    '🚑',
    '🚒',
    '🚐',
    '🛻',
    '🚚',
    '🚲',
    '🛴',
    '🛵',
    '🛺',
    '🚁',
    '✈️',
    '🛫',
    '🛬',
    '🚀',
    '🛸',
    '🚤',
    '⛵️',
    '🏠',
    '🏡',
    '🏢',
    '🏣',
    '🏤',
    '🏥',
    '🏦',
    '🏨',
    '🏪',
    '🏫',
    '🏬',
    '🏭',
    '🌞',
    '🌝',
    '🌛',
    '🌜',
    '🌚',
    '🌕',
    '🌖',
    '🌗',
    '🌘',
    '🌑',
    '🌒',
    '🌓',
    '🌙',
    '⭐',
    '🌟',
    '🌠',
    '☀️',
    '🌤️',
    '⛅',
    '🌥️',
    '🌦️',
    '🌧️',
    '⛈️',
    '🌩️',
    '🌨️',
    '❄️',
    '☃️',
    '⛄',
    '🌬️',
    '💨',
    '🌪️',
    '🌫️',
    '🌊',
    '💧',
    '💦',
    '🎉',
    '🎊',
    '🎈',
    '🎁',
    '🎂',
    '🎄',
    '🎃',
    '🎆',
    '🎇',
    '🧨',
    '🎎',
    '🎐',
    '💼',
    '📁',
    '📂',
    '🗂️',
    '🧾',
    '🧰',
    '🧲',
    '🔧',
    '🔨',
    '⚒️',
    '🛠️',
    '🪓',
    '🧱',
    '🪚',
    '🪛',
    '🔩',
    '⚙️',
    '🗜️',
    '⚖️',
    '🧮',
    '🧪',
    '🧫',
    '🧬',
    '💬',
    '🗨️',
    '🗯️',
    '💭',
    '❓',
    '❔',
    '❕',
    '❗',
    '‼️',
    '⁉️',
    '🔇',
    '🔈',
    '🔉',
    '🔊',
    '⏰',
    '⌚',
    '⏱️',
    '⏲️',
    '🕐',
    '🕑',
    '🕒',
    '🕓',
    '🕔',
    '🕕',
    '🕖',
    '🕗',
    '🕘',
    '🕙',
    '🕚',
    '🕛',
  ];

  @override
  void initState() {
    super.initState();
    onCreate();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && isEmojiVisible) {
        setState(() => isEmojiVisible = false);
      }
    });
  }

  void onCreate() {
    data = widget.data;
    ctrl.joinSingleChat(data?.id ?? '', widget.chatId);

    // watchSingleChatData
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (data, data1) {
        ctrl.onLeaveChatRoom();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Container(
                  padding: 15.horizontal + 10.vertical,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.greenlight),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.greenlight,
                            size: 20,
                          ),
                        ),
                      ),
                      10.width,
                      GestureDetector(
                        onTap: () {
                          if (data?.id != Preferences.uid) {
                            context.pushNavigator(
                              FriendProfileScreen(data: data!),
                            );
                          }
                        },
                        // onTap: () {
                        //   showDialog(
                        //     context: context,
                        //     barrierColor: Colors.transparent,
                        //     barrierDismissible: true,
                        //     builder: (context) {
                        //       return GestureDetector(
                        //         onTap: () => Navigator.pop(context),
                        //         child: Container(
                        //           color: Colors.black,
                        //           alignment: Alignment.center,
                        //           child: _buildZoomableImage(
                        //             ImageDataModel(
                        //               network: AppUtils.configImageUrl(data?.image ?? ''),
                        //               type: ImageType.network,
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   );
                        // },
                        child: ImageView(
                          size: 40,
                          radius: 20,
                          fit: BoxFit.cover,
                          url: AppUtils.configImageUrl(data?.image ?? ''),
                          defaultImage: AppImages.dummyProfile,
                          imageType: ImageType.network,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data!.name ?? '',
                              style: 16.txtMediumprimary,
                              maxLines: null,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            5.height,
                            Visibility(
                              visible: false,
                              child: Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Visibility(
                        visible: false,
                        child: GestureDetector(
                          onTap: () {
                            // _showBottomSheet(context);
                          },
                          child: Icon(
                            Icons.more_vert,
                            size: 22,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: ChatSample(peerUser: data)),
                _buildMessageInputField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    final picker = ImagePicker();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: _isEmojiVisible,
          child: GestureDetector(
            onTap: () {
              context.pop();
              setState(() {
                _isEmojiVisible = false;
              });
            },
            child: Container(
              color: Colors.grey.withOpacity(0.5),
              child: Center(
                child: GestureDetector(
                  onTap: _hideEmojiKeyboard,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    height: 250,
                    color: AppColors.white,
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: emojis.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            msgCtrl.text += emojis[index];
                            msgCtrl.selection = TextSelection.fromPosition(
                              TextPosition(offset: msgCtrl.text.length),
                            );
                          },
                          child: Center(
                            child: Text(
                              emojis[index],
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: AppColors.grey,
                ),
                onPressed: _toggleEmojiKeyboard,
              ),
              Expanded(
                child: TextFormField(
                  controller: msgCtrl,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type something...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onTap: () {
                    if (_isEmojiVisible) {
                      setState(() => _isEmojiVisible = false);
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Padding(
                              padding: 15.top,
                              child: ImageView(
                                url: AppImages.cemaraaa,
                                size: 30,
                              ),
                            ),
                            title: TextView(
                              text: 'Capture Image',
                              style: 16.txtMediumprimary,
                            ),
                            onTap: () async {
                              context.pop();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (pickedFile != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewScreen(
                                      imageFile: File(pickedFile.path),
                                      onSend: () {
                                        ctrl
                                            .sendImageMessage(pickedFile)
                                            .applyLoader;
                                        context.pop();
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: Padding(
                              padding: 15.top,
                              child: ImageView(
                                url: AppImages.videoImage,
                                size: 30,
                              ),
                            ),
                            title: TextView(
                              text: 'Capture Video',
                              style: 16.txtMediumprimary,
                            ),
                            onTap: () async {
                              context.pop();
                              final pickedFile = await picker.pickVideo(
                                source: ImageSource.camera,
                              );
                              if (pickedFile != null) {
                                final tempPath = pickedFile.path;
                                final tempFile = File(tempPath);

                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final fileName = path.basename(tempPath);
                                final savedVideo = await tempFile.copy(
                                  '${appDir.path}/$fileName',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPreviewScreen(
                                      videoFile: savedVideo,
                                      onSend: () {
                                        ctrl
                                            .sendVideoMessage(
                                              XFile(savedVideo.path),
                                            )
                                            .applyLoader;
                                        context.pop();
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: Padding(
                              padding: 15.top,
                              child: ImageView(
                                url: AppImages.gallery,
                                size: 30,
                              ),
                            ),
                            title: TextView(
                              text: 'Pick Image',
                              style: 16.txtMediumprimary,
                            ),
                            onTap: () async {
                              context.pop();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewScreen(
                                      imageFile: File(pickedFile.path),
                                      onSend: () {
                                        ctrl
                                            .sendImageMessage(pickedFile)
                                            .applyLoader;
                                        context.pop();
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: Padding(
                              padding: 15.top,
                              child: ImageView(
                                url: AppImages.videoicon,
                                size: 30,
                              ),
                            ),
                            title: TextView(
                              text: 'Pick Video',
                              style: 16.txtMediumprimary,
                            ),
                            onTap: () async {
                              context.pop();
                              final pickedVideo = await picker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (pickedVideo != null) {
                                ctrl.sendVideoMessage(pickedVideo).applyLoader;
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: ImageView(url: 'assets/images/sharebtm.png', size: 40),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (msgCtrl.getText.isNotNullEmpty) {
                    ctrl.sendTextMsg(msgCtrl.getText);
                    msgCtrl.clear();
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  child: ImageView(url: 'assets/images/sendmsg.png', size: 40),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
