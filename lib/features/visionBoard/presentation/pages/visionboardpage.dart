import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/data/textstyles.dart';
import 'package:airaapp/features/history/components/history_buttons.dart';
import 'package:airaapp/features/visionBoard/components/vision_board_button.dart';
import 'package:airaapp/features/visionBoard/data/visionBoard_impl.dart';
import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_bloc.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_events.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VisionBoardPage extends StatefulWidget {
  const VisionBoardPage({super.key});

  @override
  State<VisionBoardPage> createState() => _VisionBoardPageState();
}

class _VisionBoardPageState extends State<VisionBoardPage> {
  late VisionBoardBloc _visionBoardBloc;
  final GlobalKey _scatterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _visionBoardBloc = VisionBoardBloc(repository: VisionBoardImpl());
    _visionBoardBloc.add(LoadVisionGoals());
  }

  @override
  void dispose() {
    _visionBoardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.mainbgColor,
        centerTitle: false,
        title: Text(
          'My Vision Board',
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Appcolors.maintextColor)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
                color: Appcolors.innerdarkcolor,
                borderRadius: BorderRadius.circular(12)),
            child: IconButton(
                onPressed: () => _showAddGoalDialog(context),
                icon: SvgPicture.asset('lib/data/assets/add_reminder.svg')),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: BlocConsumer<VisionBoardBloc, VisionBoardState>(
        bloc: _visionBoardBloc,
        listener: (context, state) {
          if (state is VisionBoardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is VisionBoardLoading) {
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
                child: Center(
                    child: CircularProgressIndicator(
                  color: Appcolors.deepdarColor,
                )));
          } else if (state is VisionBoardEmpty) {
            return _buildEmptyState(context);
          } else if (state is VisionBoardLoaded) {
            return _buildGoalsList(state.goals, context);
          } else if (state is VisionBoardError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'A space for your dreams, hopes, and future plans — waiting to bloom.',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Appcolors.maintextColor,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Let\'s grow together, one intention at a time. No long-term goals yet? Add a few and let your vision take root:',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Appcolors.maintextColor,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          HistoryButton(
            onTap: () => _showAddGoalDialog(context),
            iconUrl: 'lib/data/assets/add_reminder.svg',
            text: 'Add your dream',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<VisionGoal> goals, BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'A space for your dreams, hopes, and future plans — waiting to bloom.',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Appcolors.maintextColor)),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RepaintBoundary(
              key: _scatterKey,
              child: goals.isEmpty
                  ? const Center(child: Text("No goals yet"))
                  : _buildScatterWordCloud(goals),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          HistoryButton(
              onTap: () => _downloadWordCloud(), iconUrl: "", text: 'Download'),
          const Spacer()
        ],
      ),
    );
  }

  Future<void> _downloadWordCloud() async {
    try {
      print('initaited the download process');
      // Ask for permissions
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      RenderRepaintBoundary boundary = _scatterKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/word_cloud_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(pngBytes);

      final result = await ImageGallerySaver.saveFile(file.path);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Word cloud downloaded to gallery!')),
        );
      } else {
        throw Exception('Saving failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
    }
  }

  Widget _buildScatterWordCloud(List<VisionGoal> goals) {
    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;
    final widgets = goals
        .asMap()
        .entries
        .map((entry) => _ScatterGoalWidget(entry.value, entry.key))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Appcolors.lightdarlColor,
            borderRadius: BorderRadius.circular(12)),
        child: FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
            children: widgets,
          ),
        ),
      ),
    );
  }

  Widget _ScatterGoalWidget(VisionGoal goal, int index) {
    final random = Random(goal.text.hashCode);
    final style = textStyles[random.nextInt(textStyles.length)];

    return RotatedBox(
      quarterTurns: random.nextBool() ? 1 : 0,
      child: Text(goal.text, style: style),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return BlocListener<VisionBoardBloc, VisionBoardState>(
          bloc: _visionBoardBloc,
          listener: (context, state) {
            if (state is VisionBoardLoaded) {
              Navigator.of(context).pop();
            }
          },
          child: AlertDialog(
            backgroundColor: Appcolors.lightdarlColor,
            title: Text(
              'Leave a note for your future self',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Appcolors.maintextColor)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('I\'ll be here to remind you when the\nmoment is right ❤️',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Appcolors.maintextColor))),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Appcolors.deepdarColor,
                    hintText: 'Enter your goal, let me help you',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ],
            ),
            actions: [
              VisionBoardButton(
                onTap: () {
                  Navigator.of(context).pop();
                },
                text: 'cancel',
              ),
              VisionBoardButton(
                  onTap: () {
                    if (textController.text.isNotEmpty) {
                      _visionBoardBloc.add(AddVisionGoal(textController.text));
                    }
                  },
                  text: 'Done')
            ],
          ),
        );
      },
    );
  }
}
