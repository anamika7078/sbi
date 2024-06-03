import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:sbi/widget/drawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../constant.dart';
import '../service.dart';
import '../widget/appbar.dart';

class TreasuryPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TreasuryPage({Key? key}) : super(key: key);

  @override
  _TreasuryPageState createState() => _TreasuryPageState();
}

class _TreasuryPageState extends State<TreasuryPage>
    with SingleTickerProviderStateMixin {
  RxBool isLoading = false.obs;
  late TabController tabController;
  RxList tableRFR = [].obs;
  RxList tableCredit = [].obs;
  RxList tablePRR = [].obs;
  RxList tableCOB = [].obs;
  @override
  void initState() {
    setState(() {
      tabController = TabController(length: 3, vsync: this);
      getCompanyTreasury();
      getRFR();
      getCreditRating();
      getPRR();
      getCOB();
    });

    super.initState();
  }

  List<_ChartData> debtData = [];

  getCompanyTreasury() async {
    isLoading.value = true;

    var data = await Service.getCompanytreasury();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        for (var i in data["data"]) {
          debtData.add(
            _ChartData("TIER_II_BOND",
                double.parse(i["TIER_II_BOND"].toString()), BLUE),
          );
          debtData.add(
            _ChartData(
                "Commercial_Paper",
                double.parse(i["Commercial_Paper"].toString()),
                Colors.deepOrange),
          );
          debtData.add(
            _ChartData("Bank_Line_WCL",
                double.parse(i["Bank_Line_WCL"].toString()), RED),
          );
          debtData.add(
            _ChartData("FOREX", double.parse(i["FOREX"].toString()), GREEN),
          );

          isLoading.value = false;
          print(debtData);
        }
      }
    });
    isLoading.value = false;
  }

  getRFR() async {
    var data = await Service.getRFR();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tableRFR.value = data["data"];
        print(tableRFR);
      }
    });
  }

  getCreditRating() async {
    var data = await Service.getCreditRating();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tableCredit.value = data["data"];
        print(tableCredit);
      }
    });
  }

  getPRR() async {
    var data = await Service.getCreditPRR();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tablePRR.value = data["data"];
        print(tableCredit);
      }
    });
  }

  getCOB() async {
    var data = await Service.getCreditCOB();
    print(data);
    setState(() {
      if (data["outcome"]["outcomeId"] == 1) {
        tableCOB.value = data["data"];
        print(tableCredit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GREY,
      body: Obx(
        () {
          return SafeArea(
              child: Column(
            children: [
              AppBarWidget(
                "Treasury Dashboard",
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
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const <Widget>[
                  Tab(
                    text: 'Borrowing',
                  ),
                  Tab(
                    text: 'RFR and Credit Rating',
                  ),
                  Tab(
                    text: 'PRR and COB',
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    //Borrowing
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
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  // height: Get.height - 300,
                                  child: SfCartesianChart(
                                    primaryXAxis: const CategoryAxis(
                                      labelPlacement:
                                          LabelPlacement.betweenTicks,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      labelStyle: TextStyle(fontSize: 8),
                                    ),
                                    primaryYAxis: const NumericAxis(
                                      labelStyle: TextStyle(fontSize: 10),
                                    ),
                                    enableAxisAnimation: true,
                                    zoomPanBehavior: ZoomPanBehavior(
                                      enablePanning: true,
                                    ),
                                    series: <CartesianSeries<_ChartData,
                                        String>>[
                                      ColumnSeries(
                                        color: RED,
                                        pointColorMapper:
                                            (_ChartData data, _) => data.color,
                                        dataSource: debtData,

                                        dataLabelSettings:
                                            const DataLabelSettings(
                                                isVisible: true,
                                                textStyle:
                                                    TextStyle(fontSize: 10)),
                                        xValueMapper: (_ChartData data, _) =>
                                            data.treasury.toString(),
                                        yValueMapper: (_ChartData data, _) =>
                                            data.count,
                                        width: 0.8, // Width of the columns
                                        spacing: 0.2,
                                      )
                                    ],
                                  ),
                                ),
                              ),

                    ///RFR & Crdit rating
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: titleText(
                              "Risk Free Rate (RFR)",
                              PINK,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DataTable(
                            // dataRowMinHeight: 20.0,
                            columnSpacing: 10.0,
                            // horizontalMargin: 10,
                            dataRowColor:
                                MaterialStateProperty.all(Colors.white),
                            headingRowColor: MaterialStateProperty.all(PURPLE),

                            border: const TableBorder(
                              verticalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              horizontalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              top: BorderSide(color: GREY_DARK, width: 0.5),
                              bottom: BorderSide(color: GREY_DARK, width: 0.5),
                            ),
                            showBottomBorder: true,
                            // dataTextStyle: const TextStyle(wordSpacing: 1),
                            columns: const [
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 55,
                                      child: Text(
                                        'SR NO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: WHITE,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 55,
                                      child: Text(
                                        'CURRENCY',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: WHITE,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 55,
                                      child: Text(
                                        'RFR',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: WHITE,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 55,
                                      child: Text(
                                        'PERIOD',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: WHITE,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                      child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'AMOUNT (%)',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                            ],
                            rows: [
                              // Set the values to the columns
                              for (var i in tableRFR)
                                DataRow(
                                  cells: [
                                    DataCell(Center(
                                      child: smallText(
                                          (tableRFR.indexOf(i) + 1).toString(),
                                          BLACK),
                                    )),
                                    DataCell(
                                      Center(
                                        child: smallText(
                                          i["Currency"].toString(),
                                          BLACK,
                                          FontWeight.normal,
                                          TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        i["rfr"].toString(),
                                        BLACK,
                                        FontWeight.normal,
                                        TextAlign.right,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        (i["EffectiveDate"]
                                            .toString()
                                            .substring(0, 10)),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        (i["Rate"].toString()),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: titleText(
                              "Credit Rating",
                              PINK,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DataTable(
                            dataRowMinHeight: 20.0,
                            columnSpacing: 5.0,
                            horizontalMargin: 10,
                            dataRowColor:
                                MaterialStateProperty.all(Colors.white),
                            headingRowColor: MaterialStateProperty.all(PURPLE),
                            border: const TableBorder(
                              verticalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              horizontalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              top: BorderSide(color: GREY_DARK, width: 0.5),
                              bottom: BorderSide(color: GREY_DARK, width: 0.5),
                            ),
                            showBottomBorder: true,
                            dataTextStyle: const TextStyle(wordSpacing: 1),
                            columns: const [
                              DataColumn(
                                  label: Expanded(
                                child: Center(
                                  child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'SR NO',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Expanded(
                                      child: Center(
                                child: SizedBox(
                                  width: 55,
                                  child: Text(
                                    'RATIONALE DATED',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: WHITE,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ))),
                              DataColumn(
                                label: Expanded(
                                    child: Center(
                                  child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'COMPANY NAME',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )),
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Center(
                                  child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'LONG TERM RATING',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                      child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'SHORT TERM RATING',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                            ],
                            rows: [
                              // Set the values to the columns
                              for (var i in tableCredit)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: smallText(
                                            (tableCredit.indexOf(i) + 1)
                                                .toString(),
                                            BLACK),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: smallText(
                                          i["cr_createddate"]
                                              .toString()
                                              .substring(0, 10),
                                          BLACK,
                                          FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        i["cr_companyname"].toString(),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        (i["cr_ltr"].toString()),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        (i["cr_str"].toString()),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //PRR and cob
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: titleText(
                              "Prime Reference Rate (PRR)",
                              PINK,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: DataTable(
                              // dataRowMinHeight: 20.0,
                              columnSpacing: 80.0,
                              // horizontalMargin: 10,
                              dataRowColor:
                                  MaterialStateProperty.all(Colors.white),
                              headingRowColor:
                                  MaterialStateProperty.all(PURPLE),
                              border: const TableBorder(
                                verticalInside:
                                    BorderSide(color: GREY_DARK, width: 0.5),
                                horizontalInside:
                                    BorderSide(color: GREY_DARK, width: 0.5),
                                top: BorderSide(color: GREY_DARK, width: 0.5),
                                bottom:
                                    BorderSide(color: GREY_DARK, width: 0.5),
                              ),
                              showBottomBorder: true,
                              // dataTextStyle: const TextStyle(wordSpacing: 1),
                              columns: [
                                DataColumn(
                                  label: Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        width: 55,
                                        child: Text(
                                          'SR NO',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: WHITE,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                      child: Center(
                                          child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'DATE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ))),
                                ),
                                DataColumn(
                                  label: Expanded(
                                      child: Center(
                                          child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'RATE(%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ))),
                                ),
                              ],
                              rows: [
                                // Set the values to the columns
                                for (var i in tablePRR)
                                  DataRow(
                                    cells: [
                                      DataCell(Center(
                                          child: smallText(
                                              (tablePRR.indexOf(i) + 1)
                                                  .toString(),
                                              BLACK))),
                                      DataCell(
                                        Center(
                                          child: smallText(
                                            i["pr_date"]
                                                .toString()
                                                .substring(0, 10),
                                            BLACK,
                                            FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                            child: smallText(
                                          "${i["pr_rate"]}%",
                                          BLACK,
                                          FontWeight.normal,
                                        )),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: titleText(
                              "Cost of Borrowing (COB)",
                              PINK,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DataTable(
                            // dataRowMinHeight: 20.0,
                            columnSpacing: 10.0,
                            // horizontalMargin: 10,
                            dataRowColor:
                                MaterialStateProperty.all(Colors.white),
                            headingRowColor: MaterialStateProperty.all(PURPLE),
                            border: const TableBorder(
                              verticalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              horizontalInside:
                                  BorderSide(color: GREY_DARK, width: 0.5),
                              top: BorderSide(color: GREY_DARK, width: 0.5),
                              bottom: BorderSide(color: GREY_DARK, width: 0.5),
                            ),
                            showBottomBorder: true,
                            // dataTextStyle: const TextStyle(wordSpacing: 1),
                            columns: [
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 55,
                                      child: Text(
                                        'SR NO',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: WHITE,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                    child: Center(
                                        child: SizedBox(
                                  width: 55,
                                  child: Text(
                                    'PERIOD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: WHITE,
                                      fontSize: 10,
                                    ),
                                  ),
                                ))),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                      child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'FINANCIAL YEAR',
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                      child: SizedBox(
                                    width: 55,
                                    child: Text(
                                      'AVERAGE COB (INCLUDING NCDS) (%)',
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WHITE,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Center(
                                      child: SizedBox(
                                          width: 55,
                                          child: Text(
                                            'MARGINAL COB (EXCLUDING NCDS) (%)',
                                            textAlign: TextAlign.center,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: WHITE,
                                              fontSize: 10,
                                            ),
                                          ))),
                                ),
                              ),
                            ],
                            rows: [
                              // Set the values to the columns
                              for (var i in tableCOB)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: smallText(
                                            (tableCOB.indexOf(i) + 1)
                                                .toString(),
                                            BLACK),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: smallText(
                                          i["cob_period"].toString(),
                                          BLACK,
                                          FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        i["cob_finantialyear"].toString(),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        ("${i["cob_includingncd"]}%"),
                                        BLACK,
                                        FontWeight.normal,
                                      )),
                                    ),
                                    DataCell(
                                      Center(
                                          child: smallText(
                                        ("${i["cob_excludingncd"]}%"),
                                        BLACK,
                                        FontWeight.normal,
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
              ),
            ],
          ));
        },
      ),
      drawer: WeDrawer(),
    );
  }
}

class _ChartData {
  _ChartData(
    this.treasury,
    this.count,
    this.color,
  );
  final double count;
  final String treasury;
  final Color? color;
}
