class Mission {
  final String id;
  final String title;
  final String rewardType;
  final num points;
  final String url;
  final String task;
  final bool isCompleted;
  final num voucherAmount;

  Mission({
    this.id,
    this.title,
    this.rewardType,
    this.points,
    this.url,
    this.task,
    this.isCompleted,
    this.voucherAmount,
  });

  Mission.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'] ?? '',
        rewardType = data['rewardType'] ?? '',
        points = data['points'] ?? 0,
        url = data['url'] ?? '',
        task = data['task'] ?? '',
        isCompleted = data['isCompleted'] ?? false,
        voucherAmount = data['voucherAmount'] ?? 0;
}
