package edu.pucmm.icc451;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.text.DateFormat;
import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ChatViewHolder> {

    // Lista de mensajes que el adaptador manejará
    private List<ChatMessage> messageList;

    // Constructor que toma la lista de mensajes
    public ChatAdapter(List<ChatMessage> messageList) {
        this.messageList = messageList;
    }

    @NonNull
    @Override
    public ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // Inflar la vista de cada elemento de la lista desde el layout item_message.xml
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_message, parent, false);
        return new ChatViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ChatViewHolder holder, int position) {
        // Obtener el mensaje en la posición actual
        ChatMessage message = messageList.get(position);

        // Llenar las vistas con los datos del mensaje
        holder.textViewMessage.setText(message.getMessage());
        holder.textViewSender.setText(message.getSender());
        holder.textViewTimestamp.setText(DateFormat.getTimeInstance(DateFormat.SHORT).format(message.getTimestamp()));
    }

    @Override
    public int getItemCount() {
        // Retornar la cantidad de mensajes
        return messageList.size();
    }

    // Clase ViewHolder que maneja las vistas para cada elemento del RecyclerView
    static class ChatViewHolder extends RecyclerView.ViewHolder {
        TextView textViewMessage, textViewSender, textViewTimestamp;

        public ChatViewHolder(@NonNull View itemView) {
            super(itemView);
            // Asociar cada vista del layout item_message.xml con una variable
            textViewMessage = itemView.findViewById(R.id.textViewMessage);
            textViewSender = itemView.findViewById(R.id.textViewSender);
            textViewTimestamp = itemView.findViewById(R.id.textViewTimestamp);
        }
    }
}
