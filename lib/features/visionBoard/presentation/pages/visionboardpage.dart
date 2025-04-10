import 'dart:math';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/visionBoard/data/visionBoard_impl.dart';
import 'package:airaapp/features/visionBoard/domain/entity/goal_entity.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_bloc.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_events.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class VisionBoardPage extends StatefulWidget {
  const VisionBoardPage({super.key});

  @override
  State<VisionBoardPage> createState() => _VisionBoardPageState();
}

class _VisionBoardPageState extends State<VisionBoardPage> {
  late VisionBoardBloc _visionBoardBloc;

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
        title: const Text('My Vision Board'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            return const Center(child: CircularProgressIndicator());
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'A space for your dreams, hopes, and future plans — waiting to bloom.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Let\'s grow together, one intention at a time. No long-term goals yet? Add a few and let your vision take root:',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showAddGoalDialog(context),
            child: const Text('Add your dream'),
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: goals.isEmpty
                ? const Center(child: Text("No goals yet"))
                : _buildScatterLayout(goals, context),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () => _showAddGoalDialog(context),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScatterLayout(List<VisionGoal> goals, BuildContext context) {
    final random = Random(42);
    return RefreshIndicator(
      onRefresh: () async {
        _visionBoardBloc.add(LoadVisionGoals());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: goals.map((goal) {
              final rotation = random.nextDouble() * 0.2 - 0.1;
              return Transform.rotate(
                angle: rotation,
                child: _buildGoalCard(goal),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(VisionGoal goal) {
    final random = Random(goal.text.hashCode);
    final rotation = random.nextDouble() * 0.2 - 0.1;
    final color =
        Colors.accents[random.nextInt(Colors.accents.length)].shade200;

    return Transform.rotate(
      angle: rotation,
      child: Card(
        color: color.withOpacity(0.7),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 200,
            ),
            child: Text(
              goal.text.isNotEmpty ? goal.text : 'Empty goal',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 14 + random.nextDouble() * 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
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
            title: const Text('Leave a note for your future self'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'I\'ll be here to remind you when the moment is right 💤',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your goal, let me help you',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    _visionBoardBloc.add(AddVisionGoal(textController.text));
                  }
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
}
