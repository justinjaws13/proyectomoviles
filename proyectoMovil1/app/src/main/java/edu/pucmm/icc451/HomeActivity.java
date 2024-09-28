package edu.pucmm.icc451;

import android.os.Bundle;
import android.widget.TextView;
import android.content.Intent;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;

enum ProviderType {
    BASIC
}

public class HomeActivity extends AppCompatActivity {

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
        Bundle bundle = getIntent().getExtras();
        String email = bundle != null ? bundle.getString("email") : null;
        String provider = bundle != null ? bundle.getString("provider_name") : null;

        setup(email != null ? email : "", provider != null ? provider : "");
    }

    private void setup(String email, String provider) {
        setTitle("Inicio");
        TextView emailTextView = findViewById(R.id.emailTextView);
        TextView proveedorTextView = findViewById(R.id.proveedorTextView);

        emailTextView.setText(email);
        proveedorTextView.setText(provider);

        findViewById(R.id.cerrarSesionButton).setOnClickListener(v -> {
            FirebaseAuth.getInstance().signOut();
            Intent intent = new Intent(HomeActivity.this, AuthActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();  // Cierra la actividad actual
        });
    }
}
