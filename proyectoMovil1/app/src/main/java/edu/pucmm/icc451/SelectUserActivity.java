package edu.pucmm.icc451;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;

import java.util.ArrayList;
import java.util.List;

public class SelectUserActivity extends AppCompatActivity {

    private RecyclerView recyclerViewUsers;
    private FirebaseFirestore db;
    private FirebaseAuth auth;
    private UserAdapter userAdapter;
    private List<User> userList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_user);

        // Inicializar FirebaseAuth y Firestore
        auth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();

        // Configurar RecyclerView
        recyclerViewUsers = findViewById(R.id.recyclerViewUsers);
        recyclerViewUsers.setLayoutManager(new LinearLayoutManager(this));
        userList = new ArrayList<>();
        userAdapter = new UserAdapter(userList, user -> {
            // Acción al seleccionar un usuario
            Intent intent = new Intent(SelectUserActivity.this, ChatActivity.class);
            String chatId = createChatId(auth.getCurrentUser().getUid(), user.getUserId());
            intent.putExtra("chatId", chatId);
            startActivity(intent);
        });
        recyclerViewUsers.setAdapter(userAdapter);

        // Cargar la lista de usuarios
        loadUsers();
    }

    private void loadUsers() {
        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser != null) {
            db.collection("users")
                    .get()
                    .addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            userList.clear();
                            for (QueryDocumentSnapshot document : task.getResult()) {
                                User user = document.toObject(User.class);
                                if (!user.getUserId().equals(currentUser.getUid())) {
                                    userList.add(user);
                                }
                            }
                            userAdapter.notifyDataSetChanged();
                        } else {
                            Log.w("SelectUserActivity", "Error getting users", task.getException());
                        }
                    });
        }
    }

    // Método para crear un ID único para la conversación
    private String createChatId(String userId1, String userId2) {
        return userId1.compareTo(userId2) > 0 ? userId1 + "_" + userId2 : userId2 + "_" + userId1;
    }

}
