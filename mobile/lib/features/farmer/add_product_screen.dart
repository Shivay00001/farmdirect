import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';
import '../../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double quantity = 0;
  double price = 0;
  String category = 'GRAINS';
  List<XFile> _images = [];
  bool _isUploading = false;
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isUploading = true);

      try {
        // Prepare Multipart Request
        var uri = Uri.parse('${AppConstants.baseUrl}/products/create');
        var request = http.MultipartRequest('POST', uri);
        
        // Headers
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) request.headers['Authorization'] = 'Bearer $token';

        // Fields
        request.fields['name'] = name;
        request.fields['quantity'] = quantity.toString();
        request.fields['price_per_unit'] = price.toString();
        request.fields['category'] = category;
        request.fields['unit'] = 'kg';
        request.fields['min_order_qty'] = '1';
        
        // Files
        for (var img in _images) {
            request.files.add(await http.MultipartFile.fromPath('images', img.path));
        }

        var response = await request.send();
        
        if (response.statusCode == 201) {
            if (mounted) Navigator.pop(context, true);
        } else {
             final respStr = await response.stream.bytesToString();
             throw Exception('Failed: ${response.statusCode} $respStr');
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onSaved: (v) => name = v!,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => quantity = double.parse(v!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price per kg (₹)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => price = double.parse(v!),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ['GRAINS', 'VEGETABLES', 'FRUITS'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                   ElevatedButton.icon(
                     onPressed: _pickImage, 
                     icon: const Icon(Icons.photo_camera), 
                     label: const Text('Add Photos')
                   ),
                   const SizedBox(width: 10),
                   Text('${_images.length} selected'),
                ],
              ),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(File(_images[i].path), width: 100, height: 100, fit: BoxFit.cover)
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _isUploading 
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('List Product')),
            ],
          ),
        ),
      ),
    );
  }
}
