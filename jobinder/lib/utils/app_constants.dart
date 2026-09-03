class AppConstants {
  AppConstants._();

  static const List<String> roles = [
    'Intern', 'Junior', 'Mid-level', 'Senior', 'Lead', 'Manager', 'Director',
  ];

  static const List<String> contracts = [
    '6 months', '1 year', '2 years', 'Permanent',
  ];

  static const List<String> companySizes = [
    'Startup (<50)', 'Small (50-200)', 'Medium (200-1000)', 'Large (1000+)',
  ];

  // le modèle connaît aussi None et Apprenticeship
  static const List<String> degrees = [
    'All', 'Apprenticeship', 'Bachelor', 'Master', 'PhD',
  ];

  static const List<String> cantons = [
    'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR',
    'JU', 'LU', 'NE', 'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG',
    'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH',
  ];

  static const List<String> industries = [
    'All', 'Education', 'Manufacturing', 'Healthcare', 'Finance', 'IT',
    'Energy', 'Hospitality', 'Public Sector', 'Consulting',
    'Pharma', 'Construction', 'Retail'
  ];
}