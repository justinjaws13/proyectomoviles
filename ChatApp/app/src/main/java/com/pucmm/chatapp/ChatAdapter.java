package com.pucmm.chatapp;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.pucmm.chatapp.R;
import com.pucmm.chatapp.models.ChatMessage;
import com.pucmm.chatapp.utilities.Constants;

import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final List<ChatMessage> chatMessages;
    private final Bitmap receiverProfileImage;
    private final String senderId;

    // Constructor para inicializar los mensajes, la imagen del receptor y el ID del remitente
    public ChatAdapter(List<ChatMessage> chatMessages, Bitmap receiverProfileImage, String senderId) {
        this.chatMessages = chatMessages;
        this.receiverProfileImage = receiverProfileImage;
        this.senderId = senderId;
    }

    @Override
    public int getItemViewType(int position) {
        // Determina si el mensaje fue enviado por el usuario o recibido
        if (chatMessages.get(position).senderId.equals(senderId)) {
            return R.layout.item_container_sent_message;
        } else {
            return R.layout.item_container_received_message;
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // Infla el layout de cada mensaje (enviado o recibido)
        return new ChatViewHolder(
                LayoutInflater.from(parent.getContext()).inflate(viewType, parent, false)
        );
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        // Llama al método `setData` para mostrar la información en cada mensaje
        ((ChatViewHolder) holder).setData(chatMessages.get(position));
    }

    @Override
    public int getItemCount() {
        return chatMessages.size();
    }

    // Clase interna para manejar cada vista de mensaje
    class ChatViewHolder extends RecyclerView.ViewHolder {
        TextView textMessage, textDateTime;
        ImageView imageMessage;

        ChatViewHolder(@NonNull View itemView) {
            super(itemView);
            textMessage = itemView.findViewById(R.id.textMessage);
            textDateTime = itemView.findViewById(R.id.textDateTime);
            imageMessage = itemView.findViewById(R.id.imageMessage);
        }

        void setData(ChatMessage chatMessage) {
            // Verifica si el mensaje tiene texto o es una imagen
            if (chatMessage.message != null && !chatMessage.message.isEmpty()) {
                textMessage.setVisibility(View.VISIBLE);
                imageMessage.setVisibility(View.GONE);
                textMessage.setText(chatMessage.message);
            } else if (chatMessage.image != null) {
                textMessage.setVisibility(View.GONE);
                imageMessage.setVisibility(View.VISIBLE);
                imageMessage.setImageBitmap(getBitmapFromEncodedString(chatMessage.image));
            }
            textDateTime.setText(chatMessage.dateTime);
        }
    }

    private Bitmap getBitmapFromEncodedString(String encodedImage) {
        byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }
}
