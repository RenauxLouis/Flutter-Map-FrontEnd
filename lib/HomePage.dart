import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'dart:html';
import 'package:google_maps/google_maps.dart' as gg;
import 'dart:ui' as ui;

class MyMain extends StatefulWidget {
  MyMain({Key key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Material App",
        theme: ThemeData(
            primarySwatch: Colors.orange,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        initialRoute: "/",
        routes: {
          "/": (context) => DatesScreen(),
          "/today": (context) => MapScreen(date: "today"),
          "/tomorrow": (context) => MapScreen(date: "tomorrow"),
        });
  }
}

class DatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          dateButton(context, "today"),
          dateButton(context, "tomorrow")
        ]));
  }

  Widget dateButton(context, date) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
      ),
      onPressed: () {
        Navigator.pushNamed(context, "/" + date);
      },
      child: Text(date[0].toUpperCase() + date.substring(1).toLowerCase()),
    );
  }
}

class MapScreen extends StatefulWidget {
  final String date;

  MapScreen({Key key, this.date}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Future<List> futureLivraisons;

  @override
  void initState() {
    super.initState();
    futureLivraisons = getLivraisons(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: futureLivraisons,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List dataPerIndex = getMarkerDataPerIndex(snapshot.data);
                Map<int, dynamic> colorPerIndex = dataPerIndex[0];
                Map<int, dynamic> latPerIndex = dataPerIndex[1];
                Map<int, dynamic> longPerIndex = dataPerIndex[2];
                Map<int, String> addressPerIndex = dataPerIndex[3];
                return DisplayMap(
                    livraisons: snapshot.data,
                    colorPerIndex: colorPerIndex,
                    latPerIndex: latPerIndex,
                    longPerIndex: longPerIndex,
                    addressPerIndex: addressPerIndex);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                  child: Container(
                      child: CircularProgressIndicator(),
                      width: 48.0,
                      height: 48.0));
            }));
  }
}

class DisplayMap extends StatefulWidget {
  final List<dynamic> livraisons;
  final Map<int, dynamic> colorPerIndex;
  final Map<int, dynamic> latPerIndex;
  final Map<int, dynamic> longPerIndex;
  final Map<int, String> addressPerIndex;

  const DisplayMap(
      {Key key,
      this.livraisons,
      this.colorPerIndex,
      this.latPerIndex,
      this.longPerIndex,
      this.addressPerIndex})
      : super(key: key);

  @override
  _DisplayMapState createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  List validIndexes = [];
  String startHour = "0";
  String endHour = "23";

  @override
  initState() {
    super.initState();
    validIndexes = [for (var i = 0; i < widget.livraisons.length; i += 1) i];
  }

  restrictIndexes() {
    List<int> newIndexes = [];
    for (var i = 0; i < widget.livraisons.length; i++) {
      Map<String, dynamic> livraison = widget.livraisons[i];
      if ((int.parse(livraison["hour_start"]) >= int.parse(startHour)) &&
          (int.parse(livraison["hour_start"]) < int.parse(endHour))) {
        newIndexes.add(i);
      }
    }

    setState(() {
      validIndexes = newIndexes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: MyMap(
            livraisons: widget.livraisons,
            colorPerIndex: widget.colorPerIndex,
            latPerIndex: widget.latPerIndex,
            longPerIndex: widget.longPerIndex,
            addressPerIndex: widget.addressPerIndex,
            validIndexes: validIndexes),
        flex: 2,
      ),
      Expanded(
          child: Column(children: [
        Flexible(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/");
                    },
                    child: Text("MENU"),
                  ),
                  DropdownButton<String>(
                    value: startHour,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        startHour = newValue;
                        restrictIndexes();
                      });
                    },
                    items: <String>[
                      for (var i = 0; i < 24; i += 1) i.toString()
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value + "h"),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: endHour,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        endHour = newValue;
                        restrictIndexes();
                      });
                    },
                    items: <String>[
                      for (var i = 0; i < 24; i += 1) i.toString()
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value + "h"),
                      );
                    }).toList(),
                  )
                ]),
            flex: 1),
        Flexible(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: buildWidgetsFromLivraisons(),
            ),
            flex: 9)
      ]))
    ]));
  }

  List<Widget> buildWidgetsFromLivraisons() {
    List<Widget> widgets = [];
    for (var i = 0; i < validIndexes.length; i++) {
      int index = validIndexes[i];
      Map<String, dynamic> livraison = widget.livraisons[index];
      String color = widget.colorPerIndex[index];
      Widget listWidget = itemWidget(index, livraison, color);
      widgets.add(listWidget);
    }
    return widgets;
  }
}

Widget itemWidget(index, livraison, color) {
  Map<String, dynamic> colorMap = {
    "red": Colors.red,
    "green": Colors.green,
    "orange": Colors.orange
  };

  return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(border: Border.all(color: colorMap[color])),
      child: Row(children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: indexCircle(index, colorMap[color])),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("CLIENT: " + livraison["client_name"]),
          Text("STATUS: " + livraison["status"]),
          Text("FROM: " + livraison["address_from"]),
          Text("TO: " + livraison["address_to"]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text(livraison["hour_start"].toString() + "h          "),
            Text(livraison["load"].toString() + "kg")
          ]),
          Text(livraison["livreur"]),
        ])
      ]));
}

Widget indexCircle(index, color) {
  return Center(
    child: Container(
      width: 30,
      height: 30,
      child: Center(
          child: Text(
        index.toString(),
        style: TextStyle(
          fontSize: 12.0,
        ),
        textAlign: TextAlign.center,
      )),
      decoration: BoxDecoration(
        border: Border.all(width: 3),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: color,
      ),
    ),
  );
}

class MyMap extends StatefulWidget {
  final List<dynamic> livraisons;
  final Map<int, dynamic> colorPerIndex;
  final Map<int, dynamic> latPerIndex;
  final Map<int, dynamic> longPerIndex;
  final Map<int, String> addressPerIndex;
  final List validIndexes;

  const MyMap(
      {Key key,
      this.livraisons,
      this.colorPerIndex,
      this.latPerIndex,
      this.longPerIndex,
      this.addressPerIndex,
      this.validIndexes})
      : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Future<List<dynamic>> futureLivraisons;
  String date = "today";

  @override
  Widget build(BuildContext context) {
    String htmlId = widget.validIndexes.join();

    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final mapOptions = gg.MapOptions()
        ..zoom = 12
        ..center = gg.LatLng(48.856614, 2.3522219);

      final elem = DivElement()
        ..id = htmlId
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      final map = gg.GMap(elem, mapOptions);

      final markerl1 = gg.Marker(gg.MarkerOptions()
        ..position = gg.LatLng(48.8722792, 2.3493811)
        ..map = map
        ..icon = "assets/assets/black.png");
      final infoWindowl1 = gg.InfoWindow(
          gg.InfoWindowOptions()..content = "38 Rue d'Enghien 75010 Paris");
      markerl1.onClick.listen((event) => infoWindowl1.open(map, markerl1));
      final markerl2 = gg.Marker(gg.MarkerOptions()
        ..position = gg.LatLng(48.881060, 2.292580)
        ..map = map
        ..icon = "assets/assets/black.png");
      final infoWindowl2 = gg.InfoWindow(
          gg.InfoWindowOptions()..content = "22 rue Torricelli 75017 paris");
      markerl2.onClick.listen((event) => infoWindowl2.open(map, markerl2));

      for (var i = 0; i < widget.validIndexes.length; i++) {
        int index = widget.validIndexes[i];
        final latLong =
            gg.LatLng(widget.latPerIndex[index], widget.longPerIndex[index]);

        final marker = gg.Marker(gg.MarkerOptions()
          ..position = latLong
          ..map = map
          ..label = index.toString()
          ..icon = "assets/assets/" + widget.colorPerIndex[index] + ".png");

        final infoWindow = gg.InfoWindow(
            gg.InfoWindowOptions()..content = widget.addressPerIndex[index]);
        marker.onClick.listen((event) => infoWindow.open(map, marker));
      }
      return elem;
    });

    return HtmlElementView(viewType: htmlId);
  }
}

List getMarkerDataPerIndex(livraisons) {
  String laverie1 = "38 Rue d'Enghien 75010 Paris";
  String laverie2 = "22 Rue Torricelli 75017 paris";
  List<String> laveries = [laverie1, laverie2];

  Map<int, dynamic> colorPerIndex = {};
  Map<int, dynamic> latPerIndex = {};
  Map<int, dynamic> longPerIndex = {};
  Map<int, String> addressPerIndex = {};
  List addressesFrom = [for (var item in livraisons) item["address_from"]];
  List addressesTo = [for (var item in livraisons) item["address_to"]];

  addressesFrom.removeWhere((item) => !addressesTo.contains(item));
  addressesFrom.removeWhere((item) => item == laverie1);
  addressesFrom.removeWhere((item) => item == laverie2);

  for (var i = 0; i < livraisons.length; i++) {
    Map<String, dynamic> livraison = livraisons[i];
    if (laveries.contains(livraison["address_from"])) {
      colorPerIndex[i] = "red";
      latPerIndex[i] = livraison["lat_to"];
      longPerIndex[i] = livraison["long_to"];
      addressPerIndex[i] = livraison["address_to"];
    } else if (laveries.contains(livraison["address_to"])) {
      colorPerIndex[i] = "green";
      latPerIndex[i] = livraison["lat_from"];
      longPerIndex[i] = livraison["long_from"];
      addressPerIndex[i] = livraison["address_from"];
    } else {
      print(livraison);
      print("No laverie in address_from not address_to");
    }

    if (addressesFrom.contains(livraison["address_from"]) ||
        addressesFrom.contains(livraison["address_to"])) {
      colorPerIndex[i] = "orange";
    }
  }

  return [colorPerIndex, latPerIndex, longPerIndex, addressPerIndex];
}

Future<List> getLivraisons(date) async {
  http.Response response = await http.Client().get(Uri.https(
      "laverie-privee-map-python.web.app", "/get_livraisons_payload_" + date));
  Map<String, dynamic> parsedBody = jsonDecode(response.body);
  List livraisons = parsedBody["data"];
  return livraisons;
}
