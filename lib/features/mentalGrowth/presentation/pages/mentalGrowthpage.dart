import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/mentalGrowth/domain/models/sentiment_analysis.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_bloc.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_events.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class MentalGrowthPage extends StatefulWidget {
  const MentalGrowthPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MentalGrowthPage> createState() => _MentalGrowthPageState();
}

class _MentalGrowthPageState extends State<MentalGrowthPage> {
  @override
  void initState() {
    super.initState();
    context.read<SentimentBloc>().add(LoadSentiments());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.mainbgColor,
        centerTitle: false,
        title: Text(
          'Mental Growth',
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.w700,
                  color: Appcolors.maintextColor)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black, // border color
            height: 1.0,
          ),
        ),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back)),
      ),
      body: BlocConsumer<SentimentBloc, SentimentState>(
        listener: (context, state) {
          // You can add snackbars or additional logic on state change here if needed
          if (state is SentimentError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SentimentInitial || state is SentimentLoading) {
            return FutureBuilder(
              future: Future.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Center(
                      child: Text("Processing...")); // You can replace this
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Appcolors.mainbgColor,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.2),
                          BlendMode.dstATop,
                        ),
                        image: const AssetImage('lib/data/assets/bgimage.jpeg'),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'lib/data/assets/lottie/fire.json',
                            width: height * 0.05,
                            height: height * 0.05,
                            fit: BoxFit.contain,
                          ),
                          //loading text
                          Text(
                            'Loading...',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Appcolors.textFiledtextColor,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02)),
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          } else if (state is SentimentError) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Appcolors.mainbgColor,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.dstATop,
                    ),
                    image: const AssetImage('lib/data/assets/bgimage.jpeg'),
                  ),
                ),
                child: Center(child: Text(state.message)));
          } else if (state is SentimentLoaded) {
            return _buildContent(state.sentiments, context);
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }

  Widget _buildContent(
      List<SentimentAnalysis> sentiments, BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (sentiments.isEmpty) {
      return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Appcolors.mainbgColor,
            image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.dstATop,
              ),
              image: const AssetImage('lib/data/assets/bgimage.jpeg'),
            ),
          ),
          child: Center(child: Text('No sentiment data available')));
    }

    // Sort by date
    sentiments.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Appcolors.mainbgColor,
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.dstATop,
              ),
              image: AssetImage(
                'lib/data/assets/bgimage.jpeg',
              ))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //show context text here
            Text(
              maxLines: 2,
              "I've been gently tracking your mental growth, day by day — just for you 🌱✨.",
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: height * 0.017,
                      fontWeight: FontWeight.w700,
                      color: Appcolors.maintextColor)),
            ),
            SizedBox(
              height: 10,
            ),
            _buildChart(sentiments),
            const SizedBox(height: 24),
            _buildLatestSentiment(sentiments.last, context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<SentimentAnalysis> sentiments) {
    final Map<String, List<SentimentAnalysis>> grouped = {};
    for (var sentiment in sentiments) {
      grouped.putIfAbsent(sentiment.date, () => []).add(sentiment);
    }

    final List<MapEntry<String, double>> groupedData =
        grouped.entries.map((entry) {
      final avgScore =
          entry.value.map((e) => e.mentalScore).reduce((a, b) => a + b) /
              entry.value.length;
      return MapEntry(entry.key, avgScore);
    }).toList();

    groupedData
        .sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX:
              groupedData.length > 1 ? (groupedData.length - 1).toDouble() : 1,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: groupedData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.cyanAccent, Colors.lightBlueAccent],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.cyanAccent.withOpacity(0.3),
                    Colors.lightBlueAccent.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          gridData: FlGridData(show: false), // ❌ remove grid lines
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= groupedData.length) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime.parse(groupedData[index].key);
                  final formatted =
                      DateFormat('E d').format(date); // e.g., Sun 13
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      formatted,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if ([0, 25, 50, 75, 100].contains(value.toInt())) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData:
              FlBorderData(show: false), // ❌ remove border (x and y axis lines)
        ),
      ),
    );
  }

  Widget _buildLatestSentiment(
      SentimentAnalysis sentiment, BuildContext context) {
    final date = DateTime.parse(sentiment.date);
    final height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Appcolors.textFiledtextColor),
          color: Appcolors.containerbgColor,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //show the aira image and the context text...
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //show the airaimage
              Image.asset(
                'lib/data/assets/mental_growth_airaimage.png',
                height: height * 0.085,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              //context text...
              Text(
                "Aira's Daily\nReflection",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Appcolors.maintextColor,
                        fontSize: height * 0.028)),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sentiment.mentalScore < 50
                  ? Image.asset(
                      "lib/data/assets/simple_smile.png",
                      height: 20,
                      width: 20,
                    )
                  : Image.asset(
                      'lib/data/assets/laugh_smile.png',
                      height: 20,
                      width: 20,
                    ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: height * 0.016,
                        color: Appcolors.maintextColor,
                        height: 1.4,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: "${DateFormat('EEE').format(date)} - ",
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: height * 0.017,
                                fontWeight: FontWeight.w700,
                                color: Appcolors.maintextColor)),
                      ),
                      TextSpan(
                          text: sentiment.reflectionText,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: height * 0.017,
                                  fontWeight: FontWeight.w400,
                                  color: Appcolors.maintextColor))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('lib/data/assets/chat.png'),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: height * 0.016,
                        color: Appcolors.maintextColor,
                        height: 1.4,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: "You said: ",
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: height * 0.017,
                                fontWeight: FontWeight.w700,
                                color: Appcolors.maintextColor)),
                      ),
                      TextSpan(
                          text: sentiment.supportingText,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: height * 0.017,
                                  fontWeight: FontWeight.w400,
                                  color: Appcolors.maintextColor))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('lib/data/assets/plant.png'),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: height * 0.017,
                        color: Appcolors.maintextColor,
                        height: 1.4,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text: 'Suggestions: ',
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: height * 0.017,
                                fontWeight: FontWeight.w700,
                                color: Appcolors.maintextColor)),
                      ),
                      TextSpan(
                          text: sentiment.suggestions
                              .map((s) => '• $s')
                              .join('\n'),
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: height * 0.017,
                                  fontWeight: FontWeight.w400,
                                  color: Appcolors.maintextColor))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
