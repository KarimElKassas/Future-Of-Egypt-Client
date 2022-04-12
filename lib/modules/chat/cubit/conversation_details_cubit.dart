import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/chat_model.dart';
import 'conversation_details_state.dart';


class ConversationDetailsCubit extends Cubit<ConversationDetailsState>{
  ConversationDetailsCubit() : super(DetailsIntialState());
  static ConversationDetailsCubit get(context)=>BlocProvider.of(context);
List<ChatModel> images = [];
List<ChatModel> audio = [];
List<ChatModel> files = [];
void sortMessages (List<ChatModel> messages){
 messages.forEach((element) {
   if(element.type == 'Image'){
     images.add(element);
   }else if (element.type=='Audio'){
     audio.add(element);
   }else if (element.type == 'file'){
     files.add(element);
   }
 }) ;
 emit(MediaIntialState());
}
}