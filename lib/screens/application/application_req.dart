import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_app/utlis/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryData {
  final String uid;
  final String name;
  // Add more fields as per your Firestore document structure

  DeliveryData({
    required this.uid,
    required this.name,
  });
}

class ApplicationRequest extends StatefulWidget {
  const ApplicationRequest({Key? key}) : super(key: key);

  @override
  State<ApplicationRequest> createState() => _ApplicationRequestState();
}

class _ApplicationRequestState extends State<ApplicationRequest> {
  late List<String> deviceUIDs;

  Future<void> _fetchDeviceUIDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceUIDs = prefs.getStringList('deviceUIDs') ?? [];
    });
  }

  Future<List<DeliveryData>> _fetchDeliveryData() async {
    List<DeliveryData> deliveryDataList = [];
    if (deviceUIDs.isEmpty) {
      return deliveryDataList; // Return empty list if deviceUIDs is empty
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('delivery')
          .where(FieldPath.documentId, whereIn: deviceUIDs)
          .get();
      deliveryDataList = querySnapshot.docs.map((doc) {
        return DeliveryData(
          uid: doc.id,
          name: doc['name'],
          // Add more fields as per your Firestore document structure
        );
      }).toList();
    } catch (e) {
      print('Error fetching delivery data: $e');
      // Handle error fetching data from Firestore
    }
    return deliveryDataList;
  }


  @override
  void initState() {
    super.initState();
    _fetchDeviceUIDs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
      ),
      body: FutureBuilder<List<DeliveryData>>(
        future: _fetchDeliveryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            CommonWidget.loader(context);
          } else if (snapshot.hasError) {
            CommonWidget.toastMessage('Error: ${snapshot.error}');
            print('Error: ${snapshot.error}');
          } else {
            List<DeliveryData> deliveryDataList = snapshot.data!;
            if (deliveryDataList.isEmpty) {
              return const Center(child: Text('No matching data found'));
            } else {
              return ListView.builder(
                itemCount: deliveryDataList.length,
                itemBuilder: (context, index) {
                  DeliveryData deliveryData = deliveryDataList[index];
                  return ListTile(
                    title: Text(deliveryData.name),
                    // Display more fields or customize UI as needed
                  );
                },
              );
            }
          }
          return Container();
        },
      ),
    );
  }
}
