/**
 * PWChrono_CareerPortalController
 * Public-facing career portal: browse open job postings and submit applications.
 * No HR-auth guard — portal is accessible to all (including guest users).
 */
public without sharing class PWChrono_CareerPortalController {
  // ─────────────────────────────────────────────────────────────────────────
  // Job Opening queries
  // ─────────────────────────────────────────────────────────────────────────

  /**
   * Returns open job postings with optional filters.
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Job_Opening__c> getOpenJobs(
    String keyword,
    String departmentId,
    String company,
    String employmentType,
    String location
  ) {
    try {
      String baseQuery =
        'SELECT Id, Name, Company__c, Location__c, Employment_Type__c, ' +
        'No_of_Positions__c, Closing_Date__c, Job_Description__c, ' +
        'Department__c, Department__r.Name, ' +
        'Designation__c, Designation__r.Name ' +
        'FROM PWChrono_Job_Opening__c ' +
        'WHERE Status__c = \'Open\'';

      if (String.isNotBlank(keyword)) {
        String kw = '%' + String.escapeSingleQuotes(keyword.trim()) + '%';
        baseQuery +=
          ' AND (Name LIKE \'' +
          kw +
          '\' OR Job_Description__c LIKE \'' +
          kw +
          '\')';
      }
      if (String.isNotBlank(departmentId)) {
        baseQuery +=
          ' AND Department__c = \'' +
          String.escapeSingleQuotes(departmentId) +
          '\'';
      }
      if (String.isNotBlank(company)) {
        String co = '%' + String.escapeSingleQuotes(company.trim()) + '%';
        baseQuery += ' AND Company__c LIKE \'' + co + '\'';
      }
      if (String.isNotBlank(employmentType)) {
        baseQuery +=
          ' AND Employment_Type__c = \'' +
          String.escapeSingleQuotes(employmentType) +
          '\'';
      }
      if (String.isNotBlank(location)) {
        String loc = '%' + String.escapeSingleQuotes(location.trim()) + '%';
        baseQuery += ' AND Location__c LIKE \'' + loc + '\'';
      }

      baseQuery +=
        ' ORDER BY CreatedDate DESC LIMIT ' +
        PWChrono_Constants.DEFAULT_QUERY_LIMIT;

      return Database.query(baseQuery); // NOPMD
    } catch (Exception e) {
      PWChrono_Logger.error('PWChrono_CareerPortalController.getOpenJobs', e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * Returns a single job opening by Id.
   */
  @AuraEnabled(cacheable=true)
  public static PWChrono_Job_Opening__c getJobById(String jobOpeningId) {
    try {
      List<PWChrono_Job_Opening__c> jobs = [
        SELECT
          Id,
          Name,
          Company__c,
          Location__c,
          Employment_Type__c,
          No_of_Positions__c,
          Closing_Date__c,
          Job_Description__c,
          Department__c,
          Department__r.Name,
          Designation__c,
          Designation__r.Name,
          Status__c
        FROM PWChrono_Job_Opening__c
        WHERE Id = :jobOpeningId
        LIMIT 1
      ];
      if (jobs.isEmpty()) {
        throw new AuraHandledException('Job opening not found.');
      }
      return jobs[0];
    } catch (AuraHandledException e) {
      throw e;
    } catch (Exception e) {
      PWChrono_Logger.error('PWChrono_CareerPortalController.getJobById', e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * Returns active departments for the filter dropdown.
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Department__c> getActiveDepartments() {
    try {
      return [
        SELECT Id, Name
        FROM PWChrono_Department__c
        WHERE Is_Active__c = TRUE
        ORDER BY Name ASC
        LIMIT 200
      ];
    } catch (Exception e) {
      PWChrono_Logger.error(
        'PWChrono_CareerPortalController.getActiveDepartments',
        e
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Application submission
  // ─────────────────────────────────────────────────────────────────────────

  /**
   * Inserts a Job Applicant record from the public application form.
   * @param applicationJson  JSON-serialised PWChrono_Job_Applicant__c fields.
   * @return  Id of the created record.
   */
  @AuraEnabled
  public static String submitApplication(String applicationJson) {
    try {
      if (String.isBlank(applicationJson)) {
        throw new AuraHandledException('Application data is required.');
      }
      PWChrono_Job_Applicant__c applicant = (PWChrono_Job_Applicant__c) JSON.deserialize(
        applicationJson,
        PWChrono_Job_Applicant__c.class
      );
      applicant.Id = null; // always insert
      applicant.Status__c = 'Applied';
      insert applicant;
      return applicant.Id;
    } catch (AuraHandledException e) {
      throw e;
    } catch (Exception e) {
      PWChrono_Logger.error(
        'PWChrono_CareerPortalController.submitApplication',
        e
      );
      throw new AuraHandledException(e.getMessage());
    }
  }
}
