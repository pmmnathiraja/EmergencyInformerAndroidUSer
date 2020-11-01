import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/api/food_api.dart';
import 'package:user/model/user.dart';
import 'package:user/notifier/auth_notifier.dart';
import 'package:user/notifier/food_notifier.dart';
import 'package:user/screens/detail.dart';
import 'package:user/screens/food_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/views/landing.dart';

class Feed extends StatefulWidget {
//  Feed(this.userSet):super();
//  final UserData userSet;
  @override
  _FeedState createState() => _FeedState();
}


class _FeedState extends State<Feed> {
  @override
  void initState() {
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context, listen: false);
    //AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    User _firebaseUser = FirebaseAuth.instance.currentUser;
    getFoods(foodNotifier,_firebaseUser.displayName);
    super.initState();
  }

  void setupSignOut(User _firebaseUser){
    signOut(_firebaseUser);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return LandingPage();
    }));
  }
  @override
  Widget build(BuildContext context) {
  //  AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    User _firebaseUser = FirebaseAuth.instance.currentUser;
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    Future<void> _refreshList() async {
      getFoods(foodNotifier,_firebaseUser.displayName);
    }
    print("building Feed");
    return Scaffold(
//      appBar: AppBar(
//        actions: <Widget>[
//          // action button
//          FlatButton(
//            onPressed: () => setupSignOut(_firebaseUser) ,
//            child: Text(
//              "Logout",
//              style: TextStyle(fontSize: 23, color: Colors.white),
//            ),
//          ),
//        ],
//      ),
      body: new RefreshIndicator(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Image.network(
                foodNotifier.foodList[index].image != null
                    ? foodNotifier.foodList[index].image
                    : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                fit: BoxFit.fitWidth,
              ),
              title: Text(foodNotifier.foodList[index].name),
              subtitle: Text(foodNotifier.foodList[index].category),
              onTap: () {
                foodNotifier.currentFood = foodNotifier.foodList[index];
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return FoodDetail();
                }));
              },
            );
          },
          itemCount: foodNotifier.foodList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: Colors.black,
            );
          },
        ),
        onRefresh: _refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          foodNotifier.currentFood = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return FoodForm(
                isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }
}
