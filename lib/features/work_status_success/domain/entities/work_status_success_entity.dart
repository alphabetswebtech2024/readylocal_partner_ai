class WorkStatusSuccessEntity {
  final String partnerName;
  final String title;
  final String subtitle;

  const WorkStatusSuccessEntity({
    required this.partnerName,
    this.title = 'Thank you',
    this.subtitle = 'We have received your work Status',
  });
}
