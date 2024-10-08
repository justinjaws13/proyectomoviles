package com.pucmm.chatapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;


import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.messaging.FirebaseMessaging;
import com.pucmm.chatapp.adapters.RecentConversationsAdapter;
import com.pucmm.chatapp.databinding.ActivityMainBinding;
import com.pucmm.chatapp.listeners.ConversionListener;
import com.pucmm.chatapp.models.ChatMessage;
import com.pucmm.chatapp.models.User;
import com.pucmm.chatapp.utilities.Constants;
import com.pucmm.chatapp.utilities.PreferenceManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends BaseActivity implements ConversionListener {

    private ActivityMainBinding binding;
    private PreferenceManager preferenceManager;
    private List<ChatMessage> conversations;
    private RecentConversationsAdapter conversationsAdapter;
    private FirebaseFirestore database;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        preferenceManager = new PreferenceManager(getApplicationContext());
        init();
        loadUserDetails();  // Cargar detalles del usuario
        getToken();         // Obtener token de Firebase
        setListeners();     // Definir listeners de botones
        listenConversations();
    }

    private void init(){
        conversations = new ArrayList<>();
        conversationsAdapter = new RecentConversationsAdapter(conversations, this);
        binding.conversationRecyclerView.setAdapter(conversationsAdapter);
        database = FirebaseFirestore.getInstance();
    }


    private void setListeners(){
        binding.imageSignOut.setOnClickListener(v -> signOut());  // Acciones de logout
        binding.fabNewChat.setOnClickListener(v ->
                startActivity(new Intent(getApplicationContext(), UsersActivity.class)));  // Ir a nueva actividad
    }


    /**
     * Carga el nombre de usuario y la imagen de perfil guardada en las preferencias
     */
    private void loadUserDetails(){
        binding.textUsername.setText(preferenceManager.getString(Constants.USERNAME));

//        // Manejo seguro de la imagen en caso de que no esté disponible
//        String encodedImage = preferenceManager.getString(Constants.KEY_IMAGE);
//
//        if (encodedImage != null && !encodedImage.isEmpty()) {
//            try {
//                byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
//                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
//                binding.imageProfile.setImageBitmap(bitmap);
//            } catch (IllegalArgumentException e) {
//                // Error al decodificar la imagen
//                showToast("Error al cargar la imagen de perfil.");
//                e.printStackTrace();
//            }
//        } else {
//            // En caso de que la imagen sea nula o vacía, cargar una imagen predeterminada
//            //binding.imageProfile.setImageResource(R.drawable.default_profile_image);
//        }
    }

    /**
     * Muestra un Toast con el mensaje proporcionado
     */
    private void showToast(String message){
        Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
    }

    private void listenConversations(){
        database.collection(Constants.COLLECTION_CONVERSATIONS)
                .whereEqualTo(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID))
                .addSnapshotListener(eventListener);
        database.collection(Constants.COLLECTION_CONVERSATIONS)
                .whereEqualTo(Constants.RECEIVER_ID, preferenceManager.getString(Constants.USER_ID))
                .addSnapshotListener(eventListener);
    }

    private final EventListener<QuerySnapshot> eventListener = (value, error) ->{
      if(error != null)
          return;
      if(value !=null){
          for (DocumentChange documentChange: value.getDocumentChanges()){
              if(documentChange.getType() == DocumentChange.Type.ADDED){
                  String senderId = documentChange.getDocument().getString(Constants.SENDER_ID);
                  String receiverId = documentChange.getDocument().getString(Constants.RECEIVER_ID);
                  ChatMessage chatMessage = new ChatMessage();
                  chatMessage.senderId = senderId;
                  chatMessage.receiverId = receiverId;
                  if(preferenceManager.getString(Constants.USER_ID).equals(senderId)){
//                      chatMessage.conversionImage = documentChange.getDocument().getString(Constants.KEY_RECEIVER_IMAGE);
                      chatMessage.conversionUsername = documentChange.getDocument().getString(Constants.RECEIVER_USERNAME);
                      chatMessage.conversionId = documentChange.getDocument().getString(Constants.RECEIVER_ID);

                  }else{
//                      chatMessage.conversionImage = documentChange.getDocument().getString(Constants.KEY_SENDER_IMAGE);
                      chatMessage.conversionUsername = documentChange.getDocument().getString(Constants.SENDER_USERNAME);
                      chatMessage.conversionId = documentChange.getDocument().getString(Constants.SENDER_ID);
                  }
                  chatMessage.message = documentChange.getDocument().getString(Constants.LAST_MESSAGE);
                  chatMessage.dateObject = documentChange.getDocument().getDate(Constants.TIMESTAMP);
                  conversations.add(chatMessage);
              } else if(documentChange.getType() == DocumentChange.Type.MODIFIED){
                  for(int i=0; i< conversations.size(); i++) {
                      String senderId = documentChange.getDocument().getString(Constants.SENDER_ID);
                      String receiverId = documentChange.getDocument().getString(Constants.RECEIVER_ID);
                      if (conversations.get(i).senderId.equals(senderId) && conversations.get(i).receiverId.equals(receiverId)) {
                          conversations.get(i).message = documentChange.getDocument().getString(Constants.LAST_MESSAGE);
                          conversations.get(i).dateObject = documentChange.getDocument().getDate(Constants.TIMESTAMP);
                          break;
                      }

                  }

              }
          }

          Collections.sort(conversations, (obj1, obj2) -> obj2.dateObject.compareTo(obj1.dateObject));
          conversationsAdapter.notifyDataSetChanged();
          binding.conversationRecyclerView.smoothScrollToPosition(0);
          binding.conversationRecyclerView.setVisibility(View.VISIBLE);
          binding.progressBar.setVisibility(View.GONE);

      }

    };

    /**
     * Obtiene el token de Firebase para mensajes push y lo actualiza en Firestore
     */
    private void getToken(){
        FirebaseMessaging.getInstance().getToken().addOnSuccessListener(this::updateToken);
    }

    /**
     * Actualiza el token FCM en Firestore
     */
    private void updateToken(String token){
        preferenceManager.putString(Constants.FCM_TOKEN, token);
        FirebaseFirestore database = FirebaseFirestore.getInstance();
        DocumentReference documentReference =
                database.collection(Constants.COLLECTION_USERS).document(
                        preferenceManager.getString(Constants.USER_ID)
                );
        documentReference.update(Constants.FCM_TOKEN, token)
                .addOnFailureListener(e -> showToast("Unable to update token"));
    }

    /**
     * Cierra sesión del usuario, elimina el token FCM y borra las preferencias
     */
    private void signOut(){
        showToast("Cerrando sesión...");
        FirebaseFirestore database = FirebaseFirestore.getInstance();
        DocumentReference documentReference =
                database.collection(Constants.COLLECTION_USERS).document(
                        preferenceManager.getString(Constants.USER_ID)
                );
        HashMap<String, Object> updates = new HashMap<>();
        updates.put(Constants.FCM_TOKEN, FieldValue.delete());
        documentReference.update(updates)
                .addOnSuccessListener(unused ->{
                    preferenceManager.clear();
                    startActivity(new Intent(getApplicationContext(), SignInActivity.class));
                    finish();
                })
                .addOnFailureListener(e -> showToast("Unable to sign out"));
    }

    @Override
    public void onConversionClicked(User user){
        Intent intent = new Intent(getApplicationContext(), ChatActivity.class);
        intent.putExtra(Constants.USER, user);
        startActivity(intent);
    }
}
