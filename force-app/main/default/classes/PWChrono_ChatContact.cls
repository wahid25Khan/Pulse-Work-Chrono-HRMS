public class PWChrono_ChatContact {
    @AuraEnabled public String id;
    @AuraEnabled public String name;
    @AuraEnabled public String avatarUrl;
    @AuraEnabled public String status; // 'online', 'offline', etc.
    @AuraEnabled public String lastMessage;
    @AuraEnabled public DateTime lastMessageTime;
    @AuraEnabled public Integer unreadCount;
    
    public PWChrono_ChatContact(String id, String name, String avatarUrl, String status) {
        this.id = id;
        this.name = name;
        this.avatarUrl = avatarUrl;
        this.status = status;
        this.unreadCount = 0;
    }
}