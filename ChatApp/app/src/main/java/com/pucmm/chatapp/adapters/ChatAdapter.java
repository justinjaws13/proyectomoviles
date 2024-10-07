package com.pucmm.chatapp.adapters;

import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.pucmm.chatapp.databinding.ItemContaierSentMessageBinding;
import com.pucmm.chatapp.databinding.ItemContainerReceivedMessageBinding;
import com.pucmm.chatapp.models.ChatMessage;

import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final List<ChatMessage> chatMessages;
    private final Bitmap recieverProfileImage;
    private final String senderId;

    public static final int VIEW_TYPE_SENT = 1;
    public static final int VIEW_TYPE_RECIEVED = 2;

    public ChatAdapter(List<ChatMessage> chatMessages,
                       Bitmap recieverProfileImage,
                       String senderId) {
        this.chatMessages = chatMessages;
        this.recieverProfileImage = recieverProfileImage;
        this.senderId = senderId;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if(viewType == VIEW_TYPE_SENT){
            return new SentMessageViewHolder(
                    ItemContaierSentMessageBinding.inflate(
                            LayoutInflater.from(parent.getContext()),
                            parent,
                            false
                    )
            );
        }else{
            return new RecievedMessageViewHolder(
                    ItemContainerReceivedMessageBinding.inflate(
                            LayoutInflater.from(parent.getContext()),
                            parent,
                            false
                    )
            );

        }
    }


    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
         if(getItemViewType(position) == VIEW_TYPE_SENT){
             ((SentMessageViewHolder) holder).setData(chatMessages.get(position));
         }else{
             ((RecievedMessageViewHolder) holder).setData(chatMessages.get(position), recieverProfileImage); //recieverProfileImage
         }
    }

    @Override
    public int getItemCount() {
        return chatMessages.size();
    }

    public int getItemViewType(int position){
        if(chatMessages.get(position).senderId.equals(senderId)){
            return VIEW_TYPE_SENT;
        }else{
            return VIEW_TYPE_RECIEVED;
        }
    }


    static  class  SentMessageViewHolder extends RecyclerView.ViewHolder{
        private final ItemContaierSentMessageBinding binding;

        SentMessageViewHolder(ItemContaierSentMessageBinding itemContaierSentMessageBinding){
            super(itemContaierSentMessageBinding.getRoot());
            binding = itemContaierSentMessageBinding;
        }

        void setData(ChatMessage chatMessage){
            binding.textMessage.setText(chatMessage.message);
            binding.textDateTime.setText(chatMessage.dateTime);
        }
    }

    static class RecievedMessageViewHolder extends RecyclerView.ViewHolder{

        private final ItemContainerReceivedMessageBinding binding;

        RecievedMessageViewHolder(ItemContainerReceivedMessageBinding itemContainerReceivedMessageBinding){
            super(itemContainerReceivedMessageBinding.getRoot());
            binding = itemContainerReceivedMessageBinding;
        }

        void setData(ChatMessage chatMessage, Bitmap receiverProfileImage){ // Bitmap receiverProfileImage
            binding.textMessage.setText(chatMessage.message);
            binding.textDateTime.setText(chatMessage.dateTime);
            binding.imageProfile.setImageBitmap(receiverProfileImage);

        }
    }

}
