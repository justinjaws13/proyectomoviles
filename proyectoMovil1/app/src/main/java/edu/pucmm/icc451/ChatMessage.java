package edu.pucmm.icc451;

public class ChatMessage {
    private String message;
    private String sender;
    private long timestamp;

    // Constructor vacío requerido para Firebase
    public ChatMessage() {}

    public ChatMessage(String message, String sender, long timestamp) {
        this.message = message;
        this.sender = sender;
        this.timestamp = timestamp;
    }

    // Getters y setters
    public String getMessage() { return message; }
    public String getSender() { return sender; }
    public long getTimestamp() { return timestamp; }

}
