import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart';
import 'package:sbi/widget/drawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../constant.dart';
import '../service.dart';
import '../widget/appbar.dart';
import 'package:intl/intl.dart';

class DebitManagementPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  DebitManagementPage({Key? key}) : super(key: key);

  @override
  _DebitManagementPageState createState() => _DebitManagementPageState();
}

class _DebitManagementPageState extends State<DebitManagementPage> {
  List<_ChartData> debtdata = [];
  RxBool isLoading = false.obs;
  RxBool iserror = false.obs;
  RxString date = "".obs;
  RxString errormsg = "".obs;
  RxString apidate = "".obs;
  DateTime selectedDate = DateTime.now();
  RxDouble totalamount = 0.0.obs;
  @override
  void initState() {
    setState(() {
      date.value = DateFormat("MM/dd/yyyy").format(DateTime.now().subtract(const Duration(days: 1)));

      getCompanyAllDebtManagement();
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
        getCompanyDebtManagementFilter();
        isLoading.value = false;
      });
    }
  }

  List<_ChartData> debtData = [];
  List<_ChartData> debtfilterdateData = [];

  getCompanyDebtManagementFilter() async {
    isLoading.value = true;
    var data = await Service.getCompanyDebtManagementDate(apidate.value);
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        for (var i in data["data"]) {
          debtData.add(
            _ChartData(
              i["NoOfAccount"].toString(),
              double.parse(
                i["Amount"].toString(),
              ),
              i["Product"],
            ),
          );
          print(debtData);
        }
      }
      isLoading.value = false;
      debtData.clear();

      flutterToastMsg("Error:No data found!");
      getCompanyAllDebtManagement();
      totalamount.value = 0;
    });
  }

  getCompanyAllDebtManagement() async {
    isLoading.value = true;
    iserror.value = false;
    var data = await Service.getCompanyDebtManagement();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        for (var i in data["data"]) {
          debtData.add(
            _ChartData(
              i["NoOfAccount"].toString(),
              double.parse(
                i["Amount"].toString(),
              ),
              i["Product"],
            ),
          );
          isLoading.value = false;
          print(debtData);
          totalamount.value += i["Amount"];
          print(totalamount.value);
          date.value = i["date"];
          print(date.value);
        }
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
                  "Debt Management",
                  true,
                  true,
                ),
                const SizedBox(
                  height: 20,
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
                            date.value,
                            style: TextStyle(),
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
                    : (debtData.isEmpty == true)
                        ? Center(
                            child: titleText(
                              "Error:No data found!",
                              RED,
                            ),
                          )
                        : SizedBox(
                            height: Get.height - 300,
                            child: SfCircularChart(
                              legend: const Legend(
                                alignment: ChartAlignment.center,
                                orientation: LegendItemOrientation.vertical,
                                isVisible: true,
                                shouldAlwaysShowScrollbar: false,
                                position: LegendPosition.bottom,
                                overflowMode: LegendItemOverflowMode.none,
                                textStyle: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              annotations: <CircularChartAnnotation>[
                                CircularChartAnnotation(
                                  widget: Container(
                                    child: Text(
                                      totalamount.value.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: BLACK,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              series: <CircularSeries<_ChartData, String>>[
                                DoughnutSeries<_ChartData, String>(
                                  dataSource: debtData,
                                  xValueMapper: (_ChartData data, _) =>
                                      data.text.toString(),
                                  yValueMapper: (_ChartData data, _) => data.y,
                                  dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      textStyle: TextStyle(
                                        fontSize: 8,
                                      )),
                                  legendIconType: LegendIconType.circle,
                                )
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

class _ChartData {
  _ChartData(this.x, this.y, [this.text]);
  final String x;
  final num y;
  String? text;
}
