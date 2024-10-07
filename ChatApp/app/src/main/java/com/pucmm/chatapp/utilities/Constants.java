package com.pucmm.chatapp.utilities;

import java.util.HashMap;

public class Constants {
    public static final String KEY_COLLECTION_USERS = "users";
    public static final String KEY_USERNAME  = "username";
    public static final String KEY_EMAIL  = "email";
    public static final String KEY_PASSWORD = "password";

    public static final String KEY_PREFERENCE_NAME  = "chatAppPreference";
    public static final String KEY_IS_SIGNED_IN = "isSignedIn";
    public static final String KEY_USER_ID = "userId";
    public static final String KEY_IMAGE = "image";

    public static final String KEY_FCM_TOKEN = "fcmToken";
    public static final String KEY_USER = "user";
    public static final String KEY_COLLECTION_CHAT = "chat";
    public static final String KEY_SENDER_ID = "senderID";
    public static final String KEY_RECEIVER_ID = "receiverID";
    public static final String KEY_MESSAGE = "message";
    public static final String KEY_TIMESTAMP = "timestamp";

    public static final String KEY_COLLECTION_CONVERSATIONS = "conversations";
    public static final String KEY_SENDER_USERNAME = "senderUsername";
    public static final String KEY_RECEIVER_USERNAME = "receiverUsername";
    public static final String KEY_SENDER_IMAGE = "senderImage";
    public static final String KEY_RECEIVER_IMAGE = "receiverImage";
    public static final String KEY_LAST_MESSAGE = "lastMessage";

    public static final String KEY_AVAILABILITY = "availability";

    public static final String REMOTE_MSG_AUTHORIZATION = "Authorization";
    public static final String REMOTE_MSG_CONTENT_TYPE = "Content-Type";
    public static final String REMOTE_MSG_DATA = "data";
    public static final String REMOTE_MSG_REGISTRATION_IDS = "registration_ids";



    public static HashMap<String, String> remoteMsHeaders = null;
    public static HashMap<String, String> getRemoteMsgHeaders(){
        if(remoteMsHeaders == null){
            remoteMsHeaders = new HashMap<>();
            remoteMsHeaders.put(REMOTE_MSG_AUTHORIZATION, "key=f4KwiYbESiGXZUIjuV8k22:APA91bG8eEUvmBbZB4WGZtDNvIc68ZtyhITpAA8UeKbpOf1mjNEPwqCQamStjg6HxeLdfYqJIlB4BxU0zEXOwtYVFUaAKzQsuT_7hu1LSMMw0Jzu4yEpvZz0vGA8TEXpj55F1GPhR32w");

            remoteMsHeaders.put(REMOTE_MSG_CONTENT_TYPE, "application/json");
        }
        return remoteMsHeaders;
    }


}
