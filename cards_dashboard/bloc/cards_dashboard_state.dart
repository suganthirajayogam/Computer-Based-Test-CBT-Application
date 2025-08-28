// lib/bloc/cards_dashboard/cards_dashboard_state.dart

import 'package:computer_based_test/models/quiz_dashhboard_models.dart';


abstract class CardsDashboardState {}

class CardsInitial extends CardsDashboardState {}

class CardsLoaded extends CardsDashboardState {
  final List<QuizModel> cards;
  CardsLoaded(this.cards);
}
