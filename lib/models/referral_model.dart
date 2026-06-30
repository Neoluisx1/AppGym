class ReferralModel {
  final String referralCode;
  final int pointsPerReferral;
  final ReferralStats stats;
  final List<ReferredClient> referredClients;

  ReferralModel({
    required this.referralCode,
    required this.pointsPerReferral,
    required this.stats,
    required this.referredClients,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: json['referral_code'] ?? '',
      pointsPerReferral: json['points_per_referral'] ?? 100,
      stats: ReferralStats.fromJson(json['stats'] ?? {}),
      referredClients: (json['referred_clients'] as List? ?? [])
          .map((e) => ReferredClient.fromJson(e))
          .toList(),
    );
  }
}

class ReferralStats {
  final int totalReferrals;
  final int activeReferrals;
  final int pointsEarned;

  ReferralStats({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.pointsEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferrals: json['total_referrals'] ?? 0,
      activeReferrals: json['active_referrals'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
    );
  }
}

class ReferredClient {
  final int id;
  final String name;
  final String joinedAt;
  final bool isActive;

  ReferredClient({
    required this.id,
    required this.name,
    required this.joinedAt,
    required this.isActive,
  });

  factory ReferredClient.fromJson(Map<String, dynamic> json) {
    return ReferredClient(
      id: json['id'],
      name: json['name'] ?? 'Usuario',
      joinedAt: json['joined_at'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}
