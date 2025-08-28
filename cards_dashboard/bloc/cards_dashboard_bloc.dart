// lib/bloc/cards_dashboard/cards_dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:computer_based_test/models/quiz_dashhboard_models.dart';
import 'cards_dashboard_event.dart';
import 'cards_dashboard_state.dart';
import 'package:computer_based_test/models/quiz_dashboard_models.dart';

class CardsDashboardBloc
    extends Bloc<CardsDashboardEvent, CardsDashboardState> {
  CardsDashboardBloc() : super(CardsInitial()) {
    on<LoadCardsEvent>((event, emit) {
      emit(CardsLoaded([
        QuizModel(
          title: "Safety Quiz",
          subtitle: "Test your knowledge of safety protocols",
          imagePath: "assets/images/safety.jpeg",
        ),
        QuizModel(
          title: "ESD Quiz",
          subtitle: "Understand Electrostatic Discharge",
          imagePath: "assets/images/esd.jpg",
        ),
        QuizModel(
          title: "SMT Quiz",
          subtitle: "Surface Mount Technology basics",
          imagePath: "assets/images/smt.png",
        ),
        QuizModel(
          title: "FA Quiz",
          subtitle: "Failure Analysis understanding",
          imagePath: "assets/images/fa.png",
        ),
      ]));
    });
  }
}
