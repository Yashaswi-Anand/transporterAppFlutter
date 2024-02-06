import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:liveasy/Web/dashboard.dart';
import 'package:liveasy/constants/color.dart';
import 'package:liveasy/constants/screens.dart';
import 'package:liveasy/responsive.dart';
import 'package:liveasy/screens/myLoadPages/addNewDriver.dart';
import 'package:liveasy/screens/updateBookingDetails.dart';
import 'package:liveasy/screens/updateBookingDetailsScreen.dart';
import 'package:liveasy/widgets/buttons/backButtonWidget.dart';
import 'package:liveasy/widgets/headingTextWidget.dart';
import '../../constants/fontSize.dart';
import '../../constants/fontWeights.dart';
import '../../constants/radius.dart';
import '../../constants/spaces.dart';
import '../../functions/BackgroundAndLocation.dart';
import '../models/onGoingCardModel.dart';
import 'addDriver.dart';

//This screen displayes number of Driver from which user can select only one
class UpdateDriverScreen extends StatefulWidget {
  OngoingCardModel loadAllDataModel;
  String? driverName, driverPhoneNo;
  String? selectedTruck;
  int? selectedDeviceId;

  UpdateDriverScreen({
    required this.loadAllDataModel,
    this.selectedTruck,
    this.selectedDeviceId,
  });

  @override
  State<UpdateDriverScreen> createState() => _UpdateDriverScreenState();
}

class _UpdateDriverScreenState extends State<UpdateDriverScreen> {
  final ScrollController _firstController = ScrollController();
  bool isSelected = false;
  String searchedDriver = "";
  late String selectedDriver;
  int selectedIndex = -1;
  List driverList = [];
  List searchedDriverList = [];
  List searchedDriverListNumber = [];
  List driverNames = [];
  List driverMobileNumbers = [];
  late String selectedDriverPhoneNumber;

  getDriverData() async {
    driverMobileNumbers.clear();
    driverNames.clear();
    String driverApiUrl = dotenv.get("driverApiUrl").toString();
    var jsonData;
    String? traccarUser = transporterIdController.mobileNum.value;
    String traccarPass = dotenv.get("traccarPass");
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$traccarUser:$traccarPass'));
    http.Response response = await http.get(
      Uri.parse("$driverApiUrl/api/drivers"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );
    jsonData = await jsonDecode(response.body);
    for (var json in jsonData) {
      setState(() {
        driverList.add(json);
        driverNames.add(json["name"]);
        driverMobileNumbers.add(json["uniqueId"]);
      });
    }
  }

  //searchOperation on the basis of trucknumbers
  void searchoperation(String searchText) {
    if (searchText != null) {
      searchedDriverList.clear();
      searchedDriverListNumber.clear();

      for (int i = 0; i < driverList.length; i++) {
        String driverName = driverNames[i];
        String driverNumber = driverMobileNumbers[i];

        if (driverName.toLowerCase().contains(searchText.toLowerCase()) ||
            driverNumber.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            print(searchText);
            searchedDriverList.add(driverName);
            searchedDriverListNumber.add(driverNumber);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDriverData();
  }

  @override
  Widget build(BuildContext context) {
    return (kIsWeb && (Responsive.isDesktop(context)))
    //Ui for Dekstop
        ? Scaffold(
            body: Column(
            children: [
              SizedBox(
                height: space_4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen(
                                  selectedIndex: screens.indexOf(auctionScreen),
                                  index: 1000,
                                  visibleWidget: UpdateBookingDetailsScreen(
                                    loadAllDataModel: widget.loadAllDataModel,
                                  ))));
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                  SizedBox(
                    width: space_5,
                  ),
                  Container(
                    child: Text(
                      'Select Driver',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.only(
                  left: space_20,
                  top: space_15,
                ),
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: space_8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: space_9,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: widgetBackGroundColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                width: 0.8, color: widgetBackGroundColor),
                          ),
                          child: Center(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchedDriver = value;
                                });
                                print(value);
                                searchoperation(searchedDriver);
                                selectedDriver = "";
                                selectedIndex = -1;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'searchByNumber'.tr,
                                icon: Icon(
                                  Icons.search,
                                  color: grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 70.0),
                          child: Container(
                            height: space_10,
                            width: space_30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                (kIsWeb && (Responsive.isDesktop(context)))
                                    ? showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SimpleDialog(
                                            children: [
                                              Container(
                                                width: 510,
                                                height: 320,
                                                child: AddDriver(
                                                  selectedTruck:
                                                      widget.selectedTruck,
                                                  selectedDeviceId:
                                                      widget.selectedDeviceId,
                                                  loadAllDataModel:
                                                      widget.loadAllDataModel,
                                                ),
                                              )
                                            ],
                                          );
                                        })
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddDriver(
                                            selectedTruck: widget.selectedTruck,
                                            selectedDeviceId:
                                                widget.selectedDeviceId,
                                            loadAllDataModel:
                                                widget.loadAllDataModel,
                                          ),
                                        ),
                                      );
                              },
                              icon: Icon(
                                Icons.add,
                                color: const Color(0xFF152968),
                              ),
                              label: Text(
                                "Add Driver",
                                style: TextStyle(
                                  color: const Color(0xFF152968),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.only(top: space_2),
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Scrollbar(
                          controller: _firstController,
                          child: searchedDriver.length != 0
                              ? ListView.builder(
                                  itemCount: searchedDriverList.length,
                                  controller: _firstController,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(() {
                                          isSelected = true;
                                          selectedIndex = index;
                                          selectedDriver =
                                              searchedDriverList[index];
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: space_2, bottom: space_2),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: widgetBackGroundColor),
                                              color: (index == selectedIndex)
                                                  ? Color(0xff152968)
                                                  : Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${searchedDriverList[index]} - ${searchedDriverListNumber[index]}",
                                                style: TextStyle(
                                                  fontSize: size_10,
                                                  fontWeight: mediumBoldWeight,
                                                  color:
                                                      (index == selectedIndex)
                                                          ? Colors.white
                                                          : black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size_5,
                                          )
                                        ],
                                      ),
                                    );
                                  })
                              : ListView.builder(
                                  itemCount: driverList.length,
                                  controller: _firstController,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      splashColor: Colors.white,
                                      onTap: () {
                                        setState(() {
                                          isSelected = true;
                                          selectedIndex = index;
                                          selectedDriver = driverNames[index];
                                          selectedDriverPhoneNumber =
                                              driverMobileNumbers[index];
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: space_2, bottom: space_2),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: widgetBackGroundColor),
                                              color: (index == selectedIndex)
                                                  ? Color(0xff152968)
                                                  : Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${driverNames[index]} - ${driverMobileNumbers[index]}",
                                                style: TextStyle(
                                                  fontSize: size_10,
                                                  fontWeight: mediumBoldWeight,
                                                  color:
                                                      (index == selectedIndex)
                                                          ? Colors.white
                                                          : black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size_5,
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: isSelected
                            ? () => {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => DashboardScreen(
                                              selectedIndex:
                                                  screens.indexOf(ordersScreen),
                                              index: 1000,
                                              visibleWidget:
                                                  UpdateBookingDetails(
                                                selectedTruck:
                                                    widget.selectedTruck,
                                                selectedDeviceId:
                                                    widget.selectedDeviceId,
                                                driverName: selectedDriver,
                                                mobileNo:
                                                    selectedDriverPhoneNumber,
                                                loadAllDataModel:
                                                    widget.loadAllDataModel,
                                              )))),
                                }
                            : () => {getDriverData()},
                        child: Padding(
                          padding: EdgeInsets.only(right: 250, top: 50),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff152968),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: space_50,
                            height: space_10,
                            child: Center(
                              child: Text(
                                "Next",
                                style: TextStyle(
                                    color: white,
                                    fontWeight: mediumBoldWeight,
                                    fontSize: size_8 + 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ))
    //Ui for Mobile
        : Scaffold(
            backgroundColor: statusBarColor,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: SizedBox(
              width: 130,
              height: space_9 + 1,
              child: FloatingActionButton(
                child: Text(
                  "Confirm",
                  style: TextStyle(
                      color: white,
                      fontWeight: mediumBoldWeight,
                      fontSize: size_8 + 2),
                ),
                onPressed: isSelected
                    ? () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: ((context) {
                            return UpdateBookingDetails(
                              selectedTruck: widget.selectedTruck,
                              selectedDeviceId: widget.selectedDeviceId,
                              driverName: selectedDriver,
                              mobileNo: selectedDriverPhoneNumber,
                              loadAllDataModel: widget.loadAllDataModel,
                            );
                          }))),
                        }
                    : () => {getDriverData()},
                backgroundColor: darkBlueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius_4)),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.symmetric(horizontal: space_2),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: space_4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BackButtonWidget(),
                              SizedBox(
                                width: space_3,
                              ),
                              HeadingTextWidget("Select Driver"),
                              SizedBox(
                                width: space_6,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddDriver(
                                        selectedTruck: widget.selectedTruck,
                                        selectedDeviceId:
                                            widget.selectedDeviceId,
                                        loadAllDataModel:
                                            widget.loadAllDataModel,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: darkBlueColor,
                                ),
                                label: Text(
                                  "Add Driver",
                                  style: TextStyle(
                                      color: const Color(0xFF152968),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: space_3,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: space_3, horizontal: space_3),
                            child: Container(
                              height: space_11,
                              decoration: BoxDecoration(
                                color: widgetBackGroundColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    width: 0.8, color: widgetBackGroundColor),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchedDriver = value;
                                  });
                                  searchoperation(searchedDriver);
                                  selectedDriver = "";
                                  selectedIndex = -1;
                                },
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'searchByName',
                                  icon: Padding(
                                    padding: EdgeInsets.only(left: space_2),
                                    child: Icon(
                                      Icons.search,
                                      color: grey,
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: size_8,
                                    color: grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          searchedDriver.length != 0
                              ? SingleChildScrollView(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    child: ListView.builder(
                                      itemCount: searchedDriverList.length,
                                      itemBuilder: ((context, index) {
                                        return InkWell(
                                          splashColor: Colors.white,
                                          onTap: () {
                                            setState(() {
                                              isSelected = true;
                                              selectedIndex = index;
                                              selectedDriver =
                                                  searchedDriverList[index];
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: space_8,
                                                        right: space_5,
                                                        bottom: space_4,
                                                        top: space_3),
                                                    child: !(index ==
                                                            selectedIndex)
                                                        ? Container(
                                                            height: 15,
                                                            width: 15,
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    space_2,
                                                                    space_2,
                                                                    0,
                                                                    0),
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/icons/deepbluecircle_ic.png"),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 25,
                                                            width: 25,
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    space_2,
                                                                    space_2,
                                                                    0,
                                                                    0),
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    "assets/icons/greencheckcircle_ic.png"),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                  Text(
                                                    "${searchedDriverList[index]} - ${searchedDriverListNumber[index]}",
                                                    style: TextStyle(
                                                      fontSize: size_10,
                                                      fontWeight:
                                                          mediumBoldWeight,
                                                      color: black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: space_5,
                                                    right: space_5),
                                                child: Divider(
                                                  height: size_10,
                                                  color: grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    child: ListView.builder(
                                      itemCount: driverList.length,
                                      itemBuilder: ((context, index) {
                                        return InkWell(
                                          splashColor: Colors.white,
                                          onTap: () {
                                            setState(() {
                                              isSelected = true;
                                              selectedIndex = index;
                                              selectedDriver =
                                                  driverNames[index];
                                              selectedDriverPhoneNumber =
                                                  driverMobileNumbers[index];
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: space_8,
                                                        right: space_5,
                                                        bottom: space_4,
                                                        top: space_3),
                                                    child:
                                                        (index != selectedIndex)
                                                            ? Container(
                                                                height: 15,
                                                                width: 15,
                                                                padding: EdgeInsets
                                                                    .fromLTRB(
                                                                        space_2,
                                                                        space_2,
                                                                        0,
                                                                        0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        "assets/icons/deepbluecircle_ic.png"),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 25,
                                                                width: 25,
                                                                padding: EdgeInsets
                                                                    .fromLTRB(
                                                                        space_2,
                                                                        space_2,
                                                                        0,
                                                                        0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        "assets/icons/greencheckcircle_ic.png"),
                                                                  ),
                                                                ),
                                                              ),
                                                  ),
                                                  Text(
                                                    "${driverNames[index]} - ${driverMobileNumbers[index]}",
                                                    style: TextStyle(
                                                      fontSize: size_10,
                                                      fontWeight:
                                                          mediumBoldWeight,
                                                      color: black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: space_5,
                                                    right: space_5),
                                                child: Divider(
                                                  height: size_10,
                                                  color: grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
