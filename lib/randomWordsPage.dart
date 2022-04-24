
import 'dart:io' as io;
import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'auth.dart';
import 'package:file_picker/file_picker.dart';
import 'loginPage.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RandomWordsUnAuth();
  }
}

class RandomWordsUnAuth extends StatefulWidget {
  RandomWordsUnAuth({Key? key}) : super(key: key);

  @override
  State<RandomWordsUnAuth> createState() => _RandomWordsUnAuthState();
}

class _RandomWordsUnAuthState extends State<RandomWordsUnAuth> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ScrollController listViewController = new ScrollController();
  SnappingSheetController snappingSheetController = SnappingSheetController();
  final _suggestions = <WordPair>[];
  final Set<WordPair> _saved = <WordPair>{};
  bool isSelected = false;

  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.toString(),
        style: _biggerFont,
      ),
      trailing: Icon(
        // NEW from here...
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () async {
        setState(() {
          if (alreadySaved) {
            if (AuthRepository.instance().status == Status.Authenticated) {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection("Pair")
                  .where("WordPair ", isEqualTo: pair.toString().trim())
                  .get()
                  .then((value) {
                value.docs.forEach((element) {
                  print("Hi");
                  FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection("Pair")
                      .doc(element.id)
                      .delete()
                      .then((value) {
                    print("Success!");
                  });
                });
              });
            }
            _saved.remove(pair);
          } else {
            if (AuthRepository.instance().status == Status.Authenticated) {
              print("Hiii");
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection("Pair")
                  .add({"WordPair ": pair.toString().trim()});
            }
            _saved.add(pair);
          }
        });
      },
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      // Add lines from here...
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              titleTextStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
              centerTitle: true,
              title: ConstrainedBox(constraints: BoxConstraints(maxHeight: 35, maxWidth: 200), child: Text("Login")),
            ),
            body: loginPage(),
          );
        },
      ), // ...to here.
    );
  }

  Container background(double _left) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: _left, top: 20),
        child: RichText(
            text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                Icons.delete,
                size: 20,
                color: Colors.white,
              ),
            ),
            TextSpan(text: "Delete Suggestion", style: TextStyle(fontSize: 16)),
          ],
        )),
      ),
      color: Colors.deepPurple,
    );
  }

  Future dialog(WordPair item, DismissDirection direction) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Suggestion"),
            content: direction == DismissDirection.startToEnd
                ? Text("Are you sure you to delete " + item.toString() + " from your saved suggestions?")
                : Text("Are you sure you to delete " + item.toString() + " from your saved suggestions?"),
            actions: <Widget>[
              TextButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple, fixedSize: const Size(20, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: direction == DismissDirection.startToEnd
                    ? Text.rich(TextSpan(text: "YES", style: TextStyle(color: Colors.white)))
                    : Text.rich(TextSpan(text: "YES", style: TextStyle(color: Colors.white))),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple, fixedSize: const Size(20, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text.rich(TextSpan(text: "NO", style: TextStyle(color: Colors.white))),
              ),
            ],
          );
        });
  }

  Dismissible _dismissible(WordPair item) {
    return Dismissible(
      onDismissed: (DismissDirection direction) {
        setState(() {
          if (AuthRepository.instance().status == Status.Authenticated) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection("Pair")
                .where("WordPair ", isEqualTo: item.toString().trim())
                .get()
                .then((value) {
              value.docs.forEach((element) {
                print("Hi");
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection("Pair")
                    .doc(element.id)
                    .delete()
                    .then((value) {
                  print("Success!");
                });
              });
            });
          }
          _saved.remove(item);
        });
        print(_saved);
      },
      secondaryBackground: background(230),
      background: background(20),
      child: ListTile(title: Text(item.toString())),
      key: Key(item.toString()),
      direction: DismissDirection.horizontal,
      confirmDismiss: (DismissDirection direction) async {
        return await dialog(item, direction);
      },
    );
  }

  void _pushSaved() async {
    await Navigator.of(context).push(
      // Add lines from here...
      MaterialPageRoute<WordPair>(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                titleTextStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                title: Text(
                  'Saved Suggestions',
                ),
              ),
              body: Scaffold(
                body: Container(
                  child: _saved.length > 0
                      ? ListView.builder(
                          itemCount: _saved.toList().length,
                          itemBuilder: (BuildContext context, int index) {
                            var item = _saved.elementAt(index);
                            return _dismissible(item);
                          },
                        )
                      : Center(child: Text('No Items')),
                ),
              ));
        },
      ), // ...to here.
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // Add from here...
      appBar: AppBar(
        titleTextStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () async {
              if (AuthRepository.instance().status == Status.Authenticated) {
                var result = await _db.collection("Users").doc(FirebaseAuth.instance.currentUser?.uid).collection("Pair").get();
                List<DocumentSnapshot> documents = result.docs;
                Set<WordPair> _savedset = {};
                documents.forEach((DOC) {
                  String result = DOC.data().toString().substring(DOC.data().toString().indexOf(":") + 2, DOC.data().toString().length - 1);
                  result.trim();
                  String s1 = result.substring(0, 1);
                  String s2 = result.substring(1, result.length);
                  _savedset.add(WordPair(s1, s2));
                  _saved.forEach((element) {
                    if (element.toString() == result) _savedset.remove(WordPair(s1, s2));
                  });
                });
                _saved.addAll(_savedset);
              }
              _pushSaved();
            },
            tooltip: 'Saved Suggestions',
          ),
          (AuthRepository.instance().status == Status.Authenticated)
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () async {
                    await AuthRepository.instance().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Successfully logged out'),
                    ));
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Wrapper(),
                        ),
                        (route) => false);
                  },
                )
              : IconButton(
                  icon: Icon(Icons.login),
                  onPressed: _pushLogin,
                ),
        ],
      ),
      body: (AuthRepository.instance().status == Status.Authenticated)
          ? SnappingSheet(
              controller: snappingSheetController,

              child: Stack(
                fit: StackFit.expand,
                children: [_buildSuggestions(),
                  (!isSelected) ? Container() :
                Container(
                  child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0,sigmaY: 5.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6)
                          ),
                        ),
                      )
                  ),)
                ],
              ),
              lockOverflowDrag: true,
              grabbingHeight: 75,
              grabbing: GestureDetector(
                  onTap: ()  {


                    if (!isSelected ) {
                      print("Hi");

                      snappingSheetController.snapToPosition(
                        const SnappingPosition.factor(positionFactor: 0.25),
                      );
                      isSelected = true;
                    } else if (isSelected ) {
                      print("Bye");
                      snappingSheetController.snapToPosition(
                        const SnappingPosition.factor(positionFactor: 0.05),
                      );

                      isSelected = false;
                    }
                    setState(() {

                    });

                  },
                    //if (snappingSheetController.isAttached) {

                    // }
                  child: Grabbing()),
              sheetBelow: SnappingSheetContent(
                //childScrollController: _scrollController,
                draggable: true,
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  FutureBuilder(
                                    future: AuthRepository.instance().downloadImage(),
                                    builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                      if(snapshot.data == null) print("Dammit");
                                      return CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.purple,
                                          backgroundImage: snapshot.data != null ? NetworkImage(snapshot.data.toString(),): null
                                      );

                                    }
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                                  child: Text.rich(TextSpan(
                                      style: TextStyle(
                                        fontSize: 26,
                                      ),
                                      text: FirebaseAuth.instance.currentUser?.email)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 15,
                                  ),
                                  // child: ElevatedButton(
                                  //     onPressed: () {}, child: Text.rich(TextSpan(style: TextStyle(fontSize: 20), text: "Change avatar"))),
                                  //
                                  child: Container(
                                      width: 160,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['png', 'jpg', 'gif', 'bmp', 'jpeg', 'webp'],
                                          );
                                          io.File file;
                                          if (result != null) {
                                            setState(() {
                                              file = io.File(result.files.single.path.toString());
                                              AuthRepository.instance().uploadImage(file);
                                            });
                                          } else {
                                            const snackBar = SnackBar(content: Text("No image selected"));
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        },
                                        child: const Text('change avatar'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white,
                                        ),
                                      ),
                                    )
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : _buildSuggestions(),
    );
  }
}

class Grabbing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20),
              child: Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 18,
                ),
                text: "welcome back, " + email!,
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 50),
              child: Icon(
                Icons.keyboard_arrow_up_outlined,
                size: 26,
              ),
            )
          ],
        ));
  }
}
