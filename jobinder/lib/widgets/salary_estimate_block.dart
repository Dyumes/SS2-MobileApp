import 'package:flutter/material.dart';
import '../models/employer_model.dart';
import '../models/job_opportunities_model.dart';
import '../services/salary_predictor.dart';

const int kHoursPerYear = 42 * 4 * 12;

class SalaryEstimateBlock extends StatefulWidget {
  final JobOpportunities job;
  final Employer employer;

  const SalaryEstimateBlock({
    super.key,
    required this.job,
    required this.employer,
  });

  @override
  State<SalaryEstimateBlock> createState() => _SalaryEstimateBlockState();
}

class _SalaryEstimateBlockState extends State<SalaryEstimateBlock> {
  double? _marketHourly;
  bool _loading = false;

  int get _workload => widget.job.workloadPercentage;

  double get _offerYearly =>
      widget.job.salary * kHoursPerYear * _workload / 100;

  double? get _marketYearly =>
      _marketHourly == null ? null : _marketHourly! * kHoursPerYear * _workload / 100;

  String get _yearLabel =>
      _workload == 100 ? 'CHF / year' : 'CHF / year at $_workload%';

  bool get _canEstimate =>
      widget.job.role.isNotEmpty &&
      widget.job.contract.isNotEmpty &&
      widget.job.industry.isNotEmpty &&
      widget.job.degree.isNotEmpty &&
      widget.employer.canton.isNotEmpty &&
      widget.employer.companySize.isNotEmpty;

  Future<void> _estimate() async {
    setState(() => _loading = true);
    try {
      final predictor = await SalaryPredictor.load();
      final fullTime = predictor.predictForJob(
        role: widget.job.role,
        contract: widget.job.contract,
        industry: widget.job.industry,
        canton: widget.employer.canton,
        companySize: widget.employer.companySize,
        degree: widget.job.degree,
        languages: widget.job.languages,
        holidays: widget.job.holidays,
      );
      if (!mounted) return;
      setState(() {
        _marketHourly = fullTime / kHoursPerYear;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Estimate failed: $e')));
    }
  }

  Widget _amount(BuildContext context, String hourly, String yearly,
      {Color? color}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hourly,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('CHF / hour', style: theme.textTheme.bodySmall),
            ),
          ],
        ),
        Text('$yearly $_yearLabel', style: theme.textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio =
        _marketHourly == null ? null : widget.job.salary / _marketHourly!;
    final above = ratio != null && ratio >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _amount(
              context,
              '${widget.job.salary}',
              '${_offerYearly.round()}',
            ),
            const Spacer(),
            if (_marketHourly == null)
              FilledButton.icon(
                onPressed: _canEstimate && !_loading ? _estimate : null,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_graph, size: 18),
                label: Text(_canEstimate ? 'Estimate' : 'Unavailable'),
              )
            else
              _amount(
                context,
                '${_marketHourly!.round()}',
                '${_marketYearly!.round()}',
                color: above ? Colors.green.shade700 : Colors.orange.shade800,
              ),
          ],
        ),
        if (ratio != null) ...[
          const SizedBox(height: 6),
          Text(
            above
                ? '${((ratio - 1) * 100).round()}% above the estimated market rate'
                : '${((1 - ratio) * 100).round()}% below the estimated market rate',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: above ? Colors.green.shade700 : Colors.orange.shade800,
            ),
          ),
        ],
      ],
    );
  }
}