import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

/// Predicts a full-time-equivalent yearly salary in CHF.
///
/// The model is a linear regression trained on log(salary), so the prediction
/// is exp(intercept + sum of coefficients). Coefficients live in
/// assets/salary_model.json, exported from model.ipynb.
class SalaryPredictor {
  SalaryPredictor._(this._intercept, this._numeric, this._categorical);

  final double _intercept;
  final Map<String, _NumericFeature> _numeric;
  final Map<String, Map<String, double>> _categorical;

  static SalaryPredictor? _instance;

  static Future<SalaryPredictor> load() async {
    if (_instance != null) return _instance!;

    final raw = await rootBundle.loadString('salary_model.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final numeric = <String, _NumericFeature>{};
    (json['numeric'] as Map<String, dynamic>).forEach((name, spec) {
      numeric[name] = _NumericFeature(
        mean: (spec['mean'] as num).toDouble(),
        std: (spec['std'] as num).toDouble(),
        coef: (spec['coef'] as num).toDouble(),
      );
    });

    final categorical = <String, Map<String, double>>{};
    (json['categorical'] as Map<String, dynamic>).forEach((name, spec) {
      categorical[name] = {
        for (final entry in (spec as Map<String, dynamic>).entries)
          if (entry.key != '__reference__')
            entry.key: (entry.value as num).toDouble(),
      };
    });

    _instance = SalaryPredictor._(
      (json['intercept'] as num).toDouble(),
      numeric,
      categorical,
    );
    return _instance!;
  }

  /// [numericValues] keys: Holidays, Lang_French, Lang_German, Lang_English,
  /// Lang_Italian, LangCount, DiplomaLevel, CompanySizeLevel.
  /// [categoricalValues] keys: Role, Contract, Industry, Canton.
  ///
  /// Unknown categories contribute nothing, which is the same behaviour as
  /// handle_unknown="ignore" in the Python pipeline.
  double predict({
    required Map<String, double> numericValues,
    required Map<String, String> categoricalValues,
    int workloadPercent = 100,
  }) {
    var z = _intercept;

    for (final entry in _numeric.entries) {
      final value = numericValues[entry.key];
      if (value == null) {
        throw ArgumentError('Missing numeric feature: ${entry.key}');
      }
      final f = entry.value;
      z += (value - f.mean) / f.std * f.coef;
    }

    for (final entry in _categorical.entries) {
      final value = categoricalValues[entry.key];
      if (value == null) {
        throw ArgumentError('Missing categorical feature: ${entry.key}');
      }
      z += entry.value[value] ?? 0.0;
    }

    // The model was trained on salaries normalised to 100% workload.
    return math.exp(z) * workloadPercent / 100;
  }

  /// Convenience helper mapping the app's own vocabulary onto the model's.
  double predictForJob({
    required String role,
    required String contract,
    required String industry,
    required String canton,
    required String degree,
    required String companySize,
    required List<String> languages,
    int holidays = 25,
    int workloadPercent = 100,
  }) {
    const degreeLevels = {
      'None': 0.0,
      'Apprenticeship': 1.0,
      'Bachelor': 2.0,
      'Master': 3.0,
      'PhD': 4.0,
    };
    const companySizeLevels = {
      'Startup (<50)': 0.0,
      'Small (50-200)': 1.0,
      'Medium (200-1000)': 2.0,
      'Large (1000+)': 3.0,
    };

    double has(String lang) => languages.contains(lang) ? 1.0 : 0.0;

    const knownCantons = {
      'AG', 'BE', 'BL', 'BS', 'FR', 'GE', 'LU',
      'SG', 'SO', 'TG', 'TI', 'VD', 'VS', 'ZH',
    };

    return predict(
      numericValues: {
        'Holidays': holidays.toDouble(),
        'Lang_French': has('French'),
        'Lang_German': has('German'),
        'Lang_English': has('English'),
        'Lang_Italian': has('Italian'),
        'LangCount': has('French') + has('German') + has('English') + has('Italian'),
        'DiplomaLevel': degreeLevels[degree] ?? 2.0,
        'CompanySizeLevel': companySizeLevels[companySize] ?? 1.0,
      },
      categoricalValues: {
        'Role': role,
        'Contract': contract,
        'Industry': industry,
        'Canton': knownCantons.contains(canton) ? canton : 'Other',
      },
      workloadPercent: workloadPercent,
    );
  }
}

class _NumericFeature {
  const _NumericFeature({
    required this.mean,
    required this.std,
    required this.coef,
  });

  final double mean;
  final double std;
  final double coef;
}