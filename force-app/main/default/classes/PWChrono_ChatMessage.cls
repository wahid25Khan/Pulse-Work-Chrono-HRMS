public class PWChrono_ChatMessage {
    @AuraEnabled public String id;
    @AuraEnabled public String senderId;
    @AuraEnabled public String senderName;
    @AuraEnabled public String content;
    @AuraEnabled public DateTime timestamp;
    @AuraEnabled public Boolean isMe;
    
    public PWChrono_ChatMessage(String id, String senderId, String senderName, String content, DateTime timestamp, Boolean isMe) {
        this.id = id;
        this.senderId = senderId;
        this.senderName = senderName;
        this.content = content;
        this.timestamp = timestamp;
        this.isMe = isMe;
    }
}