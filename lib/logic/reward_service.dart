class RewardGrant {
  const RewardGrant({this.coins = 100, this.hintPoints = 1});

  final int coins;
  final int hintPoints;
}

class RewardService {
  const RewardService();

  static const coinsPerStage = 100;
  static const hintsPerStage = 1;

  RewardGrant grantIfNeeded({required bool alreadyGranted}) {
    if (alreadyGranted) return const RewardGrant(coins: 0, hintPoints: 0);
    return const RewardGrant(
      coins: coinsPerStage,
      hintPoints: hintsPerStage,
    );
  }
}
