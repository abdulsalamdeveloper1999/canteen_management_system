import 'package:flutter/material.dart';

class FoodCardHome extends StatelessWidget {
  final String itemName;
  final int price;
  Widget icon;

  final String image;
  void Function() toCart;
  // void Function() edit;

  FoodCardHome({
    Key? key,
    required this.icon,
    required this.itemName,
    required this.price,
    required this.image,
    required this.toCart,
    // required this.edit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Price: \$${price}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(onTap: toCart, child: icon),
                // GestureDetector(
                //   onTap: edit,
                //   child: Icon(
                //     Icons.edit,
                //     color: Colors.black,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
