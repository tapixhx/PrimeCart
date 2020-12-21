import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _initValues = {
    'title' : '',
    'description' : '',
    'price' : '',
    'imageUrl' : '',
  };
  var _isInIt = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInIt) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if(productId != null) {
        _editedProduct = Provider.of<Products>(context, listen:false).finById(productId);
        _initValues = {
          'title' : _editedProduct.title,
          'price' : _editedProduct.price.toString(),
          'description' : _editedProduct.description,
          // 'imageUrl' : _editedProduct.imageUrl,
          'imageUrl' : '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
   if(!_imageUrlFocusNode.hasFocus) {
     setState(() {});
   } 
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if(!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null) {
      await Provider.of<Products>(context, listen:false).updateProduct(_editedProduct.id, _editedProduct);  
    }
    else {
      try {
        await Provider.of<Products>(context, listen:false)
        .addProduct(_editedProduct);
      }
      catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
              title: Text('An error occured!'),
              content: Text('Something went wrong!'),
              actions: [
                FlatButton(
                  child: Text('Okay!'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            )
        );
      } 
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    Navigator.of(context).pop();
    setState(() {
      _isLoading = false;
    });
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit details'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading 
      ? Center(
        child: CircularProgressIndicator(),
      ) 
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key:_form,
          child: ListView(children: [
            TextFormField(
              initialValue: _initValues['title'],
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value) {
                if(value.isEmpty) {
                  return 'Please provide a title';
                }
                else {
                  return null;
                }
              },
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,
                  title: value, 
                  description: _editedProduct.description, 
                  price: _editedProduct.price, 
                  imageUrl: _editedProduct.imageUrl,
                );
              },
            ),
            TextFormField(
              initialValue: _initValues['price'],
              decoration: InputDecoration(labelText: 'Price'),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              focusNode: _priceFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              validator: (value) {
                if(value.isEmpty) {
                  return 'Please provide a price';
                }
                if(double.tryParse(value) == null) {
                  return 'Please enter a valid number.';
                }
                if(double.parse(value) <= 0) {
                  return 'Please enter a number greater than zero.';
                }
                else {
                  return null;
                }
              },
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite, 
                  title: _editedProduct.title, 
                  description: _editedProduct.description, 
                  price: double.parse(value), 
                  imageUrl: _editedProduct.imageUrl,
                );
              },
            ),
            TextFormField(
              initialValue: _initValues['description'],
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              focusNode: _descriptionFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              validator: (value) {
                if(value.isEmpty) {
                  return 'Please provide a description';
                }
                if(value.length < 10) {
                  return 'Should be atleast 10 characters long.';
                }
                else {
                  return null;
                }
              },
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,
                  title: _editedProduct.title, 
                  description: value, 
                  price: _editedProduct.price, 
                  imageUrl: _editedProduct.imageUrl,
                );
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              Container(
                width:100,
                height:100,
                margin: EdgeInsets.only(top:8, right:10),
                decoration: BoxDecoration(
                  border: Border.all(width:1, color:Colors.grey),
                ),
                child: _imageUrlController.text.isEmpty 
                ? Text('Enter image URL')
                : FittedBox(
                  child: Image.network(
                    _imageUrlController.text,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Image URL'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller: _imageUrlController,
                    focusNode: _imageUrlFocusNode,
                    onFieldSubmitted: (_) {
                      _saveForm();
                    },
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please provide a Image URL';
                      }
                      if(!value.startsWith('http') && !value.startsWith('https')) {
                        return 'Enter a valid URL';
                      }
                      else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite, 
                        title: _editedProduct.title, 
                        description: _editedProduct.description, 
                        price: _editedProduct.price, 
                        imageUrl: value,
                      );
                    },
                ),
              ),
            ],)
          ]),
        ),
      ),
    );
  }
}