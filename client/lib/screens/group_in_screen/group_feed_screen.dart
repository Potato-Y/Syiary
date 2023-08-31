import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syiary_client/models/response/post_model.dart';
import 'package:syiary_client/services/group/post_api_service.dart';

class GroupFeedScreen extends StatefulWidget {
  final String groupUri;

  const GroupFeedScreen({super.key, required this.groupUri});

  @override
  State<GroupFeedScreen> createState() => _GroupFeedScreenState();
}

class _GroupFeedScreenState extends State<GroupFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  List<PostModel> posts = [];
  int page = 0;
  bool isLoading = false;

  /// 마지막 페이지라면 true, 아니라면 false
  bool lastPage = true;

  @override
  void initState() {
    super.initState();

    // 첫 페이지의 포스트를 불러온다.
    _getMorePosts(page);

    // 스크롤이 맨 아래일 경우 새로 불러온다.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++; // 페이지를 증가한다.
        _getMorePosts(page); // page를 반환하여 새로운 페이지를 요청한다.
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        // 위로 올리면 새로고침 한다.
        onRefresh: () async {
          setState(() {
            posts = []; // 기존에 받아온 정보를 초기화한다.
            page = 0; // 페이지 카운터를 초기화 한다.
            _getMorePosts(page); // 0 페이지를 요청한다.
          });
        },
        child: ListView.builder(
          // 받아온 페이지를 표시한다.
          controller: _scrollController,
          itemCount: posts.length + 1,
          physics:
              const AlwaysScrollableScrollPhysics(), // 아이템이 적어도 스크롤이 작동하도록 한다.
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return _buildLoader();
            } else {
              return PostWidget(
                  post: posts[index]); // Post 위젯에 post 정보를 넘겨서 만들어온다.
            }
          },
        ),
      ),
    );
  }

  /// 새로운 포스트를 불러온다.
  Future _getMorePosts(int page) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      // 새로운 포스트를 불러온다.
      List<PostModel> loadPosts =
          await PostApiService().getPosts(widget.groupUri, page);

      setState(() {
        if (loadPosts.isEmpty) {
          // 더 이상 새로운 포스트가 없을 경우 표시한다.
          Fluttertoast.showToast(msg: '더 이상 포스트가 없습니다.');
          lastPage = true;
        } else {
          posts.addAll(loadPosts);
          lastPage = false;
        }

        isLoading = false;
      });
    }
  }

  /// 로딩 인디케이터를 생성한다.
  Widget _buildLoader() {
    return lastPage || page == 0 // 상황에 맞게 로딩 인디케이터를 표시한다.
        ? Container()
        : const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

/// Post 정보를 받아 Post 위젯을 반환한다.
class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PageController imagePageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    DateTime createAt = widget.post.createdAt!; // 편의를 위해 생성 시각을 변수로 선언한다.

    return Container(
      margin: const EdgeInsets.fromLTRB(
          10, 10, 10, 0), // 하단을 제외한 여백을 생성하여 포스트마다 간격을 벌려준다.
      decoration: BoxDecoration(
        // 테두리를 만들어준다.
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // 유저의 닉네임과 업로드 시간을 표시한다.
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(widget.post.createUser!.nickname!),
                const Text(' • '),
                Text(
                  '${createAt.year}.${createAt.month}.${createAt.day} ${_timeFormat00(createAt.hour)}:${_timeFormat00(createAt.minute)}',
                ),
              ],
            ),
          ),
          const Divider(
            // 구분선을 추가한다.
            height: 0,
          ),
          if (widget.post.files!.isNotEmpty) // 사진이 있을 경우 사진을 표시한다.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: PageView(
                    controller: imagePageController,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page; // 사용자가 보고 있는 페이지를 카운트한다.
                      });
                    },
                    children: [
                      for (var file in widget.post.files!)
                        Image.memory(
                          Uint8List.fromList(base64.decode(file)),
                          key: ValueKey(
                              file), // 사진을 이동할 때 깜빡이는 것을 방지하고자 넣었으나, 효과가 없다. 혹시 모를 추후 관리를 위해 추가.
                        ),
                    ],
                  ),
                ),
                const Padding(
                  // 구분선을 추가하며 하단 여백을 추가한다.
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                  child: Divider(
                    height: 0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child:
                      Text('[${currentPage + 1}/${widget.post.files!.length}]'),
                ), // 사용자가 보고 있는 사진 위치를 표시한다.
              ],
            ),
          if (widget.post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child: Text(widget.post.content!), // 사용자가 작성한 컨텐츠 내용이 표시된다.
            ),
        ],
      ),
    );
  }

  /// 시간 형식을 두 자리로 반환한다.
  String _timeFormat00(int num) {
    return '0$num'.substring(-1 + num.toString().length);
  }
}
