import 'package:flutter/material.dart';
import 'package:my_flutter_project/services/storage/storage_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Fetch images after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchImages();
    });
  }

  // Fetch images from Firebase Storage
  Future<void> fetchImages() async {
    try {
      await Provider.of<StorageService>(context, listen: false).fetchImages();
    } catch (e) {
      print("Error fetching images: $e");
      // Optionally, show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch images: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        final List<String> imageUrls = storageService.imageUrls;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Image Gallery'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => storageService.uploadImage(),
            child: const Icon(Icons.add),
          ),
          body: storageService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : imageUrls.isEmpty
              ? const Center(child: Text("No images found"))
              : ListView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final String imageUrl = imageUrls[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    // Display image
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                    // Delete button
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => storageService.deleteImages(imageUrl),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_flutter_project/services/storage/storage_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    fetchImages();
  }

  //fetchImages
  Future<void> fetchImages() async{
    await Provider.of<StorageService>(context, listen: false).fetchImages();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
        builder: (context, storageService, child){
          final List<String> imageUrls = storageService.imageUrls;
          return Scaffold(
            floatingActionButton: FloatingActionButton(
                onPressed: () => storageService.uploadImage(),
              child: const Icon(Icons.add),
            ),

            body: ListView.builder(
              itemCount: imageUrls.length,
                itemBuilder: (context, index){

                  final String imageUrl = imageUrls[index];

                  return Image.network(imageUrl);
                }

            ),

          );
        },
    );
  }
}
*/
