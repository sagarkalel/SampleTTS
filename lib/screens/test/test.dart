import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class PlatformModel {
  final String name;
  final String iconUrl;
  final String desc;
  const PlatformModel(
      {required this.name, required this.desc, required this.iconUrl});

  factory PlatformModel.toJson(Map<String, dynamic> data) {
    return PlatformModel(
        name: data.containsKey('name') ? data['name'] : '',
        desc: data.containsKey('description') ? data['description'] : '',
        iconUrl: data.containsKey('iconURL') ? data['iconURL'] : '');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String mainHeader = 'Header';
String mainDesc = 'Desc';

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    var numbers = [1, 3, 2, 5, 4, 6, 8, 9, 7];
    debugPrint('original array: $numbers');
    reverseHalves(numbers);
    debugPrint('reversed array: $numbers');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: Services.fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null) {
              return const Center(child: Text("data is null"));
            }
            final data = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Scaffold(
                appBar: AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mainHeader),
                      Text(mainDesc),
                    ],
                  ),
                  toolbarHeight: 100,
                ),
                body: ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    var item = data[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.desc),
                      trailing: Image.network(item.iconUrl),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Services {
  static Future<List<PlatformModel>> fetchData() async {
    List<PlatformModel> _platforms = [];
    try {
      final response = await http.get(Uri.parse(
          "https://assessment.sgp1.digitaloceanspaces.com/android/test/machineTest.json"));

      var data = jsonDecode(response.body);
      dev.log("this is fetched data: $data");
      if (data['status'] == true) {
        var finalData = data['data'];
        mainHeader = finalData['title'] ?? 'empty';
        mainDesc = finalData['description'] ?? 'empty';
        _platforms = (finalData['platforms'] as List)
            .map((e) => PlatformModel.toJson(e))
            .toList();
      }
    } catch (e) {
      dev.log("error while getting data: $e");
    }
    return _platforms;
  }
}

void reverseHalves(var numbers) {
  // reversing first half of array
  int start = 0;
  int end = (numbers.length ~/ 2) - 1;
  while (start < end) {
    // swapping numbers[start] and numbers[end]
    var temp = numbers[start];
    numbers[start] = numbers[end];
    numbers[end] = temp;
    start++;
    end--;
  }

  // reversing second half of array
  start = (numbers.length ~/ 2) + 1;
  end = numbers.length - 1;
  while (start < end) {
    // swapping numbers[start] and numbers[end]
    var temp = numbers[start];
    numbers[start] = numbers[end];
    numbers[end] = temp;
    start++;
    end--;
  }
}

void main() {
  /// original array
  var numbers = [1, 3, 2, 5, 4, 6, 8, 9, 7];
  debugPrint('original array: $numbers');
  reverseHalves(numbers);
  debugPrint('reversed array: $numbers');
}
