import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syiary_client/services/api_services.dart';

import '../../themes/app_original_color.dart';

class AddPostScreen extends StatefulWidget {
  final String groupUri;

  const AddPostScreen({super.key, required this.groupUri});

  @override
  State<AddPostScreen> createState() => AddPostScreenState();
}

class AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile?> _pickedImages = [];

  /// 이미지 여러개 불러오기
  void getMultiImage() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      setState(() {
        _pickedImages.addAll(images);
      });
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: '지원하지 않는 이미지가 포함되어있습니다.');
    }
  }

  void resetScreen() async {
    setState(() {
      _textEditingController.text = '';
      _pickedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: appOriginalColor.shade100,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('사진 추가하기'),
                    Row(
                      children: [
                        const SizedBox(
                          // 사진을 추가한 뒤, 높이가 바뀌지 않도록 설정
                          height: 60,
                        ),
                        IconButton(
                          onPressed: () => getMultiImage(),
                          icon: const Icon(Icons.add),
                        ),
                        if (_pickedImages.isNotEmpty)
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  width: 10,
                                ),
                                itemCount: _pickedImages.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Image.file(
                                    File(_pickedImages[index]!.path),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: appOriginalColor.shade100,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: TextField(
                        controller: _textEditingController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // null이 아닌 이미지만 필터링한다.
                    List<XFile> nonNullImages = _pickedImages
                        .where((image) => image != null)
                        .map((image) => image!)
                        .toList();

                    try {
                      await ApiService.uploadPost(widget.groupUri,
                          content: _textEditingController.text,
                          files: nonNullImages);

                      Fluttertoast.showToast(msg: '전송에 성공하였습니다.');
                      resetScreen();
                    } catch (e) {
                      Fluttertoast.showToast(msg: '업로드에 실패하였습니다.');
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: const Text('전송'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
