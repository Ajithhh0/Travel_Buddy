import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({Key? key}) : super(key: key);

  @override
  _DocumentUploadState createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  late CollectionReference<Map<String, dynamic>> documentsCollection;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    Firebase.initializeApp().then((value) {
      setState(() {
        documentsCollection = FirebaseFirestore.instance.collection('documents');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Upload'),
        actions: [
          IconButton(
            onPressed: _addRow,
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: _removeRow,
            icon: Icon(Icons.remove),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < _uploadedDocuments.length; i++)
              DocumentRow(
                documentName: _uploadedDocuments[i],
                onUpload: (String? fileName) {
                  setState(() {
                    _uploadedDocuments[i] = fileName ?? '';
                  });
                },
                onDocumentUploaded: (File file) {
                  _uploadDocumentToFirestore(file);
                },
              ),
          ],
        ),
      ),
    );
  }

  // List to store the uploaded documents
  List<String> _uploadedDocuments = [''];

  // Function to add a new row to the table
  void _addRow() {
    setState(() {
      _uploadedDocuments.add('');
    });
  }

  // Function to remove the last row from the table
  void _removeRow() {
    setState(() {
      if (_uploadedDocuments.length > 1) {
        _uploadedDocuments.removeLast();
      }
    });
  }

  // Function to upload document to Firestore and get download URL
  Future<void> _uploadDocumentToFirestore(File file) async {
    if (documentsCollection != null) {
      try {
        // Upload file to Firebase Storage
        String fileName = file.path.split('/').last;
        Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Get download URL
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Upload document to Firestore
        await documentsCollection.add({
          'name': fileName,
          'url': downloadURL,
          // You can add more fields as needed
        });
      } catch (e) {
        print('Error uploading document: $e');
        // Handle error
      }
    } else {
      print('Firestore collection is not initialized.');
      // Handle error
    }
  }
}

class DocumentRow extends StatefulWidget {
  final String documentName;
  final ValueChanged<String?> onUpload;
  final ValueChanged<File> onDocumentUploaded;

  const DocumentRow({
    Key? key,
    required this.documentName,
    required this.onUpload,
    required this.onDocumentUploaded,
  }) : super(key: key);

  @override
  _DocumentRowState createState() => _DocumentRowState();
}

class _DocumentRowState extends State<DocumentRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Travel Documents',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(widget.documentName),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
            onPressed: _uploadDocument,
            icon: Icon(Icons.upload_file),
          ),
        ),
      ],
    );
  }

  // Function to handle document upload
  void _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      widget.onUpload(result.files.single.name);
      widget.onDocumentUploaded(File(result.files.single.path!));
    } else {
      // User canceled the picker
    }
  }
}
