import 'conjugation_result.dart';

class ConjugationArguments {
  final ConjugationResult conjugationResult;
  final String currentTargetValueLang;
  final String currentSourceValueLang;

  ConjugationArguments(this.conjugationResult, this.currentTargetValueLang,
      this.currentSourceValueLang);
}