package edu.pucmm.icc451;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.snackbar.Snackbar;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;

import edu.pucmm.icc451.databinding.ActivityRegistrarBinding;

public class RegistrarActivity extends AppCompatActivity {

    private ActivityRegistrarBinding binding;
    private FirebaseAuth auth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Utilizar ViewBinding para inflar el layout
        binding = ActivityRegistrarBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Inicializar Firebase Auth
        auth = FirebaseAuth.getInstance();

        setSupportActionBar(binding.toolbar);

        // Configurar los eventos de los botones
        setup();
    }

    // Setup para manejar el registro
    private void setup() {
        // Acción al presionar el botón de registrar
        binding.registrarButton.setOnClickListener(v -> {
            String email = binding.emailEditText.getText().toString();
            String password = binding.passwordEditText.getText().toString();

            // Validar que los campos no estén vacíos
            if (!email.isEmpty() && !password.isEmpty()) {
                auth.createUserWithEmailAndPassword(email, password)
                        .addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                // Registro exitoso, ir al login
                                Intent loginIntent = new Intent(RegistrarActivity.this, AuthActivity.class);
                                startActivity(loginIntent);
                                finish(); // Cerrar la actividad actual
                            } else {
                                // Manejar errores
                                if (task.getException() instanceof FirebaseAuthUserCollisionException) {
                                    showSnackbar("Este email ya está registrado.");
                                } else {
                                    showSnackbar("Error al registrar: " + task.getException().getMessage());
                                }
                            }
                        });
            } else {
                showSnackbar("Los campos no pueden estar vacíos.");
            }
        });

        // Acción para volver a la pantalla de login
        binding.volverLoginButton.setOnClickListener(v -> {
            Intent loginIntent = new Intent(RegistrarActivity.this, AuthActivity.class);
            startActivity(loginIntent);
            finish(); // Cierra la actividad actual
        });
    }

    // Método para mostrar un mensaje usando Snackbar
    private void showSnackbar(String message) {
        Snackbar.make(binding.getRoot(), message, Snackbar.LENGTH_LONG).show();
    }
}
