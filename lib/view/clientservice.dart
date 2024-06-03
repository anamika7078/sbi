import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:sbi/widget/drawer.dart';
import '../constant.dart';
import '../service.dart';
import '../widget/appbar.dart';
import 'package:intl/intl.dart';

class ClientServicePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ClientServicePage({Key? key}) : super(key: key);

  @override
  _ClientServicePageState createState() => _ClientServicePageState();
}

class _ClientServicePageState extends State<ClientServicePage>
    with SingleTickerProviderStateMixin {
  RxBool isLoading = false.obs;
  RxBool iserror = false.obs;
  RxString date = "".obs;
  RxString errormsg = "".obs;
  RxString apidate = "".obs;
  DateTime selectedDate = DateTime.now();
  RxDouble totalamount = 0.0.obs;
  late TabController tabController;
  RxList tablefiuturnover = [].obs;
  RxList tablefiuoutstanding = [].obs;
  RxList tablefiubranchwise = [].obs;
  @override
  void initState() {
    setState(() {
      // date.value = DateFormat("MM/dd/yyyy").format(DateTime.now());
      tabController = TabController(length: 3, vsync: this);
      getFIUTurnoverClientService();
      getFIUOutstandingClientService();
      getFIUBranchWiseClientService();
    });

    super.initState();
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        isLoading.value = true;
        selectedDate = picked;
        date.value = DateFormat("MM/dd/yyyy").format(picked);
        apidate.value = DateFormat("yyyy-MM-dd").format(picked);
        getFIUTurnoverClientService();
        getFIUOutstandingClientService();
        getFIUBranchWiseClientService()();
        isLoading.value = false;
      });
    }
  }

  getFIUTurnoverClientService() async {
    isLoading.value = true;
    iserror.value = false;
    var data = await Service.getFIUTurnoverClientService(apidate.value);
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tablefiuturnover.value = data["data"];
        print(tablefiuturnover);
      }
    });
    isLoading.value = false;
  }

  getFIUOutstandingClientService() async {
    isLoading.value = true;
    iserror.value = false;
    var data = await Service.getFIUOutstandingClientService(apidate.value);
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tablefiuoutstanding.value = data["data"];
        print(tablefiuoutstanding);
      }
    });
    isLoading.value = false;
  }

  getFIUBranchWiseClientService() async {
    isLoading.value = true;
    iserror.value = false;
    var data = await Service.getFIUBranchwiseClientService(apidate.value);
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tablefiubranchwise.value = data["data"];
        print(tablefiubranchwise);
      }
    });
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GREY,
      body: Obx(
        () {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppBarWidget(
                  "Client Service",
                  true,
                  true,
                ),
                TabBar(
                  labelColor: PURPLE,
                  indicatorColor: PINK,
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsets.all(10),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const <Widget>[
                    Tab(
                      text: 'Snapshot of FIU and Turnover',
                    ),
                    Tab(
                      text: 'Branchwise FIU (DF,EF and RF)',
                    ),
                    Tab(
                      text: 'LC - Region wise FIU Outstanding',
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: WHITE,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: GREY_DARK,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            date.value == "" ? "Select Date" : date.value,
                            style: TextStyle(
                              color: GREY_DARK,
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectDate(context);
                                });
                              },
                              child: Icon(
                                Icons.calendar_month,
                                color: PINK,
                                size: 18,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                (isLoading.value)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: loadingWidget()),
                      )
                    : (tablefiuturnover.isEmpty == true ||
                            tablefiubranchwise.isEmpty == true ||
                            tablefiuoutstanding.isEmpty == true)
                        ? Center(
                            child: titleText(
                              "Error:No data found!",
                              RED,
                            ),
                          )
                        : Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                //turnover table
                                DataTable(
                                  dataRowMinHeight: 20.0,
                                  columnSpacing: 5.0,
                                  horizontalMargin: 10,
                                  border: TableBorder(
                                    verticalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    horizontalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    top: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    bottom: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                  ),
                                  showBottomBorder: true,
                                  dataTextStyle: TextStyle(wordSpacing: 1),
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Particulars', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-23', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('30-APR-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('16-MAY-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('31-MAY-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    // Set the values to the columns
                                    for (var i in tablefiuturnover)
                                      DataRow(
                                        cells: [
                                          DataCell(smallText(
                                              (i["Particulars"]), BLACK)),
                                          DataCell(
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: smallText(
                                                i["col_5"].toString(),
                                                BLACK,
                                                FontWeight.normal,
                                                TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  i["col_4"].toString(),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_2"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_3"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_1"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                //BranchWise table
                                DataTable(
                                  dataRowMinHeight: 20.0,
                                  columnSpacing: 5.0,
                                  horizontalMargin: 10,
                                  border: TableBorder(
                                    verticalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    horizontalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    top: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    bottom: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                  ),
                                  showBottomBorder: true,
                                  dataTextStyle: TextStyle(wordSpacing: 1),
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Particulars', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-23', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('16-MAY-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('YOD %', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('SEP 24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    // Set the values to the columns
                                    for (var i in tablefiubranchwise)
                                      DataRow(
                                        cells: [
                                          DataCell(smallText(
                                              (i["Particulars"]), BLACK)),
                                          DataCell(
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: smallText(
                                                i["col_5"].toString(),
                                                BLACK,
                                                FontWeight.normal,
                                                TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  i["col_1"].toString(),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_2"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                decoration: BoxDecoration(
                                                  color: (i["col_3"] <= 0.0)
                                                      ? RED
                                                      : (i["col_3"] >= 33)
                                                          ? GREEN
                                                          : Colors.yellow,
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_3"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_4"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                //outstanding
                                DataTable(
                                  dataRowMinHeight: 20.0,
                                  columnSpacing: 5.0,
                                  horizontalMargin: 10,
                                  border: TableBorder(
                                    verticalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    horizontalInside: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    top: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                    bottom: BorderSide(
                                        color: GREY_DARK, width: 0.5),
                                  ),
                                  showBottomBorder: true,
                                  dataTextStyle: TextStyle(wordSpacing: 1),
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Particulars', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-23', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('Mar-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('30-APR-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('13-MAY-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 50,
                                        child: smallText('16-MAY-24', PINK,
                                            FontWeight.bold, TextAlign.center),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    // Set the values to the columns
                                    for (var i in tablefiuoutstanding)
                                      DataRow(
                                        cells: [
                                          DataCell(smallText(
                                              (i["Particulars"]), BLACK)),
                                          DataCell(
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: smallText(
                                                "0",
                                                BLACK,
                                                FontWeight.normal,
                                                TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  i["col_4"].toString(),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_2"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_3"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                          DataCell(
                                            Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: smallText(
                                                  (i["col_1"].toString()),
                                                  BLACK,
                                                  FontWeight.normal,
                                                  TextAlign.right,
                                                )),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
              ],
            ),
          );
        },
      ),
      drawer: WeDrawer(),
    );
  }
}
