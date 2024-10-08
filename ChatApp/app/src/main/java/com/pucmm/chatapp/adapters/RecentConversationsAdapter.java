package com.pucmm.chatapp.adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.pucmm.chatapp.databinding.ItemContainerRecentConversationBinding;
import com.pucmm.chatapp.listeners.ConversionListener;
import com.pucmm.chatapp.models.ChatMessage;
import com.pucmm.chatapp.models.User;

import java.util.List;


public class RecentConversationsAdapter extends RecyclerView.Adapter<RecentConversationsAdapter.conversionViewHolder>{

    private final List<ChatMessage> chatMessages;
    private final ConversionListener conversionListener;

    public RecentConversationsAdapter(List<ChatMessage> chatMessages, ConversionListener conversionListener) {
        this.chatMessages = chatMessages;
        this.conversionListener = conversionListener;
    }

    @NonNull
    @Override
    public conversionViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new conversionViewHolder(
                ItemContainerRecentConversationBinding.inflate(
                        LayoutInflater.from(parent.getContext()),
                parent,
                false
                )
        );
    }

    @Override
    public void onBindViewHolder(@NonNull conversionViewHolder holder, int position) {
        holder.setData(chatMessages.get(position));
    }

    @Override
    public int getItemCount() {
        return chatMessages.size();
    }

    class conversionViewHolder extends RecyclerView.ViewHolder{

        ItemContainerRecentConversationBinding binding;

        conversionViewHolder(ItemContainerRecentConversationBinding itemContainerRecentConversationBinding){
         super (itemContainerRecentConversationBinding.getRoot());
         binding = itemContainerRecentConversationBinding;
        }
    void setData(ChatMessage chatMessage){
//            binding.imageProfile.setImageBitmap(getConversionImage(chatMessage.conversionImage));
            binding.textUsername.setText(chatMessage.conversionUsername);
            binding.textRecentMessage.setText(chatMessage.message);
            binding.getRoot().setOnClickListener(v -> {
                User user = new User();
                user.id = chatMessage.conversionId;
                user.username = chatMessage.conversionUsername;
//                user.image = chatMessage.conversionImage;
                conversionListener.onConversionClicked(user);
            });
    }

    }

//    private Bitmap getConversionImage(String encodedImage){
//        byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
//        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
//    }

}
