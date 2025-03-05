import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService with ChangeNotifier {

  final firebaseStorage = FirebaseStorage.instance;

// images are stored in firebase as download URLs
  List<String> _imageUrls = [];

// loading status
  bool _isLoading = false;

// uploading status
  bool _isUploading = false;

/*
  GETTERS
*/

  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

/*
  READ IMAGES
*/
  Future<void> fetchImages() async {
    // start loading..
    _isLoading = true;

    // get the list under the directory: uploaded_images/
    final ListResult result = await firebaseStorage.ref('uploaded_images/').listAll();

    // get the download URLs for each image
    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    // update URLs
    _imageUrls = urls;

    // loading finished..
    _isLoading = false;

    // update UI
    notifyListeners();
  }



/*
  DELETE IMAGE
*/


}