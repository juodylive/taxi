import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zearah_driver/core/utils/translate.dart';
import '../../../core/extensions/workspace.dart';
import '../../../core/utils/common_widget.dart';
import '../../../core/utils/theme/project_color.dart';
import '../../../core/utils/theme/theme_style.dart';
import '../../../domain/entities/history.dart';
import '../../cubits/history/history_cubit.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool? isBackButton;
  const HistoryScreen({super.key, this.isBackButton});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData(isInitial: true);
    });
  }

  List<Bookings> bookings = [];
  int offset = 0;
  bool isPaginating = true;
  int? selectedIndex = 0;

  Future<void> fetchData({bool isInitial = false}) async {
    if (isInitial) {
      offset = 0;
    }
    await context.read<HistoryCubit>().getHistoryData(
      context: context,

      bookingKeyMap: {
        "type": statuses[selectedIndex!].toLowerCase(),
        "offset": offset.toString()
      },type:statuses[selectedIndex!].toLowerCase()
    );
  }

  final List<String> statuses = [
    "Completed",
    "Rejected",
    "Cancelled",
  ];

  RefreshController refreshController = RefreshController();
  void onRefresh() async {
    bookings.clear();
    offset = 0;

    isPaginating = true;
    await fetchData(isInitial: true);

    refreshController.refreshCompleted();
  }

  void onLoading() async {
    if (offset == -1) {
      refreshController.loadComplete();
      refreshController.loadNoData();
      return;
    }

    isPaginating = false;
    await fetchData();
    refreshController.loadComplete();
  }

  String formatSimpleDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return "";

      // Parse date with or without time
      final inputDate = DateTime.tryParse(dateStr);
      if (inputDate == null) return dateStr;

      // Format to your desired style
      final formattedDate = DateFormat("dd MMM yyyy").format(inputDate);
      return formattedDate;
    } catch (e) {
      return dateStr;
    }
  }

  get fontSize => null;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (widget.isBackButton == true) {
          return true;
        }

        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: widget.isBackButton == true
            ? const CustomAppBar(title: "History")
            : AppBar(
                surfaceTintColor: whiteColor,
                title: Text(
                  "History".translate(context),
                  style: headingBlack(context)
                      .copyWith(fontSize: 22, color: blackColor),
                ),
                backgroundColor: whiteColor,
                automaticallyImplyLeading: false,
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(statuses.length, (index) {
                final bool isSelected = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isSelected) return;
                      bookings.clear();
                      setState(() {
                        selectedIndex = index;
                      });
                      fetchData(isInitial: true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: regular2(context).copyWith(
                          color: isSelected ? grey1 : Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        child: Text(
                          statuses[index].translate(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),




          const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) {
                if (state is HistoryLoading && isPaginating) {
                  return ListView.builder(
                    itemCount: 6,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Shimmer.fromColors(
                          baseColor: grey5,
                          highlightColor: grey4,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is HistorySuccess) {
                  if(statuses[selectedIndex!].toLowerCase()==state.type){
                    isPaginating=true;

                    if(offset==0){
                      bookings.clear();
                      bookings=(state.bookings??[]);
                    }else{
                      bookings.addAll(state.bookings??[]);
                    }

                    offset=state.historyModel?.data?.offset??0;
                    context.read<HistoryCubit>().resetHistoryData();
                  }
                }

                return SmartRefresher(
                  controller: refreshController,
                  onRefresh: onRefresh,
                  onLoading: onLoading,
                  enablePullUp: offset == -1 ? false : true,
                  child: bookings.isEmpty
                      ? Center(
                          child: Text(
                          "No data available".translate(context),
                          style: regular2(context),
                        ))
                      : ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final rideData = bookings[index];
                            return GestureDetector(
                              onTap: () {
                                goTo(HistoryDetailScreen(rideData: rideData));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 25),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: grey5,
                                        blurRadius: 4.0,
                                        spreadRadius: 1.0,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (rideData.status != null &&
                                          rideData.status!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: getStatusBackground(
                                                    rideData.status!)),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: getStatusBackground(
                                                rideData.status!),
                                          ),
                                          child: Text(
                                            rideData.status!.translate(context),
                                            style:
                                                headingBlack(context).copyWith(
                                              color: getStatusColor(
                                                  rideData.status!),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 15),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  color: themeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Image.asset(
                                                  "assets/images/line2.png",
                                                  color: blackColor,
                                                  scale: 3),
                                              const SizedBox(height: 5),
                                              Container(
                                                height: 45,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  color: whiteColor,
                                                  border: Border.all(
                                                      width: 1, color: grey4),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10),
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                    color: blackColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rideData.pickupLocation
                                                          ?.address ??
                                                      "",
                                                  style: headingBlack(context)
                                                      .copyWith(fontSize: 14),
                                                  softWrap: true,
                                                ),
                                                const SizedBox(height: 28),
                                                Text(
                                                  rideData.dropoffLocation
                                                          ?.address ??
                                                      "",
                                                  style: headingBlack(context)
                                                      .copyWith(fontSize: 14),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "$currency ${rideData.total}",
                                            style: headingBlack(context)
                                                .copyWith(color: greentext),
                                          ),
                                          Text(
                                            formatSimpleDate(
                                                "${rideData.rideDate}"),
                                            style: regular3(context)
                                                .copyWith(fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class RideHistory {
  final String dateTime;
  final String pickupAddress;
  final String dropOffAddress;
  final double price;
  final String status;

  RideHistory({
    required this.dateTime,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.price,
    required this.status,
  });
}
