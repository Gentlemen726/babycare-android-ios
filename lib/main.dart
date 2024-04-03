import 'package:baby_care/growth.dart';
import 'package:baby_care/growth_details.dart';
import 'package:baby_care/nappy.dart';
import 'package:baby_care/nappy_details.dart';
import 'package:baby_care/sleep.dart';
import 'package:baby_care/sleep_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feed_details.dart';
import 'firebase_options.dart';

import 'feed.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedModel>(create: (_) => FeedModel()),
        ChangeNotifierProvider<GrowthModel>(create: (_) => GrowthModel()),
        ChangeNotifierProvider<SleepModal>(create: (_) => SleepModal()),
        ChangeNotifierProvider<NappyModel>(create: (_) => NappyModel()),
      ],
      child: MaterialApp(
        title: 'Baby Care App',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: const MyHomePage(title: 'BabyCare App'),
      ),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Feeds'),
            Tab(text: 'Sleep'),
            Tab(text: 'Nappy'),
            Tab(text: 'Growth'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeedData(),
          SleepData(),
          NappyData(),
          GrowthData(),
        ],
      ),
    );
  }
}

class FeedData extends StatelessWidget {
  const FeedData({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FeedModel>(
        builder: (context, feedModel, _) {
          if (feedModel.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemBuilder: (_, index) {
                var feed = feedModel.items[index];
                var feedDate = feed.feedDate;
                var feedStartTime = feed.feedStartTime;
                var milkType = feed.milkType;
                var feedSide = feed.feedSide;
                return Dismissible(
                  key: Key(feed.id),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Are you sure you want to delete this item?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    feedModel.delete(feed.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feed Data Deleted'),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent[100],
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'images/breastfeeding.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      feedDate,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3),
                        Text(
                          "Start Time: " + feedStartTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Milk Type: " + milkType,
                          style: TextStyle(
                            fontSize: 14,
                            color: milkType == "Mothers Milk" ? Colors.pink : Colors.blue,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Feed Side: " +feedSide,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ],

                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FeedDetails(id: feed.id);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              itemCount: feedModel.items.length,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return const FeedDetails();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class SleepData extends StatelessWidget {
  const SleepData({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SleepModal>(
        builder: (context, sleepModel, _) {
          if (sleepModel.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: sleepModel.items.length,
              itemBuilder: (context, index) {
                var sleep = sleepModel.items[index];
                var sleepDate = sleep.date;
                var sleepStartTime = sleep.sleepStart;
                var sleepDuration = sleep.sleepDuration;
                var sleepEnd = sleep.sleepEnd;
                return Dismissible(
                    key: Key(sleep.id),
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text('Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      sleepModel.delete(sleep.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sleep Data Deleted'),
                        ),
                      );
                    },
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/sleeping1.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  title: Text(
                    sleepDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3),
                      Text(
                        'Wake Up Time: $sleepEnd',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sleep Start Time: $sleepStartTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Duration: $sleepDuration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SleepDetails(id: sleep.id);
                        },
                      ),
                    );
                  },
                ));
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return const SleepDetails();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NappyData extends StatelessWidget {
  const NappyData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NappyModel>(
        builder: (context, nappyModel, _) {
          if (nappyModel.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: nappyModel.items.length,
              itemBuilder: (context, index) {
                var nappy = nappyModel.items[index];
                var poopDate = nappy.poopDate;
                var poopTime = nappy.poopTime;
                var nappyType = nappy.nappyType;

                return Dismissible(
                    key: Key(nappy.id),
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text('Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      nappyModel.delete(nappy.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nappy Data Deleted'),
                        ),
                      );
                    },
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/nappy.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  title: Text(
                    poopDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3),
                      Text(
                        'Nappy Time: $poopTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Nappy Type: $nappyType',
                        style: TextStyle(
                          fontSize: 14,
                          color: nappyType == "Wet and Dirty" ? Colors.brown : Colors.black,
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return NappyDataDetails(id: nappy.id);
                        },
                      ),
                    );
                  },
                ));
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return const NappyDataDetails();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class GrowthData extends StatelessWidget {
  const GrowthData({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GrowthModel>(
        builder: (context, growthModel, _) {
          if (growthModel.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemBuilder: (_, index) {
                var growth = growthModel.items[index];
                var height = growth.height;
                var measuredDate = growth.measuredDate;
                return Dismissible(
                  key: Key(growth.id),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Are you sure you want to delete this item?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    growthModel.delete(growth.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Growth Data Deleted'),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'images/height.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      measuredDate,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3),
                        Text(
                          "Height: " + height,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ],
                    ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return GrowthDetails(id: growth.id);
                            },
                          ),
                        );
                      }
                  ),
                );
              },
              itemCount: growthModel.items.length,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return const GrowthDetails();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}

