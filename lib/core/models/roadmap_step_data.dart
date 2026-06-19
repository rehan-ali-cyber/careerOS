class RoadmapStepData {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  RoadmapStepData({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
  });
}
