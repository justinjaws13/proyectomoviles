package com.pucmm.chatapp.firebase;


import android.Manifest;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.pucmm.chatapp.R;
import com.pucmm.chatapp.activities.ChatActivity;
import com.pucmm.chatapp.models.User;
import com.pucmm.chatapp.utilities.Constants;

import java.util.List;
import java.util.Random;
import java.util.concurrent.Future;

public class MessagingService extends FirebaseMessagingService {
    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        super.onMessageReceived(message);

        getFirebaseMessage(message.getNotification().getTitle(), message.getNotification().getBody());

//        super.onMessageReceived(message);
//        User user = new User();
//        user.id = message.getData().get(Constants.KEY_USER_ID);
//        user.username = message.getData().get(Constants.KEY_USERNAME);
//        user.token = message.getData().get(Constants.KEY_FCM_TOKEN);
//
//        int notificationId = new Random().nextInt();
//        String channelId = "mensaje_chat";
//
//        Intent intent = new Intent(this, ChatActivity.class);
//        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
//        intent.putExtra(Constants.KEY_USER, user);
//        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, android.app.PendingIntent.FLAG_IMMUTABLE);
//
//        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId);
//        builder.setContentTitle(user.username);
//        builder.setContentText(message.getData().get(Constants.KEY_MESSAGE));
//        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message.getData().get(Constants.KEY_MESSAGE)));
//        builder.setPriority(NotificationCompat.PRIORITY_DEFAULT);
//        builder.setContentIntent(pendingIntent);
//        builder.setAutoCancel(true);
//
//        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
//             CharSequence channelName = "Chat Message";
//             String channelDescription = "Este canal de notificacion esta siendo usado para notificaciones de mensajes de chat";
//             int importance = NotificationManager.IMPORTANCE_DEFAULT;
//             NotificationChannel channel = new NotificationChannel(channelId, channelName, importance);
//             channel.setDescription(channelDescription);
//             NotificationManager notificationManager = getSystemService(NotificationManager.class);
//             notificationManager.createNotificationChannel(channel);
        }

    private void getFirebaseMessage(String title, String body) {
      NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "notification")
              .setSmallIcon(R.drawable.ic_notification)
              .setContentTitle(title)
              .setContentText(body)
              .setAutoCancel(true);

      NotificationManagerCompat managerCompat = NotificationManagerCompat.from(this);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        managerCompat.notify(102, builder.build());
    }

//        NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(this);
//        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
//            // TODO: Consider calling
//            //    ActivityCompat#requestPermissions
//            // here to request the missing permissions, and then overriding
//            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//            //                                          int[] grantResults)
//            // to handle the case where the user grants the permission. See the documentation
//            // for ActivityCompat#requestPermissions for more details.
//            return;
//        }
//        notificationManagerCompat.notify(notificationId, builder.build());
//    }
}
