import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class suggestionsPage extends StatefulWidget {
  final List list;
  const suggestionsPage({Key? key, required List this.list}) : super(key: key);

  @override
  State<suggestionsPage> createState() => _suggestionsPageState();
}

class _suggestionsPageState extends State<suggestionsPage> {


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Container(
        child: widget.list.length > 0
            ? ListView.builder(
                itemCount: widget.list.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        //print(widget.list[index]);
                        // _saved.remove(index);
                        // widget.saved.remove(index);
                        //inst.stationstate(index);
                        //Navigator.of(context).pop(widget.list[index]);
                        //widget.savePrefs(_saved);
                        widget.list.removeAt(index);
                      });
                    },
                    secondaryBackground: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 230, top: 20),
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
                            TextSpan(
                                text: "Delete Suggestion",
                                style: TextStyle(fontSize: 16)),
                          ],
                        )),
                      ),
                      color: Colors.deepPurple,
                    ),
                    background: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
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
                              TextSpan(
                                  text: "Delete Suggestion",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      color: Colors.deepPurple,
                    ),
                    child: widget.list[index],
                    //child: Text(_saved.toList()[index]),
                    key: UniqueKey(),
                    direction: DismissDirection.horizontal,
                    // confirmDismiss: (DismissDirection direction) async {
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //     content: Text('Deletion is not implemented yet'),
                    //   ));
                    //
                    // });
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Suggestion"),
                              content: direction == DismissDirection.startToEnd
                                  ? Text(
                                  "Are you sure you to delete " + widget.list.elementAt(index).title.data.toString()
                                      + " from your saved suggestions?")
                                  : Text(
                                  "Are you sure you to delete " + widget.list.elementAt(index).title.data.toString()
                                      + " from your saved suggestions?"),
                              actions: <Widget>[
                                TextButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepPurple,
                                      fixedSize:
                                      const Size(20, 40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              5))),
                                  onPressed: ()
                                      {

                                        Navigator.of(context).pop(true);
                                      },
                                  child: direction ==
                                      DismissDirection.startToEnd
                                      ? Text.rich(TextSpan(text: "YES", style: TextStyle(color: Colors.white)))
                                      : Text.rich(TextSpan(text: "YES", style: TextStyle(color: Colors.white))),
                                ),
                                TextButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepPurple,
                                      fixedSize:
                                      const Size(20, 40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              5))),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text.rich(TextSpan(text: "NO", style: TextStyle(color: Colors.white))),
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                },
              )
            : Center(child: Text('No Items')),
      ),
    );
  }
}
