package edu.pucmm.icc451;

import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.content.Intent;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

enum ProviderType {
    BASIC
}

public class HomeActivity extends AppCompatActivity  implements UserAdapter.OnUserClickListener {

    private RecyclerView usuariosRecyclerView;
    private UserAdapter usuariosAdapter;
    private List<User> usuariosList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FirebaseApp.initializeApp(this);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_home);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Setup
//        Bundle bundle = getIntent().getExtras();
//        String email = bundle != null ? bundle.getString("email") : null;
//        String provider = bundle != null ? bundle.getString("provider_name") : null;
//
//        setup(email != null ? email : "", provider != null ? provider : "");

        Bundle bundle = getIntent().getExtras();
        if (bundle == null) {
            Log.e("HomeActivity", "Bundle is null");
        } else {
            String email = bundle.getString("email");
            String provider = bundle.getString("provider_name");
            Log.d("HomeActivity", "Email: " + email + ", Provider: " + provider);
        }

        // Configurar el RecyclerView
        usuariosRecyclerView = findViewById(R.id.usuariosRecyclerView);
        usuariosRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        usuariosList = new ArrayList<>();

        FirebaseFirestore db = FirebaseFirestore.getInstance();
        db.collection("users").get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                for (QueryDocumentSnapshot document : task.getResult()) {
                    String userId = document.getId();
                    String emailUser = document.getString("email");
                    usuariosList.add(new User(userId, emailUser));
                }
                usuariosAdapter = new UserAdapter(usuariosList, this);
                usuariosRecyclerView.setAdapter(usuariosAdapter);
            } else {
                // Manejar error
                System.out.println("Error getting documents: " + task.getException());
            }
        });

        findViewById(R.id.cerrarSesionButton).setOnClickListener(v -> {
            FirebaseAuth.getInstance().signOut();
            Intent intent = new Intent(HomeActivity.this, AuthActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish(); // Cierra la actividad actual
        });

    }

    private void setup(String email, String provider) {
        setTitle("Inicio");
        TextView emailTextView = findViewById(R.id.emailTextView);
        TextView proveedorTextView = findViewById(R.id.proveedorTextView);

        emailTextView.setText(email);
        proveedorTextView.setText(provider);
    }

    @Override
    public void onUserClick(User user) {
        // Crear un intent para iniciar el chat directamente
        Intent intent = new Intent(HomeActivity.this, ChatActivity.class);
        String currentUserId = Objects.requireNonNull(FirebaseAuth.getInstance().getCurrentUser()).getUid();
        String chatId = createChatId(currentUserId, user.getUserId());
        intent.putExtra("chatId", chatId);
        startActivity(intent);
    }

    public static String createChatId(String userId1, String userId2) {
        return userId1.compareTo(userId2) > 0 ? userId1 + "_" + userId2 : userId2 + "_" + userId1;
    }

}
