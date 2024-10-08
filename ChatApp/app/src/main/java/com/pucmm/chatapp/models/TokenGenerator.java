package com.pucmm.chatapp.models;

import android.os.Handler;
import android.os.Looper;

import org.json.JSONException;
import org.json.JSONObject;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import retrofit2.Callback;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class TokenGenerator {

    private static final String SERVICE_ACCOUNT_EMAIL = "android-studio-chatapp-emely@chatapp1-5f3e5.iam.gserviceaccount.com";
    private static final String PRIVATE_KEY = "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCiJKlSDZXvAXNV\n8vF+uVaWk2ReZAeQkPSCxr1WMxP2cjauctPtOZPk+8vTVOq6ZP7SehgDsqhwSyRh\nc8TJxWBfXDDJiJlPRPAElNcmnHbxRDOFcSI5vnakTVzvqh1prf2RwWKEaBNODjRc\ncWCkI4fbil4vtQVnaSfwUPKyWryiSSLmYvWEJzkVTScSJT5duT5/ytIO377+MCnz\npb/c5ODakRlb//09cnaOuorFAlUdpKOyDyqJAct7HepD9UDssdy87rvXwZa5FDc6\nYkOFZcAuYobGwcs4DB1jWLJ0wse/7LZU48RoK+y0HwNpFdEfvAZClQdwLSS+ivhB\nvU9Ca9GfAgMBAAECggEAR40nHRr6raB1vZl6YWI3aDY9xfudbPnStL0wA1CCADCx\nmbT5eYd9kMBe13DzLnLwEoCnhUY7V2aJdOnKDwInP52mt+CsStNQmaz27saAJILk\nu3/LyzCWGXY8S1TGKwMJUV9F8skcr8bL63lq3LQDOWnrm2DmNBau9bk7CGLLOE+a\nnPZeN9ZGRrGlL5FV9GbWVYAVrEmV9/TJXqu64z+HOpgNaqYX9CeEPmCvgOvvTjBz\noT/3uQ8JboGL2McaFssZFXb04tIwVs3yzDecI5XVHhqqhjZbDGRkA/PiW3u8B3q4\nBxnBGoxLje7h+liSMcf8AatiCfAMxOKsnS4MMcUOeQKBgQDb45bGdKfpPAeDV6Fy\nwa9vk/mTZlC7zBfUstyM7hS9eSVZxaYoDHVFsXngi9c/rlNaBwrbusM04CCBzi3j\n0e+2f+c5TLyE28URpND/JDLFCjDBUBZOSOCR+VLBJEpQWbQprt/zTueK6hGcbE2r\neMmZvZdSL2LbBhbGclOgYRVtBwKBgQC8xV2r2QOkROS/jW/DbsfXmhI7yF/UcJiB\nRO/C8+PsG8bFmtNPbceF4yKhs9Q2zQDVuqcbXykIvIVY5Uk3lRtnV90FuZxhxk88\nA2yXOhQhabW+EsX6tB/Vm3q6D+9xrLgisYPw7WKMVo3O3KUNtY0KhO86nd79mX66\ncJllTiRoqQKBgAsV5jwLFYwEorxUZqdKbHXLmAF+XwOYvnrSqZvRROpoeSGVfVL3\njdH9qI9RfYCQYVNgl4OMXtsDkZ/5rQaXRuaEfDu/SqHIEp9ZF9BFGuokIWEdkIJR\n2kCBuVJTaguy+go/7rptd+7g7hJcw22poUBG9qIGEY3JOMy4Zs7nFhVxAoGAFJJV\noPKnaPFxFEbvlRavhJlvv0AY4Wfb1sqSbmZxwjtMsCAtQwytn7OfBIw6ZjZ1DtWm\nfF8kc6VHyuZB0mLXd62lkogluKoJ3HprDRfxNar1eV9GYAndJkQpXbl62KJ/9pft\nzwWvpaeREKgO/K16T1kpUPP/ZxehLeQzc0zOvvECgYAaLX2AfRaIlvaNftQ2maKD\nfvQe3FpXsVh3eyLbDYwuCXZz6pQqmcOy79wtf7VMaBv44YHzLgzjU2vA3qZu8U/s\nh/J/pdBhHab+/+qQRsM0W9fVrBYvMUhtySjImnbI9i3A952mqDZhvVY+CXQvTewK\ndHVzXuMWocjK4QE043ct4Q==\n-----END PRIVATE KEY-----\n";
    private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";

    public String createJWT() throws Exception {
        try {
            // Decodificar la clave privada base64
            byte[] encoded = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                encoded = Base64.getDecoder().decode(PRIVATE_KEY.replace("-----BEGIN PRIVATE KEY-----\n", "")
                        .replace("-----END PRIVATE KEY-----", "")
                        .replace("\n", ""));
            }
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(encoded);
            PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(keySpec);

            // Construir el JWT
            Calendar calendar = Calendar.getInstance();
            Date now = calendar.getTime();
            calendar.add(Calendar.HOUR, 1);  // Token válido por 1 hora
            Date expirationTime = calendar.getTime();

            String jwt = Jwts.builder()
                    .setIssuer(SERVICE_ACCOUNT_EMAIL)
                    .setSubject(SERVICE_ACCOUNT_EMAIL)
                    .setAudience(TOKEN_URL)
                    .setIssuedAt(now)
                    .setExpiration(expirationTime)
                    .signWith(SignatureAlgorithm.RS256, privateKey)
                    .compact();

            // Verifica si el JWT se generó correctamente
            if (jwt == null || jwt.isEmpty()) {
                throw new Exception("Error: JWT is null or empty");
            }

            System.out.println("JWT generated successfully: " + jwt);
            return jwt;

        } catch (Exception e) {
            System.err.println("Error generating JWT: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public String getAccessToken(String jwt) throws Exception {
        OkHttpClient client = new OkHttpClient();

        try {
            RequestBody requestBody = new FormBody.Builder()
                    .add("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer")
                    .add("assertion", jwt)
                    .build();

            Request request = new Request.Builder()
                    .url(TOKEN_URL)
                    .post(requestBody)
                    .addHeader("Content-Type", "application/x-www-form-urlencoded")
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (response.isSuccessful() && response.body() != null) {
                    String responseBody = response.body().string();
                    System.out.println("Response from token URL: " + responseBody);
                    JSONObject jsonObject = new JSONObject(responseBody);
                    String accessToken = jsonObject.getString("access_token");

                    // Verifica si el token de acceso se recibió correctamente
                    if (accessToken == null || accessToken.isEmpty()) {
                        throw new Exception("Error: Access token is null or empty");
                    }

                    System.out.println("Access Token generated successfully: " + accessToken);
                    return accessToken;

                } else {
                    String errorMessage = response.body() != null ? response.body().string() : "Unknown error";
                    throw new IOException("Failed to obtain access token. Response: " + response.message() + ", Error: " + errorMessage);
                }
            } catch (JSONException e) {
                System.err.println("Error parsing JSON: " + e.getMessage());
                throw new RuntimeException(e);
            }
        } catch (Exception e) {
            System.err.println("Error getting Access Token: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public void getAccessTokenAsync(String jwt, Callback<String> callback) {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            try {
                String accessToken = getAccessToken(jwt);
                // Llamamos al callback en el hilo principal después de obtener el token
                new Handler(Looper.getMainLooper()).post(() -> callback.onSuccess(accessToken));
            } catch (Exception e) {
                new Handler(Looper.getMainLooper()).post(() -> callback.onError(e));
            }
        });
    }

    public interface Callback<T> {
        void onSuccess(T result);
        void onError(Exception e);
    }
}
