enum UserRole {
  homeowner,
  worker;

  String get displayName => switch (this) {
        UserRole.homeowner => 'Homeowner',
        UserRole.worker => 'Skilled Worker',
      };
}
