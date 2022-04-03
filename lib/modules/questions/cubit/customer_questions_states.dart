abstract class CustomerQuestionsStates{}

class CustomerQuestionsInitialState extends CustomerQuestionsStates{}

class CustomerQuestionsLogOutSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsStartRecordSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsInitializeRecordSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsDisposeRecordSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsPermissionDeniedState extends CustomerQuestionsStates{}

class CustomerQuestionsStopRecordSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsToggleRecordSuccessState extends CustomerQuestionsStates{}

class CustomerQuestionsChangeSpeedState extends CustomerQuestionsStates{}

class CustomerQuestionsEndSpeedState extends CustomerQuestionsStates{}

class CustomerQuestionsLogOutErrorState extends CustomerQuestionsStates{

  final String error;

  CustomerQuestionsLogOutErrorState(this.error);

}
class CustomerQuestionsEndSpeedErrorState extends CustomerQuestionsStates{

  final String error;

  CustomerQuestionsEndSpeedErrorState(this.error);

}

