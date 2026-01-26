class ApiEndpoints {
  // Authentication Endpoints
  static final String loginEndpoint = '/api/method/aos.api.auth.login';
  static final String registerEndpoint = '/api/method/aos.api.auth.register';
  static final String verifyOtpEndpoint =
      '/api/method/aos.api.auth.verify_email_otp';
  static final String resendOtpEndpoint =
      '/api/method/aos.api.auth.resend_email_otp';
  static final String forgotPasswordRequestEndpoint =
      '/api/method/aos.api.auth.forgot_password_request';
  static final String forgotPasswordVerifyOtpEndpoint =
      '/api/method/aos.api.auth.forgot_password_verify_otp';
  static final String forgotPasswordResetEndpoint =
      '/api/method/aos.api.auth.forgot_password_reset';
  static final String meEndpoint = '/api/method/aos.api.auth.me';
  static final String logoutEndpoint = '/api/method/aos.api.auth.logout';
  static final String changePasswordEndpoint =
      '/api/method/aos.api.auth.change_password';
  static final String googleLoginEndpoint =
      '/api/method/aos.api.auth.google_login';

  // Accounts Endpoints
  static final String getProfileEndpoint =
      '/api/method/aos.api.accounts.get_profile';
  static final String updateProfileEndpoint =
      '/api/method/aos.api.accounts.update_profile';
  static final String uploadFileEndpoint = '/api/method/upload_file';

  // Catalog Endpoints
  static final String getCategoriesEndpoint =
      '/api/method/aos.api.catalog.get_categories';
}
