import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';


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



  Future<void> fetchImages() async {
    try {
      _isLoading = true;
      notifyListeners();

      final ListResult result = await firebaseStorage.ref('uploaded_images/').listAll();

      if (result.items.isNotEmpty) {
        final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
        _imageUrls = urls;
        print("Fetched image URLs: $urls");
      } else {
        _imageUrls.clear(); // No images found
        print("No images found in Firebase Storage");
      }
    } catch (e) {
      print("Error fetching images: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


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

    // Extract the full path after "/o/"
    String path = uri.path.split('/o/').last.split('?').first;

    return Uri.decodeComponent(path);
  }


  Future<void> uploadImage() async {
    _isUploading = true;
    notifyListeners();

    final ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      _isUploading = false;
      notifyListeners();
      return;
    }

    try {
      String filePath = 'uploaded_images/${DateTime.now().millisecondsSinceEpoch}.png';
      print("Uploading file to: $filePath");

      if (kIsWeb) {
        // Read bytes for web upload
        final bytes = await image.readAsBytes();
        final metadata = SettableMetadata(contentType: 'image/png');
        await firebaseStorage.ref(filePath).putData(bytes, metadata);
      } else {
        // Mobile file upload
        File file = File(image.path);
        await firebaseStorage.ref(filePath).putFile(file);
      }

      // Fetch download URL
      String downloadURL = await firebaseStorage.ref(filePath).getDownloadURL();
      _imageUrls.add(downloadURL);
      notifyListeners();

      print("Image uploaded successfully: $downloadURL");
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


}