class NutritionPlanModel {
  final int id;
  final String name;
  final String? description;
  final String goal;
  final int? targetCalories;
  final String? trainerName;
  final List<NutritionMealModel> meals;

  NutritionPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.goal,
    this.targetCalories,
    this.trainerName,
    required this.meals,
  });

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) {
    return NutritionPlanModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      goal: json['goal'] ?? 'maintain',
      targetCalories: json['target_calories'],
      trainerName: json['trainer_name'],
      meals: (json['meals'] as List?)
              ?.map((m) => NutritionMealModel.fromJson(m))
              .toList() ??
          [],
    );
  }

  String get goalLabel {
    switch (goal) {
      case 'lose_weight':  return 'Bajar de peso';
      case 'gain_muscle':  return 'Ganar músculo';
      case 'maintain':     return 'Mantener peso';
      default:             return 'Otro';
    }
  }

  int get totalCalories =>
      meals.fold(0, (sum, m) => sum + (m.totalCalories ?? 0));
}

class NutritionMealModel {
  final int id;
  final String mealType;
  final String name;
  final String? description;
  final int? totalCalories;
  final List<MealFoodModel> foods;

  NutritionMealModel({
    required this.id,
    required this.mealType,
    required this.name,
    this.description,
    this.totalCalories,
    required this.foods,
  });

  factory NutritionMealModel.fromJson(Map<String, dynamic> json) {
    return NutritionMealModel(
      id: json['id'],
      mealType: json['meal_type'] ?? 'lunch',
      name: json['name'] ?? '',
      description: json['description'],
      totalCalories: json['total_calories'],
      foods: (json['foods'] as List?)
              ?.map((f) => MealFoodModel.fromJson(f))
              .toList() ??
          [],
    );
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':       return 'Desayuno';
      case 'morning_snack':   return 'Snack mañana';
      case 'lunch':           return 'Almuerzo';
      case 'afternoon_snack': return 'Snack tarde';
      case 'dinner':          return 'Cena';
      default:                return name;
    }
  }
}

class MealFoodModel {
  final int id;
  final String foodName;
  final double amount;
  final String unit;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatsG;

  MealFoodModel({
    required this.id,
    required this.foodName,
    required this.amount,
    required this.unit,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatsG,
  });

  factory MealFoodModel.fromJson(Map<String, dynamic> json) {
    return MealFoodModel(
      id: json['id'],
      foodName: json['food_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: json['calories'],
      proteinG: json['protein_g']?.toDouble(),
      carbsG: json['carbs_g']?.toDouble(),
      fatsG: json['fats_g']?.toDouble(),
    );
  }
}
