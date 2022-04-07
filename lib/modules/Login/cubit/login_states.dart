abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginChangePassVisibility extends LoginStates {}

class LoginNoInternetState extends LoginStates {}

class LoginLoadingSignIn extends LoginStates {}

class LoginUpdateLogSuccess extends LoginStates {}

class LoginUpdateLogError extends LoginStates {

  final String error;

  LoginUpdateLogError(this.error);

}

class LoginSuccessState extends LoginStates {

  final String sectionName;

  LoginSuccessState(this.sectionName);

}

class LoginGetClientDataSuccessState extends LoginStates {}

class LoginNoUserState extends LoginStates {}

class LoginSharedPrefErrorState extends LoginStates {
  final String error;

  LoginSharedPrefErrorState(this.error);
}

class LoginGetClientDataErrorState extends LoginStates {
  final String error;

  LoginGetClientDataErrorState(this.error);
}

class LoginErrorState extends LoginStates {
  final String error;

  LoginErrorState(this.error);
}
