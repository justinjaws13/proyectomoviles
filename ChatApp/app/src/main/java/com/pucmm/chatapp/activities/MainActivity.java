package com.pucmm.chatapp.activities;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Base64;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.messaging.FirebaseMessaging;
import com.pucmm.chatapp.R;
import com.pucmm.chatapp.databinding.ActivityMainBinding;
import com.pucmm.chatapp.utilities.Constants;
import com.pucmm.chatapp.utilities.PreferenceManager;

import java.util.HashMap;

public class MainActivity extends AppCompatActivity {

    private ActivityMainBinding binding;
    private PreferenceManager preferenceManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        preferenceManager = new PreferenceManager(getApplicationContext());
        loadUserDetails();  // Cargar detalles del usuario
        getToken();         // Obtener token de Firebase
        setListeners();     // Definir listeners de botones
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
        binding.textUsername.setText(preferenceManager.getString(Constants.KEY_USERNAME));

        // Manejo seguro de la imagen en caso de que no esté disponible
        String encodedImage = preferenceManager.getString(Constants.KEY_IMAGE);

        if (encodedImage != null && !encodedImage.isEmpty()) {
            try {
                byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                binding.imageProfile.setImageBitmap(bitmap);
            } catch (IllegalArgumentException e) {
                // Error al decodificar la imagen
                showToast("Error al cargar la imagen de perfil.");
                e.printStackTrace();
            }
        } else {
            // En caso de que la imagen sea nula o vacía, cargar una imagen predeterminada
            //binding.imageProfile.setImageResource(R.drawable.default_profile_image);
        }
    }

    /**
     * Muestra un Toast con el mensaje proporcionado
     */
    private void showToast(String message){
        Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
    }

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
        FirebaseFirestore database = FirebaseFirestore.getInstance();
        DocumentReference documentReference =
                database.collection(Constants.KEY_COLLECTION_USERS).document(
                        preferenceManager.getString(Constants.KEY_USER_ID)
                );
        documentReference.update(Constants.KEY_FCM_TOKEN, token)
                .addOnFailureListener(e -> showToast("Unable to update token"));
    }

    /**
     * Cierra sesión del usuario, elimina el token FCM y borra las preferencias
     */
    private void signOut(){
        showToast("Cerrando sesión...");
        FirebaseFirestore database = FirebaseFirestore.getInstance();
        DocumentReference documentReference =
                database.collection(Constants.KEY_COLLECTION_USERS).document(
                        preferenceManager.getString(Constants.KEY_USER_ID)
                );
        HashMap<String, Object> updates = new HashMap<>();
        updates.put(Constants.KEY_FCM_TOKEN, FieldValue.delete());
        documentReference.update(updates)
                .addOnSuccessListener(unused ->{
                    preferenceManager.clear();
                    startActivity(new Intent(getApplicationContext(), SignInActivity.class));
                    finish();
                })
                .addOnFailureListener(e -> showToast("Unable to sign out"));
    }
}
