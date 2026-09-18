import 'env_config.dart';

// 🌐 API Constants
class ApiConstants {
  // Base URL - Configurado en env_config.dart
  static String get baseUrl => EnvConfig.baseUrl;
  
  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String loginByDocument = '/auth/login-document';
  static const String verifyStaffTwoFactor = '/auth/login-document/verify-2fa';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  
  // Promotions
  static const String promotions = '/promotions';
  
  // Client endpoints
  static const String clientDashboard = '/client/dashboard';
  static const String clientProfile = '/client/profile';
  static const String clientProfilePhoto = '/client/profile/photo';
  static const String clientChangePassword = '/client/profile/change-password';
  
  // Attendances
  static const String clientAttendances = '/client/attendances';
  static const String clientAttendancesStats = '/client/attendances/stats';
  
  // Routines
  static const String clientRoutines = '/client/routines';
  static String clientRoutineDetail(int id) => '/client/routines/$id';
  
  // Progress
  static const String clientProgress = '/client/progress';
  static const String clientProgressPhotos = '/client/progress/photos';
  
  // Goals
  static const String clientGoals = '/client/goals';
  static String clientGoalDetail(int id) => '/client/goals/$id';
  static String clientGoalUpdateProgress(int id) => '/client/goals/$id/update-progress';
  static String acceptGoal(int id) => '/client/goals/$id/accept';
  static String rejectGoal(int id) => '/client/goals/$id/reject';
  
  // Memberships
  static const String membershipPlans = '/membership-plans';
  static const String clientRenewMembership = '/client/membership/renew';
  
  // Group Classes
  static const String groupClasses = '/group-classes';
  static String enrollGroupClass(int id) => '/group-classes/$id/enroll';
  
  // Notifications
  static const String notifications = '/client/notifications';
  static String markNotificationAsRead(int id) => '/client/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/client/notifications/read-all';
  static String deleteNotification(int id) => '/client/notifications/$id';
  
  // Referrals
  static const String clientReferrals = '/client/referrals';

  // Points history
  static const String clientPointTransactions = '/client/point-transactions';

  // Workout logs
  static const String workoutLogsToday = '/client/workout-logs/today';
  static const String workoutLogs = '/client/workout-logs';
  static String deleteWorkoutLog(int id) => '/client/workout-logs/$id';

  // Chat
  static const String chatTrainers = '/client/chat/trainers';
  static const String chatMessages = '/client/chat/messages';

  // Nutrition
  static const String nutritionPlans = '/client/nutrition-plans';
  static String nutritionPlanDetail(int id) => '/client/nutrition-plans/$id';

  // Store
  static const String storeProducts = '/store/products';
  static String redeemProduct(int id) => '/store/products/$id/redeem';
  static String buyProduct(int id) => '/store/products/$id/buy';
  static const String myRedemptions = '/client/redemptions';

  // Gym configuration (logo, name, colors, tour video)
  static const String gymConfig = '/gym/config';

  // Exercises
  static const String exercises = '/exercises';
  static String exerciseDetail(int id) => '/exercises/$id';

  // Surveys
  static const String surveys = '/client/surveys';
  static String surveyDetail(int id) => '/client/surveys/$id';
  static String surveyRespond(int id) => '/client/surveys/$id/respond';

  // Admin endpoints
  static const String adminStats              = '/admin/stats';
  static const String adminTodayAttendance    = '/admin/today-attendance';
  static const String adminExpiringMemberships= '/admin/expiring-memberships';
  static const String adminClientsSearch      = '/admin/clients/search';
  static const String adminPushNotification   = '/admin/push-notification';
  static const String adminTrainers           = '/admin/trainers';
  static String adminClientDetail(int id) => '/admin/clients/$id';
  static String adminAssignTrainer(int id) => '/admin/clients/$id/assign-trainer';

  // Trainer endpoints
  static const String trainerDashboard = '/trainer/dashboard';
  static const String trainerClients   = '/trainer/clients';
  static String trainerClientDetail(int id) => '/trainer/clients/$id';

  // Trainer - sub-recursos del cliente
  static String trainerClientEvaluations(int clientId) => '/trainer/clients/$clientId/evaluations';
  static String trainerClientEvaluationDetail(int clientId, int evalId) => '/trainer/clients/$clientId/evaluations/$evalId';
  static String trainerClientGoals(int clientId) => '/trainer/clients/$clientId/goals';
  static String trainerUpdateGoalProgress(int clientId, int goalId) => '/trainer/clients/$clientId/goals/$goalId/progress';
  static String trainerClientProgress(int clientId) => '/trainer/clients/$clientId/progress';
  static String trainerClientRoutines(int clientId) => '/trainer/clients/$clientId/routines';
  static String trainerToggleRoutine(int clientId, int routineId) => '/trainer/clients/$clientId/routines/$routineId/toggle';
  static String trainerAddRoutineDay(int clientId, int routineId) => '/trainer/clients/$clientId/routines/$routineId/days';
  static String trainerRemoveRoutineDay(int clientId, int routineId, int dayId) => '/trainer/clients/$clientId/routines/$routineId/days/$dayId';

  // Trainer - Chat con clientes
  static const String trainerChatClients  = '/trainer/chat/clients';
  static const String trainerChatMessages = '/trainer/chat/messages';

  // Trainer - Nutrición
  static String trainerClientNutrition(int clientId) => '/trainer/clients/$clientId/nutrition';
  static const String trainerNutrition = '/trainer/nutrition';
  static String trainerNutritionDetail(int planId)  => '/trainer/nutrition/$planId';
  static String trainerNutritionMeals(int planId)   => '/trainer/nutrition/$planId/meals';
  static String trainerNutritionMeal(int planId, int mealId) => '/trainer/nutrition/$planId/meals/$mealId';
  static String trainerNutritionFoods(int planId, int mealId) => '/trainer/nutrition/$planId/meals/$mealId/foods';
  static String trainerNutritionFood(int planId, int mealId, int foodId) => '/trainer/nutrition/$planId/meals/$mealId/foods/$foodId';
}
