import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/pollCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../components/appLoader.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../data/models/dataModels/post_data.dart';
import '../../controller/auth_Controller/auth_ctrl.dart';
import '../../controller/auth_Controller/profileCtrl.dart';

class ShowPollScreen extends StatefulWidget {
  const ShowPollScreen({Key? key}) : super(key: key);

  @override
  State<ShowPollScreen> createState() => _ShowPollScreenState();
}

class _ShowPollScreenState extends State<ShowPollScreen> {
  final AuthCtrl authCtrl = Get.find<AuthCtrl>();
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  bool isOpenPollSelected = true;
  int page = 1;

  // Separate lists for open and closed
  final RxList<dynamic> openPollList = <dynamic>[].obs;
  final RxList<dynamic> closedPollList = <dynamic>[].obs;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    fetchPolls().applyLoader; // load open by default
  }

  Future fetchPolls({bool isRefresh = false}) async {
    final pollType = isOpenPollSelected ? 'true' : 'false';

    if (isRefresh) page = 1;

    AppUtils.log(
      "🔄 fetchPolls | type=$pollType | page=$page | refresh=$isRefresh",
    );

    await authCtrl
        .getPollList(pollType, page: page)
        .then((newPolls) {
          if (newPolls.isEmpty) {
            if (isRefresh) {
              _refreshController.refreshCompleted();
            } else {
              _refreshController.loadNoData();
            }
            return;
          }

          final targetList = isOpenPollSelected ? openPollList : closedPollList;

          final existingIds = targetList
              .map(
                (e) =>
                    e is Map<String, dynamic> ? e['_id'] : (e as PostData).id,
              )
              .whereType<String>()
              .toSet();

          final uniqueNewPolls = newPolls
              .where((p) => !existingIds.contains(p['_id']))
              .toList();

          if (isRefresh) {
            if (uniqueNewPolls.isNotEmpty) {
              // ✅ Prepend new items at the top
              targetList.insertAll(0, uniqueNewPolls);
              AppUtils.log(
                "✅ Added ${uniqueNewPolls.length} new polls on refresh. Total=${targetList.length}",
              );
            } else {
              AppUtils.log(
                "ℹ️ No new polls found on refresh, keeping existing list.",
              );
            }
            _refreshController.refreshCompleted();
          } else {
            // Load more → append at bottom
            targetList.addAll(uniqueNewPolls);
            AppUtils.log(
              "✅ Appended ${uniqueNewPolls.length} polls on load more. Total=${targetList.length}",
            );
            _refreshController.loadComplete();
          }
        })
        .catchError((err) {
          AppUtils.log("❌ Error fetching polls: $err");
          if (isRefresh) {
            _refreshController.refreshFailed();
          } else {
            _refreshController.loadFailed();
          }
        });
  }

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
    } catch (e) {
      AppUtils.log("Error retrieving address: $e");
    }
    return "No Address Found";
  }

  Future postliker(String selectedpostId) async {
    await profileCtrl.likeposts(selectedpostId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextView(style: 24.txtSBoldprimary, text: "Polls"),
      ),
      body: Column(
        children: [
          /// Tabs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    padding: 10.vertical + 10.horizontal,
                    onTap: () {
                      setState(() {
                        isOpenPollSelected = true;
                        page = 1;
                      });
                      fetchPolls(isRefresh: true).applyLoader;
                    },
                    buttonColor: isOpenPollSelected
                        ? AppColors.btnColor
                        : AppColors.primaryColor,
                    label: "Open Polls".toUpperCase(),
                    labelStyle: 17.txtBoldWhite,
                  ),
                ),
                10.width,
                Expanded(
                  child: AppButton(
                    padding: 10.vertical + 10.horizontal,
                    onTap: () {
                      setState(() {
                        isOpenPollSelected = false;
                        page = 1;
                      });
                      fetchPolls(isRefresh: true).applyLoader;
                    },
                    buttonColor: !isOpenPollSelected
                        ? AppColors.btnColor
                        : AppColors.primaryColor,
                    label: "Closed Polls".toUpperCase(),
                    labelStyle: 17.txtBoldWhite,
                  ),
                ),
              ],
            ),
          ),

          /// Poll list
          Expanded(
            child: Obx(() {
              // if (authCtrl.isLoading.value) {
              //   return Center(child: AppLoader.loaderWidget());
              // }

              final pollList = isOpenPollSelected
                  ? openPollList
                  : closedPollList;

              if (pollList.isEmpty) {
                return Center(
                  child: TextView(
                    text:
                        'No ${isOpenPollSelected ? "open" : "closed"} polls available',
                    style: TextStyle(color: AppColors.grey),
                  ),
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () {
                  page = 1;
                  fetchPolls(isRefresh: true);
                },
                onLoading: () {
                  page++;
                  fetchPolls();
                },
                child: ListView.builder(
                  itemCount: pollList.length,
                  itemBuilder: (context, index) {
                    final raw = pollList[index];

                    PostData _ensurePostData(dynamic raw) {
                      if (raw is PostData) return raw;
                      if (raw is Map<String, dynamic>) {
                        return PostData.fromJson(raw);
                      }
                      throw Exception("Invalid poll item type");
                    }

                    final PostData item = _ensurePostData(raw);

                    final header = postCardHeader(
                      item,
                      onBlockUser: () {},
                      onRemovePostAction: () {
                        pollList.removeAt(index);
                      },
                    );

                    final footer = postFooter(
                      context: context,
                      item: item,
                      postLiker: (value) {
                        postliker(value);
                        final count = item.likeCount ?? 0;
                        final status = item.isLikedByUser ?? false;
                        final updated = item.copyWith(
                          isLikedByUser: !status,
                          likeCount: status ? count - 1 : count + 1,
                        );
                        pollList[index] = updated;
                        pollList.refresh();
                      },
                      updateCommentCount: (newCount) {
                        final updated = item.copyWith(commentCount: newCount);
                        pollList[index] = updated;
                        pollList.refresh();
                      },
                      updatePostOnAction: (commentCount) async {
                        final postId = item.id!;
                        final value = await profileCtrl.getSinglePostData(
                          postId,
                        );
                        final updated = item.copyWith(
                          commentCount:
                              commentCount ??
                              value.commentCount ??
                              item.commentCount,
                        );
                        pollList[index] = updated;
                        pollList.refresh();
                      },
                    );

                    return PollCard(
                      footer: footer,
                      data: item,
                      header: header,
                      question: item.content ?? '',
                      options: item.options ?? [],
                      onPollAction: (String optionId) async {
                        // Validate item.id before making vote call
                        if (item.id == null || item.id!.isEmpty) {
                          AppUtils.log(
                            "ERROR: Poll item has no ID, cannot vote",
                          );
                          AppUtils.toastError("Unable to vote on this poll");
                          return;
                        }

                        try {
                          await profileCtrl
                              .givePollToHomePost(item, optionId)
                              .applyLoader;
                          final refreshed = await profileCtrl.getSinglePostData(
                            item.id!,
                          );
                          pollList[index] = refreshed;
                          pollList.refresh();
                        } catch (e) {
                          AppUtils.log("Error voting on poll: $e");
                          AppUtils.toastError("Failed to vote on poll");
                        }
                      },
                      showPollButton: false,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
