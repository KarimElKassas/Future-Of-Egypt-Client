import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/components.dart';
import '../../../shared/constants.dart';
import 'customer_questions_states.dart';


class CustomerQuestionsCubit extends Cubit<CustomerQuestionsStates> {
  CustomerQuestionsCubit() : super(CustomerQuestionsInitialState());

  static CustomerQuestionsCubit get(context) => BlocProvider.of(context);

}
