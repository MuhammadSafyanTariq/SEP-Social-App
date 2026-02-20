import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/data/repository/iTempRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/postDetail/post_detail_screen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

class PostDeepLinkLoaderScreen extends StatefulWidget {
  final String postId;
  const PostDeepLinkLoaderScreen({super.key, required this.postId});

  @override
  State<PostDeepLinkLoaderScreen> createState() => _PostDeepLinkLoaderScreenState();
}

class _PostDeepLinkLoaderScreenState extends State<PostDeepLinkLoaderScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    try {
      AppUtils.log('🔗 DeepLinkLoader: fetching post ${widget.postId}');
      
      // Use the correct getSinglePost method (not getPostById!)
      final repo = ITempRepository();
      final res = await repo.getSinglePost(widget.postId);

      AppUtils.log('🔗 DeepLinkLoader: API response - isSuccess: ${res.isSuccess}');
      AppUtils.log('🔗 DeepLinkLoader: API response - data: ${res.data?.id}');

      if (!mounted) return;

      if (res.isSuccess && res.data != null && (res.data!.id?.isNotEmpty ?? false)) {
        AppUtils.log('✅ DeepLinkLoader: post fetched successfully!');
        PostData postData = res.data!;
        // If API did not populate post owner (user array empty), fetch profile so name & picture show
        if (postData.user.isEmpty &&
            postData.userId != null &&
            postData.userId!.isNotEmpty) {
          try {
            final profile = await ProfileCtrl.find.getFriendProfileDetails(
              postData.userId!,
            );
            final postUser = User(
              id: profile.id,
              name: profile.name ?? profile.userName,
              image: profile.image,
            );
            postData = postData.copyWith(user: [postUser]);
            AppUtils.log('🔗 DeepLinkLoader: filled post owner from profile');
          } catch (e) {
            AppUtils.log('🔗 DeepLinkLoader: could not load post owner: $e');
          }
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(postData: postData),
          ),
        );
        return;
      }

      // If we get here, something went wrong
      final errorMsg = (res.getError ?? res.exception?.toString() ?? 'Post not found').toString();
      AppUtils.log('❌ DeepLinkLoader: Failed - $errorMsg');
      
      setState(() {
        _loading = false;
        _error = errorMsg;
      });
      AppUtils.toastError('Post not found');
    } catch (e) {
      AppUtils.log('❌ DeepLinkLoader exception: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load post: $e';
      });
      AppUtils.toastError('Could not load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar2(
          title: 'Opening post',
          prefixImage: 'back',
          onPrefixTap: () => context.pop(),
          backgroundColor: Colors.white,
        ),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error ?? 'Could not open post'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
      ),
    );
  }
}

