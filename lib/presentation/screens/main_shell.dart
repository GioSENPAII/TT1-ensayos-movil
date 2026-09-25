import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'submission_history_screen.dart';

/// Árbol principal (sección 4.6.2): barra inferior con Inicio, Entregas y Perfil.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupBloc>(
      create: (_) => sl<GroupBloc>()..add(GroupsRequested()),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [HomeScreen(), SubmissionHistoryScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Entregas'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
