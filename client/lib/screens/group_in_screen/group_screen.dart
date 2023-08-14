import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syiary_client/models/response/group_info_model.dart';
import 'package:syiary_client/services/api_services.dart';

import 'add_post_screen.dart';

class GroupScreen extends StatelessWidget {
  final String groupUri;

  const GroupScreen({super.key, required this.groupUri});

  Future<GroupInfoModel> _loadGroup() async {
    try {
      GroupInfoModel group = await ApiService.getGroupInfo(groupUri);
      return group;
    } catch (e) {
      Fluttertoast.showToast(msg: '그룹 정보를 불러오지 못 하였습니다.');
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(groupUri);
    return FutureBuilder(
      future: _loadGroup(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.groupName!),
            ),
            body: GroupBodyScreen(
              groupUri: groupUri,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const CircularProgressIndicator(),
        );
      },
    );
  }
}

/// Group 기본 정보가 불러와진 뒤 하단의 body 영역
class GroupBodyScreen extends StatefulWidget {
  final String groupUri;
  const GroupBodyScreen({super.key, required this.groupUri});

  @override
  State<GroupBodyScreen> createState() => _GroupBodyScreenState();
}

class _GroupBodyScreenState extends State<GroupBodyScreen> {
  final _pageController = PageController();

  // page view 페이지 넘버
  int _currentIndex = 0;

  /// pageview 해당 페이지로 부드럽게 이동
  void _onTab(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(microseconds: 350),
      curve: Curves.easeIn,
    );
  }

  /// 해당 페이지로 변경
  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: [
          // feed
          Container(
            child: const Text('feed container'),
          ),
          // feed add
          AddPostScreen(
            groupUri: widget.groupUri,
            goChangePage: _onTab,
          ),
          // my page
          Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _onTab,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed_outlined,
              size: 20,
            ),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
              size: 20,
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list_alt_outlined,
              size: 20,
            ),
            label: 'My',
          ),
        ],
      ),
    );
  }
}
