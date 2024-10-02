package edu.pucmm.icc451;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.snackbar.Snackbar;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

import edu.pucmm.icc451.databinding.ActivityAuthBinding;

public class AuthActivity extends AppCompatActivity {

    private FirebaseAuth auth;
    private ActivityAuthBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Usar ViewBinding
        binding = ActivityAuthBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Inicializar FirebaseAuth
        auth = FirebaseAuth.getInstance();

        // Configurar eventos de botones
        setup();
    }

    // Configurar los botones de login y registro
    private void setup() {
        binding.loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String email = binding.emailEditText.getText().toString();
                String password = binding.passwordEditText.getText().toString();

                if (!email.isEmpty() && !password.isEmpty()) {
                    auth.signInWithEmailAndPassword(email, password)
                            .addOnCompleteListener(task -> {
                                if (task.isSuccessful()) {
                                    FirebaseUser user = auth.getCurrentUser();
                                    // Inicio de sesión exitoso, dirigir a la siguiente actividad
                                    if (user != null) {
                                        goToHomeActivity();
                                    }
                                } else {
                                    showSnackbar("Error de autenticación: " + task.getException().getMessage());
                                }
                            });
                } else {
                    showSnackbar("Por favor ingrese ambos campos.");
                }
            }
        });

        // Ir a la pantalla de registro
        binding.registrarButton.setOnClickListener(v -> {
            Intent intent = new Intent(AuthActivity.this, RegistrarActivity.class);
            startActivity(intent);
        });
    }

    // Método para navegar a la actividad principal después del login
    private void goToHomeActivity() {
        Intent intent = new Intent(this, HomeActivity.class); // Suponiendo que tienes una HomeActivity
        startActivity(intent);
        finish(); // Cerrar la actividad actual
    }

    // Método para mostrar mensajes
    private void showSnackbar(String message) {
        Snackbar.make(binding.getRoot(), message, Snackbar.LENGTH_LONG).show();
    }

    @Override
    protected void onStart() {
        super.onStart();
        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser != null) {
            // Si el usuario ya ha iniciado sesión, ir directamente a HomeActivity
            goToHomeActivity();
        }
    }
}
