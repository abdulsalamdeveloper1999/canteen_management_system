import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../apis/impl/user_orders_impl.dart';

class UserOrdersPage extends StatefulWidget {
  @override
  _UserOrdersPageState createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();

    _loadOrders();
  }

  // Method to load orders based on the user's UID
  void _loadOrders() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _ordersFuture = UserOrdersServiceImpl().retrieveUserOrders(uid);
  }

  // Fetch item details from the items collection using item_id
  Future<Map<String, dynamic>> fetchItemDetails(String itemId) async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .doc('items/$itemId') // Assuming 'items' is the collection
          .get();

      log(documentSnapshot.exists.toString());

      if (documentSnapshot.exists) {
        log(documentSnapshot.data().toString());
        return documentSnapshot.data()!;
      } else {
        throw Exception('Item not found');
      }
    } catch (e) {
      throw Exception('Failed to load item details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading orders'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // final orderId = order['item'];
              // final placedAt = order['placed_at'];

              final placedAt =
                  DateTime.parse(order['placed_at'].toDate().toString());

              final status = order['status'];
              final items = order['items'];

              List<String> extractItemIds(List<Map<String, dynamic>> items) {
                return items.map((item) => item['item_id'] as String).toList();
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice: #${item['item_id'].length >= 6 ? item['item_id'].substring(0, 6) : item['item_id']}',
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 8),
                      Text(
                        'Placed on: ${DateFormat.yMMMd().add_jm().format(placedAt)}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 16,
                          color: status == 'Completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...items.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item Name: ${item['item_name']}\nQuantity: ${item['count']}\nTotal Charge: - \$${item['price']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 8),

                      // Fetch and display item details for each item in the order

                      ElevatedButton(
                        onPressed: () {
                          // Handle order details navigation or actions here
                          itemDetailWidget(context, items);
                        },
                        child: Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<dynamic> itemDetailWidget(BuildContext context, items) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...items.map((item) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchItemDetails(item['item_id']),
                    builder: (context, itemSnapshot) {
                      if (itemSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (itemSnapshot.hasError) {
                        return Text('Error loading item details');
                      }

                      if (itemSnapshot.hasData) {
                        final itemDetails = itemSnapshot.data!;
                        final itemName = itemDetails['item_name'];
                        final itemImageUrl = itemDetails['imageUrl'];
                        final itemPrice = itemDetails['price'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Item Name: $itemName',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                fit: BoxFit.cover,
                                itemImageUrl,
                                height: 200,
                                width: 200,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Price: \$${itemPrice.toString()}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Quantity: ${item['count']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Total Charge: \$${(itemPrice * item['count']).toString()}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        );
                      }

                      return Container(); // Empty container if no data
                    },
                  );
                }).toList(),
              ],
            ),
          );
        });
  }
}
