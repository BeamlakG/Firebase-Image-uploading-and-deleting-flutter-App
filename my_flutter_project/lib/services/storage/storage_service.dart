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

  - images are stored as download URLs.
    eg: https://firebasestorage.googleapis.com/v0/b/fir-masterclass...../uploaded_images/image_name.png

  - in order to delete, we need to know only the path of this image store in firebase
    ie: uploaded_images/image_name.png
*/

  Future<void> deleteImages(String imageUrl) async {
    try {
      // remove from local list
      _imageUrls.remove(imageUrl);

      // get path name and delete from firebase
      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    }

    //hundle errors
    catch (e){
      print("Error detecting image: $e");
    }

    //notify UI
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);

    // extracting the part of the url we need
    String encodedPath = uri.pathSegments.last;

    // url decoding the path
    return Uri.decodeComponent(encodedPath);
  }



}