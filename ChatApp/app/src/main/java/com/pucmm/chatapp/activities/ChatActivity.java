package com.pucmm.chatapp.activities;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Base64;
import android.view.View;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.tasks.OnCompleteListener;
//import com.google.auth.oauth2.AccessToken;
//import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;
import com.pucmm.chatapp.adapters.ChatAdapter;
import com.pucmm.chatapp.databinding.ActivityChatBinding;
import com.pucmm.chatapp.models.ChatMessage;
import com.pucmm.chatapp.models.TokenGenerator;
import com.pucmm.chatapp.models.User;
import com.pucmm.chatapp.network.ApiClient;
import com.pucmm.chatapp.network.ApiService;
import com.pucmm.chatapp.utilities.Constants;
import com.pucmm.chatapp.utilities.PreferenceManager;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ChatActivity extends BaseActivity {

    private ActivityChatBinding binding;
    private User receiverUser;
    private List<ChatMessage> chatMessages;
    private ChatAdapter chatAdapter;
    private PreferenceManager preferenceManager;
    private FirebaseFirestore database;
    private String conversationId = null;
    private Boolean isReceiverAvailable = false;
    private String encodedImage;


    // Ruta del archivo de la cuenta de servicio de Firebase
    private static final String SERVICE_ACCOUNT_FILE = "C:\\Users\\Coshita\\AndroidStudioProjects\\proyectomoviles\\ChatApp\\app\\chatapp1-5f3e5-925a2f3843db.json"; // Cambia esta ruta
    private static final String FCM_API_URL = "https://fcm.googleapis.com/v1/projects/860878442387/messages:send";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityChatBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        requestNotificationPermission();
        setListeners();
        loadReceiverDetails();
        init();
        listenMessages();
    }

    private void init(){
        preferenceManager = new PreferenceManager(getApplicationContext());
        chatMessages = new ArrayList<>();
        chatAdapter = new ChatAdapter(
                chatMessages,
//                getBitmapFromEncodedString(receiverUser.image),
                preferenceManager.getString(Constants.USER_ID)
        );
        binding.chatRecyclerView.setAdapter(chatAdapter);
        database = FirebaseFirestore.getInstance();
    }

    private void sendImageMessage(Bitmap bitmap){
        encodedImage = encodeImage(bitmap);
        HashMap<String, Object> messageImage = new HashMap<>();
        messageImage.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
        messageImage.put(Constants.RECEIVER_ID, receiverUser.id);
        messageImage.put(Constants.IMAGE, encodedImage);
        messageImage.put(Constants.TIMESTAMP, new Date());
        database.collection(Constants.COLLECTION_CHAT).add(messageImage);

        if (conversationId != null){
            updateConversion("Imagen");
        }
        else {
          HashMap<String, Object> conversion = new HashMap<>();
          conversion.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
          conversion.put(Constants.SENDER_USERNAME, preferenceManager.getString(Constants.USER_ID));
          conversion.put(Constants.RECEIVER_ID, receiverUser.id);
          conversion.put(Constants.RECEIVER_USERNAME, receiverUser.username);
          conversion.put(Constants.LAST_MESSAGE, "Imagen");
          conversion.put(Constants.TIMESTAMP, new Date());
          addConversion(conversion);

        }
        // Notificación push si el receptor no está disponible
        if (!isReceiverAvailable) {
            try {
                JSONArray tokens = new JSONArray();
                tokens.put(receiverUser.token);

                JSONObject data = new JSONObject();
                data.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
                data.put(Constants.USERNAME, preferenceManager.getString(Constants.USERNAME));
                data.put(Constants.FCM_TOKEN, preferenceManager.getString(Constants.FCM_TOKEN));
                data.put(Constants.MESSAGE, "Imagen");  // Notificación con texto que indica imagen

                JSONObject body = new JSONObject();
                body.put(Constants.REMOTE_MSG_DATA, data);
                body.put(Constants.REMOTE_MSG_REGISTRATION_IDS, tokens);

                sendNotification(body.toString());

            } catch (Exception e) {
                showToast(e.getMessage());
            }
        }

        // Limpiar vista
        binding.inputMessage.setText(null);

    }

    private void sendMessage(){
        HashMap<String, Object> message = new HashMap<>();
        message.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
        message.put(Constants.RECEIVER_ID, receiverUser.id);
        message.put(Constants.MESSAGE, binding.inputMessage.getText().toString());
        message.put(Constants.TIMESTAMP, new Date());
        database.collection(Constants.COLLECTION_CHAT).add(message);
        if(conversationId != null){
            updateConversion(binding.inputMessage.getText().toString());
        }else{
            HashMap<String, Object> conversion = new HashMap<>();
            conversion.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
            conversion.put(Constants.SENDER_USERNAME, preferenceManager.getString(Constants.USERNAME));
//            conversion.put(Constants.KEY_SENDER_IMAGE, preferenceManager.getString(Constants.KEY_IMAGE));

            conversion.put(Constants.RECEIVER_ID, receiverUser.id);
            conversion.put(Constants.RECEIVER_USERNAME, receiverUser.username);
//            conversion.put(Constants.KEY_RECEIVER_IMAGE, receiverUser.image);

            conversion.put(Constants.LAST_MESSAGE, binding.inputMessage.getText().toString());
            conversion.put(Constants.TIMESTAMP, new Date());
            addConversion(conversion);
        }
        if(!isReceiverAvailable){
            try {
                JSONArray tokens = new JSONArray();
                tokens.put(receiverUser.token);

                JSONObject data = new JSONObject();
                data.put(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID));
                data.put(Constants.USERNAME, preferenceManager.getString(Constants.USERNAME));
                data.put(Constants.FCM_TOKEN, preferenceManager.getString(Constants.FCM_TOKEN));
                data.put(Constants.MESSAGE, binding.inputMessage.getText().toString());

                JSONObject body = new JSONObject();
                body.put(Constants.REMOTE_MSG_DATA, data);
                body.put(Constants.REMOTE_MSG_REGISTRATION_IDS, tokens);

                sendNotification(body.toString());

            }catch (Exception e){
                showToast(e.getMessage());
            }
        }

        binding.inputMessage.setText(null);
    }

    private void showToast(String message){
        Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
    }


    private void requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.POST_NOTIFICATIONS}, 1);
            }
        }
    }

//    private String getAccessToken() throws Exception {
//        GoogleCredentials credentials = GoogleCredentials
//                .fromStream(new FileInputStream(SERVICE_ACCOUNT_FILE))
//                .createScoped(Collections.singleton("https://www.googleapis.com/auth/cloud-platform"));
//        credentials.refreshIfExpired();
//        AccessToken token = credentials.getAccessToken();
//        return token.getTokenValue();
//    }

    private void sendNotification(String messageBody) {
        try {
            TokenGenerator tokenGenerator = new TokenGenerator();
            String jwt = tokenGenerator.createJWT();
            System.out.println("JWT generado: " + jwt);

            // Obtener el access token en segundo plano
            tokenGenerator.getAccessTokenAsync(jwt, new TokenGenerator.Callback<String>() {
                @Override
                public void onSuccess(String accessToken) {
                    System.out.println("Access Token: " + accessToken);

                    HashMap<String, String> headers = new HashMap<>();
                    headers.put("Authorization", "Bearer " + accessToken);
                    headers.put("Content-Type", "application/json; UTF-8");

                    ApiClient.getClient().create(ApiService.class).sendMessage(headers, messageBody)
                            .enqueue(new Callback<String>() {
                                @Override
                                public void onResponse(Call<String> call, Response<String> response) {
                                    // Manejo de la respuesta
                                }

                                @Override
                                public void onFailure(Call<String> call, Throwable t) {
                                    showToast(t.getMessage());
                                }
                            });
                }

                @Override
                public void onError(Exception e) {
                    showToast("Error obteniendo el token: " + e.getMessage());
                }
            });

        } catch (Exception e) {
            showToast("Error: " + e.getMessage());
        }
    }





    private void listenAvailabilityOfReceiver(){
        database.collection(Constants.COLLECTION_USERS).document(
                receiverUser.id
        ).addSnapshotListener(ChatActivity.this, (value, error) ->{
            if(error != null){
                return;
            }
            if(value != null){
                if(value.getLong(Constants.AVAILABILITY) != null){
                    int availability = Objects.requireNonNull(
                            value.getLong(Constants.AVAILABILITY)
                    ).intValue();
                    isReceiverAvailable = availability == 1;
                }
                receiverUser.token = value.getString(Constants.FCM_TOKEN);
//                if(receiverUser.image == null){
//                    receiverUser.image = value.getString(Constants.KEY_IMAGE);
//                    chatAdapter.setRecieverProfileImage(getBitmapFromEncodedString(receiverUser.image));
//                    chatAdapter.notifyItemRangeChanged(0, chatMessages.size());
//                }

            }
            if(isReceiverAvailable){
                binding.textAvailability.setVisibility(View.VISIBLE);
            }else{
                binding.textAvailability.setVisibility(View.GONE);
            }
        });
    }


    private void listenMessages(){
        database.collection(Constants.COLLECTION_CHAT)
                .whereEqualTo(Constants.SENDER_ID, preferenceManager.getString(Constants.USER_ID))
                .whereEqualTo(Constants.RECEIVER_ID, receiverUser.id)
                .addSnapshotListener(eventListener);
        database.collection(Constants.COLLECTION_CHAT)
                .whereEqualTo(Constants.SENDER_ID, receiverUser.id)
                .whereEqualTo(Constants.RECEIVER_ID, preferenceManager.getString(Constants.USER_ID))
                .addSnapshotListener(eventListener);
    }

    private final EventListener<QuerySnapshot> eventListener = (value, error) -> {
        if(error != null)
        {
            return;
        }
        if(value != null){
            int count = chatMessages.size();
            for (DocumentChange documentChange : value.getDocumentChanges()){
                if(documentChange.getType() == DocumentChange.Type.ADDED){
                    ChatMessage chatMessage = new ChatMessage();
                    chatMessage.senderId = documentChange.getDocument().getString(Constants.SENDER_ID);
                    chatMessage.receiverId = documentChange.getDocument().getString(Constants.RECEIVER_ID);
                    chatMessage.message = documentChange.getDocument().getString(Constants.MESSAGE);
                    chatMessage.image = documentChange.getDocument().getString(Constants.IMAGE);
                    chatMessage.dateTime = getReadableDateTime(documentChange.getDocument().getDate(Constants.TIMESTAMP));
                    chatMessage.dateObject = documentChange.getDocument().getDate(Constants.TIMESTAMP);
                    chatMessages.add(chatMessage);
                }

            }

            Collections.sort(chatMessages, (obj1, obj2) -> obj1.dateObject.compareTo(obj2.dateObject));
            if (count == 0){
                chatAdapter.notifyDataSetChanged();
            } else {
                chatAdapter.notifyItemRangeInserted(chatMessages.size(), chatMessages.size());
                binding.chatRecyclerView.smoothScrollToPosition(chatMessages.size() - 1);
            }
            binding.chatRecyclerView.setVisibility(View.VISIBLE);
        }

        binding.progressBar.setVisibility(View.GONE);
        if(conversationId == null){
            checkForConversation();
        }
    };

    private Bitmap getBitmapFromEncodedString(String encodedImage){
        if(encodedImage != null){
            byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        } else{
            return null;
        }

    }

    private void loadReceiverDetails(){
        receiverUser = (User) getIntent().getSerializableExtra(Constants.USER);
        assert receiverUser != null;
        binding.textUsername.setText(receiverUser.username);
    }

    private void setListeners(){
        binding.imageBack.setOnClickListener(v -> onBackPressed());
        binding.layoutSend.setOnClickListener(v -> sendMessage());
        binding.layoutSendImage.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            pickImage.launch(intent);

        });

    }


    private String getReadableDateTime(Date date){
        return new SimpleDateFormat("MMMM dd, yyyy - hh:mm a", Locale.getDefault()).format(date);
    }

    private void addConversion(HashMap<String, Object> conversion){
        database.collection(Constants.COLLECTION_CONVERSATIONS)
                .add(conversion)
                .addOnSuccessListener(documentReference -> conversationId = documentReference.getId());
    }

    private void updateConversion(String message){
        DocumentReference documentReference =
                database.collection(Constants.COLLECTION_CONVERSATIONS).document(conversationId);
        documentReference.update(Constants.LAST_MESSAGE, message, Constants.TIMESTAMP, new Date());
    }


    private void checkForConversation(){
        if(!chatMessages.isEmpty()){
            checkForConversationRemotely(
                    preferenceManager.getString(Constants.USER_ID),
                    receiverUser.id);
        } else {
            checkForConversationRemotely(
                    receiverUser.id,
                    preferenceManager.getString(Constants.USER_ID)
            );
        }
    }

    private void checkForConversationRemotely(String senderId, String receiverId){
        database.collection(Constants.COLLECTION_CONVERSATIONS)
                .whereEqualTo(Constants.SENDER_ID, senderId)
                .whereEqualTo(Constants.RECEIVER_ID, receiverId)
                .get()
                .addOnCompleteListener(conversationOnCompleteListener);
    }

    private final OnCompleteListener<QuerySnapshot> conversationOnCompleteListener = task -> {
        if(task.isSuccessful() && task.getResult() != null && task.getResult().getDocuments().size() > 0){
            DocumentSnapshot documentSnapshot = task.getResult().getDocuments().get(0);
            conversationId = documentSnapshot.getId();
        }
    };

    @Override
    protected void onResume() {
        super.onResume();
        listenAvailabilityOfReceiver();
    }


        private String encodeImage(Bitmap bitmap){
        int previewWidth = 150;
        int previewHeight = bitmap.getHeight() * previewWidth / bitmap.getWidth();
        Bitmap previewBitmap = Bitmap.createScaledBitmap(bitmap, previewWidth, previewHeight, false);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        previewBitmap.compress(Bitmap.CompressFormat.JPEG, 50, byteArrayOutputStream);
        byte[] bytes = byteArrayOutputStream.toByteArray();
        return Base64.encodeToString(bytes, Base64.DEFAULT);
    }

    private final ActivityResultLauncher<Intent> pickImage = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
                if(result.getResultCode() == RESULT_OK){
                    if(result.getData() != null){
                        Uri imageUri = result.getData().getData();
                        try {
                            InputStream inputStream = getContentResolver().openInputStream(imageUri);
                            Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                            sendImageMessage(bitmap);
                        }catch (FileNotFoundException e){
                            e.printStackTrace();
                        }
                    }
                }
            }
    );


}