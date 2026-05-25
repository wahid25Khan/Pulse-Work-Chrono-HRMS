/**
 * @description Shared attachment service for request-based modules.
 *              Stores files in Salesforce Files and links them to request records.
 */
public inherited sharing class PWChrono_RequestAttachmentService {
  @AuraEnabled
  public static FileDescriptorDTO uploadFile(
    Id recordId,
    String fileName,
    String base64Data
  ) {
    if (recordId == null) {
      throw new AuraHandledException('Record Id is required for file upload.');
    }
    if (String.isBlank(fileName) || String.isBlank(base64Data)) {
      throw new AuraHandledException('File name and data are required.');
    }

    ContentVersion version = new ContentVersion();
    version.Title = fileName;
    version.PathOnClient = '/' + fileName;
    version.VersionData = EncodingUtil.base64Decode(base64Data);
    version.FirstPublishLocationId = recordId;
    insert version;

    version = [
      SELECT
        Id,
        ContentDocumentId,
        ContentDocument.Title,
        ContentDocument.FileType,
        ContentDocument.ContentSize,
        ContentDocument.CreatedDate,
        ContentDocument.CreatedBy.Name
      FROM ContentVersion
      WHERE Id = :version.Id
      LIMIT 1
    ];

    return mapVersion(version);
  }

  @AuraEnabled(cacheable=true)
  public static List<FileDescriptorDTO> getFilesForRecord(Id recordId) {
    if (recordId == null) {
      return new List<FileDescriptorDTO>();
    }

    List<FileDescriptorDTO> files = new List<FileDescriptorDTO>();
    for (ContentDocumentLink link : [
      SELECT
        ContentDocumentId,
        ContentDocument.Title,
        ContentDocument.FileType,
        ContentDocument.ContentSize,
        ContentDocument.CreatedDate,
        ContentDocument.CreatedBy.Name,
        ContentDocument.LatestPublishedVersionId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recordId
      ORDER BY ContentDocument.CreatedDate DESC
    ]) {
      FileDescriptorDTO dto = new FileDescriptorDTO();
      dto.id = link.ContentDocumentId;
      dto.contentDocumentId = link.ContentDocumentId;
      dto.contentVersionId = link.ContentDocument.LatestPublishedVersionId;
      dto.name = link.ContentDocument.Title;
      dto.fileType = link.ContentDocument.FileType;
      dto.contentSize = link.ContentDocument.ContentSize;
      dto.sizeLabel = formatFileSize(link.ContentDocument.ContentSize);
      dto.createdDate = link.ContentDocument.CreatedDate;
      dto.createdByName = link.ContentDocument.CreatedBy != null
        ? link.ContentDocument.CreatedBy.Name
        : null;
      dto.downloadUrl =
        '/sfc/servlet.shepherd/document/download/' + link.ContentDocumentId;
      files.add(dto);
    }

    return files;
  }

  private static FileDescriptorDTO mapVersion(ContentVersion version) {
    FileDescriptorDTO dto = new FileDescriptorDTO();
    dto.id = version.ContentDocumentId;
    dto.contentDocumentId = version.ContentDocumentId;
    dto.contentVersionId = version.Id;
    dto.name = version.ContentDocument != null
      ? version.ContentDocument.Title
      : version.Title;
    dto.fileType = version.ContentDocument != null
      ? version.ContentDocument.FileType
      : null;
    dto.contentSize = version.ContentDocument != null
      ? version.ContentDocument.ContentSize
      : null;
    dto.sizeLabel = formatFileSize(dto.contentSize);
    dto.createdDate = version.ContentDocument != null
      ? version.ContentDocument.CreatedDate
      : null;
    dto.createdByName = version.ContentDocument != null &&
      version.ContentDocument.CreatedBy != null
      ? version.ContentDocument.CreatedBy.Name
      : null;
    dto.downloadUrl =
      '/sfc/servlet.shepherd/document/download/' + version.ContentDocumentId;
    return dto;
  }

  private static String formatFileSize(Integer bytes) {
    if (bytes == null) {
      return null;
    }
    if (bytes >= 1024 * 1024) {
      Decimal megaBytes = Decimal.valueOf(bytes) / (1024 * 1024);
      return megaBytes.setScale(1) + ' MB';
    }
    if (bytes >= 1024) {
      Decimal kiloBytes = Decimal.valueOf(bytes) / 1024;
      return kiloBytes.setScale(1) + ' KB';
    }
    return String.valueOf(bytes) + ' B';
  }

  public class FileDescriptorDTO {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public Id contentDocumentId;
    @AuraEnabled
    public Id contentVersionId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String fileType;
    @AuraEnabled
    public Integer contentSize;
    @AuraEnabled
    public String sizeLabel;
    @AuraEnabled
    public Datetime createdDate;
    @AuraEnabled
    public String createdByName;
    @AuraEnabled
    public String downloadUrl;
  }
}
