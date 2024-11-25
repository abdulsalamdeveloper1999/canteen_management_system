import 'dart:developer';

import 'package:canteen_food_ordering_app/models/food.dart';
import 'package:canteen_food_ordering_app/models/user.dart';
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/screens/adminHome.dart';
import 'package:canteen_food_ordering_app/screens/login.dart';
import 'package:canteen_food_ordering_app/screens/navigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../widgets/loading_widget.dart';

void toast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white);
}

login(User user, AuthNotifier authNotifier, BuildContext context) async {
  showLoadingDialog(context);
  try {
    final userCredential = await auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.email, password: user.password);

    if (userCredential.user != null) {
      // if (!userCredential.user!.emailVerified) {
      //   await auth.FirebaseAuth.instance.signOut();
      //   hideLoadingDialog(context);
      //   toast("Email ID not verified");
      //   return;
      // }

      log("Log In: ${userCredential.user}");
      authNotifier.setUser(userCredential.user!);
      await getUserDetails(authNotifier);
      log("done");
      hideLoadingDialog(context);

      if (authNotifier.userDetails.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => AdminHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  NavigationBarPage(selectedIndex: 1)),
        );
      }
    }
  } catch (error) {
    hideLoadingDialog(context);
    toast(error.toString());
    log(error.toString());
    return;
  }
}

signUp(User user, AuthNotifier authNotifier, BuildContext context) async {
  showLoadingDialog(context);
  bool userDataUploaded = false;

  try {
    final userCredential = await auth.FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: user.email.trim(), password: user.password);

    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(user.displayName);
      // await userCredential.user!.sendEmailVerification();

      log("Sign Up: ${userCredential.user}");
      await uploadUserData(user, userDataUploaded);
      await auth.FirebaseAuth.instance.signOut();
      authNotifier.setUser(null);
      hideLoadingDialog(context);
      // toast("Verification link is sent to ${user.email}");
      Navigator.pop(context);
    }
  } catch (error) {
    hideLoadingDialog(context);
    toast(error.toString());
    log(error.toString());
    return;
  }
}

getUserDetails(AuthNotifier authNotifier) async {
  final docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(authNotifier.user!.uid)
      .get();

  if (docSnapshot.exists) {
    authNotifier.setUserDetails(User.fromMap(docSnapshot.data()!));
  } else {
    log("User document does not exist");
  }
}

uploadUserData(User user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  final currentUser = await auth.FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final userRef = FirebaseFirestore.instance.collection('users');
  final cartRef = FirebaseFirestore.instance.collection('carts');

  user.uuid = currentUser.uid;
  if (!userDataUploadVar) {
    await userRef.doc(currentUser.uid).set(user.toMap());
    await cartRef.doc(currentUser.uid).set({});
    userDataUploadVar = true;
  }
  log('user data uploaded successfully');
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  final firebaseUser = auth.FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    await getUserDetails(authNotifier);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await auth.FirebaseAuth.instance.signOut();
  authNotifier.setUser(null);
  log('log out');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
  );
}

forgotPassword(
    User user, AuthNotifier authNotifier, BuildContext context) async {
  showLoadingDialog(context);
  try {
    await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
    hideLoadingDialog(context);
    toast("Reset Email has sent successfully");
    Navigator.pop(context);
  } catch (error) {
    hideLoadingDialog(context);
    toast(error.toString());
    log(error.toString());
  }
}

addToCart(Food food, BuildContext context) async {
  try {
    showLoadingDialog(context);
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      hideLoadingDialog(context);
      toast("Please login first!");
      return;
    }

    final cartRef = FirebaseFirestore.instance.collection('carts');
    final cartSnapshot =
        await cartRef.doc(currentUser.uid).collection('items').get();

    if (cartSnapshot.docs.length >= 10) {
      hideLoadingDialog(context);
      toast("Cart cannot have more than 10 items!");
      return;
    }

    await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .doc(food.id)
        .set({"count": 1});

    hideLoadingDialog(context);
    toast("Added to cart successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to add to cart!");
    log(error.toString());
  }
}

removeFromCart(Food food, BuildContext context) async {
  try {
    showLoadingDialog(context);

    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      toast("Please login first!");
      hideLoadingDialog(context);
      return;
    }

    final cartRef = FirebaseFirestore.instance.collection('carts');
    await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .doc(food.id)
        .delete();

    toast("Removed from cart successfully!");
  } catch (error) {
    log("Error removing item from cart: $error");
    toast("Failed to remove item from cart!");
  } finally {
    hideLoadingDialog(context);
  }
}

addNewItem(String itemName, int price, int totalQty, BuildContext context,
    imageUrl) async {
  showLoadingDialog(context);
  try {
    final itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef.add({
      "item_name": itemName,
      "price": price,
      "total_qty": totalQty,
      "imageUrl": imageUrl,
    });

    hideLoadingDialog(context);
    Navigator.pop(context);
    toast("New Item added successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to add new item!");
    log(error.toString());
  }
}

editItem(String itemName, int price, int totalQty, BuildContext context,
    String id, String images) async {
  showLoadingDialog(context);
  try {
    final itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef.doc(id).set({
      "item_name": itemName,
      "price": price,
      "total_qty": totalQty,
      'imageUrl': images
    });

    hideLoadingDialog(context);
    Navigator.pop(context);
    toast("Item edited successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to edit item!");
    log(error.toString());
  }
}

deleteItem(String id, BuildContext context) async {
  showLoadingDialog(context);
  try {
    final itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef.doc(id).delete();

    hideLoadingDialog(context);
    Navigator.pop(context);
    toast("Item deleted successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to delete item!");
    log(error.toString());
  }
}

editCartItem(String itemId, int count, BuildContext context) async {
  try {
    // Show loading indicator
    showLoadingDialog(context);

    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      hideLoadingDialog(context);
      toast("Please login first!");
      return;
    }

    final cartRef = FirebaseFirestore.instance.collection('carts');

    // Update or delete item based on count
    if (count <= 0) {
      await cartRef
          .doc(currentUser.uid)
          .collection('items')
          .doc(itemId)
          .delete();
      toast("Item removed from cart!");
    } else {
      await cartRef
          .doc(currentUser.uid)
          .collection('items')
          .doc(itemId)
          .update({"count": count});
      toast("Cart updated successfully!");
    }
  } catch (error) {
    toast("Failed to update cart!");
    log("Error updating cart item: $error");
  } finally {
    // Hide loading indicator
    hideLoadingDialog(context);
  }
}

addMoney(int amount, BuildContext context, String id) async {
  showLoadingDialog(context);
  try {
    final userRef = FirebaseFirestore.instance.collection('users');
    await userRef.doc(id).update({'balance': FieldValue.increment(amount)});

    hideLoadingDialog(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              NavigationBarPage(selectedIndex: 1)),
    );
    toast("Money added successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to add money!");
    log(error.toString());
  }
}

placeOrder(BuildContext context, double total) async {
  showLoadingDialog(context);
  try {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      hideLoadingDialog(context);
      toast("Please login first!");
      return;
    }

    final cartRef = FirebaseFirestore.instance.collection('carts');
    final orderRef = FirebaseFirestore.instance.collection('orders');
    final itemRef = FirebaseFirestore.instance.collection('items');
    final userRef = FirebaseFirestore.instance.collection('users');

    List<String> foodIds = [];
    Map<String, int> count = {};
    List<Map<String, dynamic>> cartItems = [];

    // Check user balance
    final userData = await userRef.doc(currentUser.uid).get();
    if (!userData.exists || userData.data()!['balance'] < total) {
      hideLoadingDialog(context);
      toast("You don't have sufficient balance to place this order!");
      return;
    }

    // Get cart items
    final cartSnapshot =
        await cartRef.doc(currentUser.uid).collection('items').get();
    for (var item in cartSnapshot.docs) {
      foodIds.add(item.id);
      count[item.id] = item.data()['count'];
    }

    // Check item availability
    final itemsSnapshot =
        await itemRef.where(FieldPath.documentId, whereIn: foodIds).get();
    for (var item in itemsSnapshot.docs) {
      if (item.data()['total_qty'] < count[item.id]!) {
        hideLoadingDialog(context);
        toast(
            "Item: ${item.data()['item_name']} has QTY: ${item.data()['total_qty']} only. Reduce/Remove the item.");
        return;
      }

      cartItems.add({
        "item_id": item.id,
        "count": count[item.id],
        "item_name": item.data()['item_name'],
        "price": item.data()['price']
      });
    }

    // Use transaction for atomic operations
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Update item quantities
      for (var item in itemsSnapshot.docs) {
        transaction.update(item.reference,
            {"total_qty": item.data()["total_qty"] - count[item.id]!});
      }

      // Deduct user balance
      transaction.update(userRef.doc(currentUser.uid),
          {'balance': FieldValue.increment(-1 * total)});

      // Create order
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      transaction.set(orderRef, {
        "items": cartItems,
        "is_delivered": false,
        "total": total,
        "placed_at": FieldValue.serverTimestamp(),
        "placed_by": currentUser.uid
      });

      // Clear cart
      for (var item in cartSnapshot.docs) {
        transaction.delete(item.reference);
      }
    });

    hideLoadingDialog(context);
    // Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              NavigationBarPage(selectedIndex: 1)),
    );
    toast("Order Placed Successfully!");
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to place order!");
    log(error.toString());
  }
}

orderReceived(String id, BuildContext context) async {
  showLoadingDialog(context);

  try {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');
    await ordersRef
        .doc(id)
        .update({'is_delivered': true})
        .catchError((e) => log(e))
        .then((value) => log("Success"));
  } catch (error) {
    hideLoadingDialog(context);
    toast("Failed to mark as received!");
    log(error.toString());
    return;
  }
  hideLoadingDialog(context);
  Navigator.pop(context);
  toast("Order received successfully!");
}
