package edu.pucmm.icc451;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;

import java.util.ArrayList;
import java.util.List;

public class ChatActivity extends AppCompatActivity {

    private RecyclerView recyclerViewMessages;
    private EditText editTextMessage;
    private TextView textViewSenderName; // Para mostrar el nombre del usuario

    private FirebaseFirestore db;
    private FirebaseAuth auth; // Instancia de FirebaseAuth
    private ChatAdapter chatAdapter;
    private List<ChatMessage> messageList;
    private String senderName; // Variable para almacenar el nombre del remitente

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat); // Asegúrate de que este sea el layout correcto que contiene el RecyclerView y el input.

        // Inicializar FirebaseAuth
        auth = FirebaseAuth.getInstance();
        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser != null) {
            senderName = currentUser.getEmail(); // Obtener el correo electrónico del usuario actual
        } else {
            senderName = "Usuario Desconocido"; // Manejo de caso donde no hay usuario
        }

        // Inicializar vistas
        recyclerViewMessages = findViewById(R.id.recyclerViewMessages);
        editTextMessage = findViewById(R.id.editTextMessage);
        Button buttonSend = findViewById(R.id.buttonSend);

        // Configurar RecyclerView
        messageList = new ArrayList<>();
        chatAdapter = new ChatAdapter(messageList);
        recyclerViewMessages.setAdapter(chatAdapter);
        recyclerViewMessages.setLayoutManager(new LinearLayoutManager(this));

        // Configurar Firebase Firestore
        db = FirebaseFirestore.getInstance();

        // Enviar mensajes
        buttonSend.setOnClickListener(view -> {
            String messageText = editTextMessage.getText().toString();
            if (!messageText.isEmpty()) {
                long timestamp = System.currentTimeMillis();

                ChatMessage chatMessage = new ChatMessage(messageText, senderName, timestamp);
                db.collection("messages")
                        .add(chatMessage)
                        .addOnSuccessListener(documentReference -> editTextMessage.setText(""))
                        .addOnFailureListener(e -> Log.w("ChatActivity", "Error al enviar mensaje", e));
            }
        });

        // Recibir mensajes en tiempo real
        db.collection("messages")
                .orderBy("timestamp", Query.Direction.ASCENDING)
                .addSnapshotListener((queryDocumentSnapshots, e) -> {
                    if (e != null) {
                        Log.w("ChatActivity", "Error al recibir mensajes", e);
                        return;
                    }
                    messageList.clear();
                    assert queryDocumentSnapshots != null;
                    for (QueryDocumentSnapshot document : queryDocumentSnapshots) {
                        ChatMessage chatMessage = document.toObject(ChatMessage.class);
                        messageList.add(chatMessage);
                    }
                    chatAdapter.notifyDataSetChanged();
                    recyclerViewMessages.smoothScrollToPosition(messageList.size() - 1);
                });
    }
}
