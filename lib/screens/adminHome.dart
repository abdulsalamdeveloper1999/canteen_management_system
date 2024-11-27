import 'dart:developer';
import 'package:canteen_food_ordering_app/notifiers/cloundindary_service.dart';
import 'package:canteen_food_ordering_app/notifiers/image_handler.dart';
import 'package:canteen_food_ordering_app/screens/food_card_widget.dart';
import 'package:canteen_food_ordering_app/apis/foodAPIs.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/widgets/customRaisedButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:canteen_food_ordering_app/models/food.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyEdit = GlobalKey<FormState>();
  List<Food> _foodItems = [];
  String name = '';
  Uint8List? _webImage;

  signOutUser() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    if (authNotifier.user != null) {
      signOut(authNotifier, context);
    }
  }

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    getUserDetails(authNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cassia'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            onPressed: () {
              signOutUser();
            },
          )
        ],
      ),
      // ignore: unrelated_type_equality_checks
      body: (authNotifier.userDetails == null)
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text("No Items to display"),
            )
          : (authNotifier.userDetails.role == 'admin')
              ? adminHome(context)
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text("No Items to display"),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return popupForm(context);
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 63, 111, 1),
      ),
    );
  }

  Widget adminHome(context) {
    // AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          Card(
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Search...'),
              onChanged: (val) {
                setState(() {
                  name = val;
                });
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('items').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.length > 0) {
                _foodItems = [];
                snapshot.data!.docs.forEach(
                  (item) {
                    _foodItems.add(
                      Food(
                        item.id,
                        item['item_name'],
                        item['total_qty'],
                        item['price'],
                        item['imageUrl']!,
                      ),
                    );
                  },
                );
                List<Food> _suggestionList = (name == '')
                    ? _foodItems
                    : _foodItems
                        .where((element) => element.itemName
                            .toLowerCase()
                            .contains(name.toLowerCase()))
                        .toList();
                if (_suggestionList.length > 0) {
                  return Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suggestionList.length,
                          itemBuilder: (context, int i) {
                            log(_suggestionList[i].imageUrl!);
                            return FoodCard(
                              itemName: _suggestionList[i].itemName ?? '',
                              price: _suggestionList[i].price,
                              quantity: _suggestionList[i].totalQty,
                              image: _suggestionList[i].imageUrl!,
                              delete: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return popupDelete(
                                        context,
                                        _suggestionList[i],
                                      );
                                    });
                              },
                              edit: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return popupEditForm(
                                      context,
                                      _suggestionList[i],
                                    );
                                  },
                                );

                                // onLongPress: () {
                                //   showDialog(
                                //       context: context,
                                //       barrierDismissible: false,
                                //       builder: (BuildContext context) {
                                //         return popupDeleteOrEmpty(
                                //           context,
                                //           _suggestionList[i],
                                //         );
                                //       });
                                // },
                                // onTap: () {
                                // showDialog(
                                //   context: context,
                                //   barrierDismissible: false,
                                //   builder: (BuildContext context) {
                                //     return popupEditForm(
                                //       context,
                                //       _suggestionList[i],
                                //     );
                                //   },
                                //   );
                              },
                            );
                          }));
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text("No Items to display"),
                  );
                }
              } else {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text("No Items to display"),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget popupEditForm(context, Food data) {
    String itemName = data.itemName;
    String ImageUrl = data.imageUrl!;
    int totalQty = data.totalQty, price = data.price;

    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKeyEdit,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Edit Food Item",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 63, 111, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: itemName,
                  validator: (String? value) {
                    if (value!.length < 3)
                      return "Not a valid name";
                    else
                      return null;
                  },
                  keyboardType: TextInputType.text,
                  onSaved: (String? value) {
                    itemName = value!;
                  },
                  cursorColor: Color.fromRGBO(255, 63, 111, 1),
                  decoration: InputDecoration(
                    hintText: 'Food Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.fastfood,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: price.toString(),
                  validator: (String? value) {
                    if (value!.length > 3)
                      return "Not a valid price";
                    else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(),
                  onSaved: (String? value) {
                    price = int.parse(value!);
                  },
                  cursorColor: Color.fromRGBO(255, 63, 111, 1),
                  decoration: InputDecoration(
                    hintText: 'Price in £',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.attach_money,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: totalQty.toString(),
                  validator: (String? value) {
                    if (value!.length > 4)
                      return "QTY cannot be above 4 digits";
                    else if (int.tryParse(value) == null)
                      return "Not a valid integer";
                    else
                      return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(),
                  onSaved: (String? value) {
                    totalQty = int.parse(value!);
                  },
                  cursorColor: Color.fromRGBO(255, 63, 111, 1),
                  decoration: InputDecoration(
                    hintText: 'Total QTY',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromRGBO(255, 63, 111, 1),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (_formKeyEdit.currentState!.validate()) {
                      _formKeyEdit.currentState!.save();
                      editItem(
                        itemName,
                        price,
                        totalQty,
                        context,
                        data.id,
                        ImageUrl,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: CustomRaisedButton(buttonText: 'Edit Item'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CustomRaisedButton(
                    buttonText: 'Cancel',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget popupForm(BuildContext context) {
    String itemName = '';
    int totalQty = 0;
    int price = 0;

    return AlertDialog(
      content: Consumer<ImagePickerProvider>(
          builder: (context, imagePickerProvider, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "New Food Item",
                      style: TextStyle(
                        color: Color.fromRGBO(255, 63, 111, 1),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.length < 3)
                          return "Not a valid name";
                        else
                          return null;
                      },
                      keyboardType: TextInputType.text,
                      onSaved: (String? value) {
                        itemName = value!;
                      },
                      cursorColor: Color.fromRGBO(255, 63, 111, 1),
                      decoration: InputDecoration(
                        hintText: 'Food Name',
                        icon: Icon(Icons.fastfood,
                            color: Color.fromRGBO(255, 63, 111, 1)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.length > 3)
                          return "Not a valid price";
                        else if (int.tryParse(value) == null)
                          return "Not a valid integer";
                        else
                          return null;
                      },
                      keyboardType: TextInputType.number,
                      onSaved: (String? value) {
                        price = int.parse(value!);
                      },
                      cursorColor: Color.fromRGBO(255, 63, 111, 1),
                      decoration: InputDecoration(
                        hintText: 'Price in £',
                        icon: Icon(Icons.attach_money,
                            color: Color.fromRGBO(255, 63, 111, 1)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.length > 4)
                          return "QTY cannot be above 4 digits";
                        else if (int.tryParse(value) == null)
                          return "Not a valid integer";
                        else
                          return null;
                      },
                      keyboardType: TextInputType.number,
                      onSaved: (String? value) {
                        totalQty = int.parse(value!);
                      },
                      cursorColor: Color.fromRGBO(255, 63, 111, 1),
                      decoration: InputDecoration(
                        hintText: 'Total QTY',
                        icon: Icon(Icons.add_shopping_cart,
                            color: Color.fromRGBO(255, 63, 111, 1)),
                      ),
                    ),
                  ),
                  imagePickerProvider.pickedImage == null
                      ? Text("No file selected.")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'File name: ${imagePickerProvider.pickedImage!.files.first.name}'),
                            SizedBox(height: 10),
                            // If the file is an image, you could display a preview
                            if (imagePickerProvider.pickedImage!.files.first.extension == 'jpg' ||
                                imagePickerProvider
                                        .pickedImage!.files.first.extension ==
                                    'png' ||
                                imagePickerProvider
                                        .pickedImage!.files.first.extension ==
                                    'jpeg')
                              Image.memory(
                                imagePickerProvider.imageBytes!,
                                height: 100,
                                width: 100,
                              ),
                            SizedBox(height: 10),
                            // Remove button to reset the picked image
                            ElevatedButton(
                              onPressed: () {
                                imagePickerProvider.removeImage();
                              },
                              child: Text('Remove Image'),
                            ),
                          ],
                        ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Trigger the image picker
                        imagePickerProvider.pickImage();
                      },
                      icon: Icon(Icons.image),
                      label: Text('Select Image'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate() &&
                            imagePickerProvider.imageBytes != null &&
                            imagePickerProvider.imageBytes!.isNotEmpty) {
                          _formKey.currentState!.save();

                          // Upload the image to Cloudinary
                          try {
                            String? img = await CloudinaryService().uploadImage(
                                fileBytes: imagePickerProvider.imageBytes!);

                            if (img != null && img.isNotEmpty) {
                              // Call the addNewItem function after successful image upload
                              addNewItem(
                                  itemName, price, totalQty, context, img);
                            } else {
                              toast('Image upload failed or image is required');
                            }
                          } catch (e) {
                            toast('Error uploading image: ${e.toString()}');
                          }
                        } else {
                          toast(
                              'Please select an image and fill in the form correctly');
                        }
                      },
                      child: CustomRaisedButton(buttonText: 'Add Item'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CustomRaisedButton(
                        buttonText: 'Cancel',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget popupDelete(context, Food data) {
    return AlertDialog(
        content: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  deleteItem(data.id, context);
                  Navigator.pop(context);
                },
                child: CustomRaisedButton(buttonText: 'Delete Item'),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: GestureDetector(
            //     onTap: () {
            //       editItem(data.itemName, data.price, 0, context, data.id,
            //           data.images!);
            //     },
            //     child: CustomRaisedButton(buttonText: 'Edit Item'),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CustomRaisedButton(
                  buttonText: 'Cancel',
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
