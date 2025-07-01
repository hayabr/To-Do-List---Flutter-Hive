// ignore_for_file: must_be_immutable

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:todoohive/data/hive_data_store.dart';
import 'package:todoohive/view/auth/sign_in_view.dart';
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../utils/strings.dart';
import 'widgets/task_widget.dart';
import '../tasks/task_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();

  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  dynamic valueOfTheIndicator(List<Task> task) {
    if (task.isNotEmpty) {
      return task.length;
    } else {
      return 3;
    }
  }

  void warningNoTask(BuildContext context) {
    PanaraInfoDialog.show(
      context,
      title: MyString.noTaskWarning,
      message: "There are no tasks to delete!",
      buttonText: "Okay",
      onTapDismiss: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.warning,
    );
  }

  void deleteAllTask(BuildContext context) {
    PanaraConfirmDialog.show(
      context,
      title: MyString.deleteAllTasks,
      message: "Are you sure you want to delete all tasks?",
      confirmButtonText: "Delete",
      cancelButtonText: "Cancel",
      onTapCancel: () => Navigator.pop(context),
      onTapConfirm: () {
        BaseWidget.of(context).dataStore.deleteAllTasks();
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    var textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base.dataStore.listenToTask(),
      builder: (ctx, Box<Task> box, Widget? child) {
        var tasks = base.dataStore.getUserTasks();
        tasks.sort(((a, b) => a.createdAtDate.compareTo(b.createdAtDate)));
        print('Tasks in HomeView: ${tasks.map((t) => t.title).toList()}');

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: const FAB(),
          body: SliderDrawer(
            isDraggable: false,
            key: dKey,
            animationDuration: 1000,
            appBar: MyAppBar(drawerKey: dKey),
            slider: MySlider(),
            child: _buildBody(tasks, base, textTheme),
          ),
        );
      },
    );
  }

  SizedBox _buildBody(List<Task> tasks, BaseWidget base, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(55, 0, 0, 0),
            width: double.infinity,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation(
                      MyColors.primaryColor,
                    ),
                    backgroundColor: Colors.grey,
                    value: checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                  ),
                ),
                const SizedBox(width: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(MyString.mainTitle, style: textTheme.displayLarge),
                    const SizedBox(height: 3),
                    Text(
                      "${checkDoneTask(tasks)} of ${tasks.length} task",
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(thickness: 2, indent: 100),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: tasks.isNotEmpty
                  ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        var task = tasks[index];
                        return Dismissible(
                          direction: DismissDirection.horizontal,
                          background: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.delete_outline, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                MyString.deletedTask,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          onDismissed: (direction) {
                            base.dataStore.deleteTask(task: task);
                          },
                          key: Key(task.id),
                          child: TaskWidget(
                            task: tasks[index],
                            onEdit: () {
                              // Navigate to TaskView for editing
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TaskView(
                                    task: tasks[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeIn(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Lottie.asset(
                              lottieURL,
                              animate: tasks.isNotEmpty ? false : true,
                            ),
                          ),
                        ),
                        FadeInUp(
                          from: 30,
                          child: const Text(MyString.doneAllTask),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class MySlider extends StatelessWidget {
  MySlider({Key? key}) : super(key: key);

  List<IconData> icons = [
    CupertinoIcons.home,
    CupertinoIcons.person_fill,
    CupertinoIcons.settings,
    CupertinoIcons.info_circle_fill,
    CupertinoIcons.square_arrow_right,
  ];

  List<String> texts = [
    "Home",
    "Profile",
    "Settings",
    "Details",
    MyString.logout,
  ];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final hiveDataStore = HiveDataStore();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: MyColors.primaryColor,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text("AmirHossein Bayat", style: textTheme.displayMedium),
              Text("junior flutter dev", style: textTheme.displaySmall),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 10,
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    icons.length,
                    (i) => InkWell(
                      onTap: () {
                        if (i == 4) {
                          hiveDataStore.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInView(),
                            ),
                          );
                        } else {
                          print("$i Selected");
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: ListTile(
                          leading: Icon(
                            icons[i],
                            color: Colors.white,
                            size: 30,
                          ),
                          title: Text(
                            texts[i],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.drawerKey});
  final GlobalKey<SliderDrawerState> drawerKey;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var base = BaseWidget.of(context).dataStore;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: controller,
            size: 40,
          ),
          onPressed: toggle,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              var tasks = base.getUserTasks();
              tasks.isEmpty ? warningNoTask(context) : deleteAllTask(context);
            },
            child: const Icon(CupertinoIcons.trash, size: 40),
          ),
        ),
      ],
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TaskView(
              taskControllerForTitle: null,
              taskControllerForSubtitle: null,
              task: null,
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(child: Icon(Icons.add, color: Colors.white)),
        ),
      ),
    );
  }
}