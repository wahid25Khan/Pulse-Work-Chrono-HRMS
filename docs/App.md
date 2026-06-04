# AI System Build Prompt: HRMS and Recruitment Management System

I want you to create a complete HRMS and Recruitment Management System inspired by the process, fields, and workflow patterns shown in the provided Frappe HRMS reference document.

The system should not be an exact copy of Frappe, but it should follow similar business processes, similar object structures, similar fields, similar workflows, and similar user experience.

## 1. Core Modules Required

Build the system with the following modules:

1. Recruitment
2. Job Requisition
3. Staffing Plan
4. Job Opening
5. Job Application
6. Interview Management
7. Interview Feedback
8. Job Offer
9. Recruitment Dashboard
10. Employee Referral
11. Employee Master
12. Employee Onboarding
13. Employee Promotion
14. Employee Transfer
15. Employee Separation / Exit
16. Full and Final Settlement
17. Expense and Employee Advance
18. Leave Management
19. Holiday List
20. Attendance and Employee Check-In
21. Payroll
22. Salary Structure and Salary Slip
23. Training
24. Organizational Chart
25. HR Dashboards and Reports

## 2. Recruitment Process

Create a recruitment process with this flow:

Staffing Plan → Job Requisition → Job Opening → Published Job Portal → Job Application → Interview → Interview Feedback → Candidate Accepted / Rejected → Job Offer → Employee Creation / Onboarding

### 2.1 Staffing Plan

The Staffing Plan should allow HR to plan hiring requirements by department, designation, and date range.

Required fields:

- Staffing Plan Name
- Company
- Department
- From Date
- To Date
- Status: Draft, Submitted, Closed
- Designation
- Vacancies
- Estimated Cost Per Position
- Total Estimated Cost
- Number of Positions
- Requested By
- Created Date
- Modified Date

The Staffing Plan should support multiple staffing plan detail rows.

### 2.2 Job Requisition

The Job Requisition should allow departments to request new hiring.

Required fields:

- Requisition Title
- Designation
- Department
- Requested By
- Requested By Department
- Number of Positions
- Expected Compensation
- Company
- Status: Pending, Open & Approved, Filled, Rejected, Closed
- Expected By Date
- Posting Date
- Completed On
- Time to Fill
- Staffing Plan
- Reason for Hiring
- Job Description
- Connections to Job Opening and Job Applicant records

Business rules:

- A Job Requisition can be created from a Staffing Plan.
- A Job Requisition can create or link to one or more Job Openings.
- Status should update based on approval and hiring progress.

### 2.3 Job Opening

The Job Opening should represent an active position available for applicants.

Required fields:

- Job Title
- Designation
- Department
- Company
- Employment Type: Full-Time, Part-Time, Contract, Internship
- Location
- Status: Open, Closed
- Posted On
- Closed On
- Job Description
- Job Requisition
- Publish on Website: Yes/No
- Publish Applications Received: Yes/No
- Job Application Route / URL
- Number of Applications
- Expected Skills
- Minimum Experience
- Salary Range
- Hiring Manager

Business rules:

- If Publish on Website is enabled, the Job Opening should appear on the public career portal.
- The public job page should allow candidates to apply using a web form.
- Job Openings should be filterable by company, department, employment type, location, and status.

### 2.4 Career Portal / Web Form

Create a public job portal where published Job Openings are visible.

The job portal should include:

- Job cards
- Department filter
- Company filter
- Employment Type filter
- Location filter
- Search by keyword
- Job detail page
- Apply button
- Job Application form

Job Application form fields:

- Job Opening
- Applicant Name
- Email Address
- Phone Number
- Country of Residence
- Cover Letter
- Resume Attachment
- Resume Link
- Source
- Expected Salary
- Lower Salary Range
- Upper Salary Range

After submission, the system should create a Job Applicant record.

### 2.5 Job Applicant

The Job Applicant object should store candidate/application details.

Required fields:

- Applicant Name
- Email Address
- Phone Number
- Country
- Job Opening
- Designation
- Status: Open, Rejected, Accepted, Hold, Offer Made
- Source: Referral, Website, Recruiter, Job Board, Other
- Applicant Rating
- Resume Attachment
- Resume Link
- Cover Letter
- Expected Salary
- Lower Range
- Upper Range
- Interview Summary
- Offer Status
- Created Date
- Modified Date

Related records:

- Interviews
- Interview Feedback
- Job Offers
- Employee Referral
- Attachments

Business rules:

- HR should be able to create an Interview directly from the Job Applicant record.
- Once interview feedback is cleared, HR should be able to mark the applicant as Accepted.
- Accepted applicants should be eligible for Job Offer creation.

## 3. Interview Management

Create an Interview object to track interviews for candidates.

Required fields:

- Interview Name
- Job Applicant
- Job Opening
- Interview Round: First, HR Interview, Technical Interview, Final Interview
- Scheduled Date
- From Time
- To Time
- Interviewer
- Interviewer Email
- Status: Scheduled, Under Review, Cleared, Rejected, Cancelled
- Average Rating
- Feedback Summary
- Skill Assessment Table

Skill Assessment child table fields:

- Skill
- Rating
- Comments

Business rules:

- Each interview can have one or more interviewers.
- Interviewers can submit feedback.
- System should calculate average rating from skill ratings.
- Interview feedback should show an overall average rating and rating distribution.
- If the candidate clears the interview, HR should be prompted to update the Job Applicant status to Accepted.

## 4. Job Offer

Create a Job Offer object for accepted applicants.

Required fields:

- Job Applicant
- Applicant Name
- Applicant Email Address
- Offer Date
- Designation
- Company
- Status: Draft, Awaiting Response, Accepted, Rejected, Withdrawn
- Job Offer Term Template
- Offer Terms
- Salary
- Department
- Leaves Per Year
- Probationary Period
- Notice Period
- Applicable Modules
- Terms and Conditions
- Print Preview / PDF Output

Business rules:

- Job Offer should support predefined templates.
- HR should be able to generate a printable offer letter.
- Offer letter should include company details, candidate details, salary, terms, and policies.
- Once the offer is accepted, system should support Employee creation and onboarding initiation.

## 5. Recruitment Dashboard

Create a Recruitment Dashboard showing:

- Total Job Openings
- Open Job Openings
- Closed Job Openings
- Total Job Applicants
- Applicants by Status
- Job Applicants by Source
- Job Applicants by Job Opening
- Job Offers by Status
- Interview Status Summary
- Average Time to Fill
- Department-wise Openings
- Hiring Funnel: Application → Interview → Offer → Accepted

Use charts, counters, and list widgets.

## 6. Employee Referral

Create an Employee Referral module.

Required fields:

- Referral Name
- Full Name
- Email
- Mobile Number
- For Designation
- Status: Pending, In Process, Selected, Rejected
- Job Applicant
- Current Employee
- Referral Bonus Amount
- Is Applicable for Referral Bonus: Yes/No
- Referral Bonus Payment Status
- Additional Information

Business rules:

- An employee can refer a candidate.
- Referral should link to a Job Applicant.
- If the referred candidate is hired, referral bonus eligibility should be tracked.

## 7. Employee Master

Create an Employee master object as the central HR record.

Required sections:

1. Overview
2. User Details
3. Company Details
4. Joining
5. Address and Contacts
6. Attendance and Leaves
7. Salary
8. Personal Details
9. Profile
10. Exit
11. Connections

Required fields:

### Overview / User Details

- Employee ID
- First Name
- Middle Name
- Last Name
- Full Name
- Gender
- Date of Birth
- Date of Joining
- Status: Active, Inactive, Left, Suspended
- User ID
- Company Email
- Personal Email
- Cell Number
- Reports To
- Designation
- Department
- Branch
- Grade
- Employment Type
- Company

### Company Details

- Company
- Department
- Designation
- Branch
- Reports To
- Employee Number
- Payroll Cost Center
- Holiday List
- Default Shift

### Joining

- Offer Date
- Confirmation Date
- Contract End Date
- Date of Retirement

### Address and Contacts

- Current Address
- Permanent Address
- Personal Email
- Company Email
- Preferred Contact Email
- Emergency Contact Name
- Emergency Phone
- Relation

### Salary

- Cost to Company
- Salary Currency
- Salary Mode
- Payroll Cost Center
- PAN Number
- Provident Fund Account

### Personal Details

- Marital Status
- Blood Group
- Family Background
- Health Insurance Number
- Passport Number
- Date of Issue
- Valid Up To
- Place of Issue

### Connections

The Employee record should show related records for:

- Attendance
- Employee Check-In
- Leave Application
- Leave Policy Assignment
- Salary Structure Assignment
- Salary Slip
- Employee Onboarding
- Employee Transfer
- Employee Promotion
- Employee Separation
- Exit Interview
- Expense Claim
- Employee Advance
- Employee Benefit Claim
- Training Event
- Training Result
- Training Feedback

Business rules:

- Reports To should define employee hierarchy.
- Employee should support an organizational chart.
- Promotion and Transfer should update Employee work history.
- Employee Master should maintain history of company, department, designation, branch, and reports-to changes.

## 8. Employee Onboarding

Create Employee Onboarding functionality.

Objects:

1. Employee Onboarding Template
2. Employee Onboarding
3. Onboarding Activities / Tasks

Employee Onboarding Template fields:

- Template Name
- Designation
- Department
- Activities
- Activity Name
- Assigned To
- Begin On Day
- Duration
- Required: Yes/No

Employee Onboarding fields:

- Employee
- Job Offer
- Job Applicant
- Company
- Department
- Designation
- Date of Joining
- Status: Pending, In Process, Completed
- Onboarding Template
- Activities

Business rules:

- When Employee Onboarding is created, the system should generate projects and tasks.
- Tasks should be viewable in List View and Kanban Board.
- Kanban statuses should include Pending, In Process, and Completed.
- HR should be able to mark onboarding as complete after all required activities are completed.

## 9. Employee Promotion

Create an Employee Promotion process.

Required fields:

- Employee
- Employee Name
- Company
- Promotion Date
- Current Designation
- New Designation
- Current Department
- New Department
- Current Grade
- New Grade
- Current Branch
- New Branch
- Current Reports To
- New Reports To
- Salary Details
- Promotion Details Table
- Status: Draft, Submitted, Approved, Cancelled

Promotion Detail child table:

- Property
- Current Value
- New Value

Business rules:

- HR should be able to add employee properties to update, such as designation, department, branch, grade, reports-to, and salary.
- Once submitted, the Employee Master should be updated.
- Work history should be inserted into the Employee record.
- System should support promotion letter templates and print preview.

## 10. Employee Transfer

Create an Employee Transfer process.

Required fields:

- Employee
- Employee Name
- Company
- Transfer Date
- Current Branch
- New Branch
- Current Department
- New Department
- Current Designation
- New Designation
- Current Reports To
- New Reports To
- Transfer Details
- Status: Draft, Submitted, Approved, Cancelled

Business rules:

- Transfer should update Employee Master fields.
- Transfer should create a work history entry.
- Transfer letter template should be available.

## 11. Employee Separation / Exit

Create employee separation functionality.

Objects:

1. Employee Separation Template
2. Employee Separation
3. Employee Exit
4. Exit Interview
5. Full and Final Settlement
6. Certificate of Employment

Employee Separation Template fields:

- Template Name
- Department
- Designation
- Activities
- Activity Name
- Assigned To
- Begin On Day
- Duration
- Required

Employee Separation fields:

- Employee
- Employee Name
- Company
- Department
- Designation
- Resignation Letter Date
- Relieving Date
- Reason for Leaving
- Status: Pending, In Process, Completed, Cancelled
- Exit Checklist Activities

Employee Exit fields:

- Employee
- Employee Name
- Department
- Designation
- Date of Joining
- Resignation Date
- Relieving Date
- Exit Interview Status
- Full and Final Status
- Final Decision
- Reason for Exit
- Exit Type: Resignation, Termination, Mutual Separation, Retirement

Exit Interview fields:

- Employee
- Employee Name
- Department
- Designation
- Interview Date
- Interviewer
- Exit Questionnaire
- Employee Feedback
- Final Remarks
- Rating

Business rules:

- Separation template should create exit checklist tasks.
- HR should track exit progress using status and dashboard.
- Exit Interview should capture structured feedback.
- Certificate of Employment should be generated from the Employee record.

## 12. Full and Final Settlement

Create Full and Final Settlement functionality.

Required fields:

- Employee
- Employee Name
- Company
- Department
- Designation
- Date of Joining
- Relieving Date
- Payables
- Receivables
- Net Payable / Recoverable
- Status: Draft, Submitted, Paid, Cancelled

Payables table:

- Component
- Reference Document
- Account
- Amount
- Status

Receivables table:

- Component
- Reference Document
- Account
- Amount
- Status

Business rules:

- Settlement should calculate total payable and total receivable.
- Net amount should be calculated automatically.
- System should create accounting journal entries with debit and credit lines.
- Payroll Payable and Expense Claim records should be linkable.
- Settlement should be printable.

## 13. Leave Management

Create Leave Management module.

Objects:

1. Leave Type
2. Leave Policy
3. Leave Policy Assignment
4. Leave Application
5. Holiday List

Leave Application fields:

- Employee
- Employee Name
- Leave Type
- From Date
- To Date
- Total Leave Days
- Reason
- Status: Open, Approved, Rejected, Cancelled
- Approver
- Posting Date

Holiday List fields:

- Holiday List Name
- From Date
- To Date
- Total Holidays
- Holiday Table

Holiday child table fields:

- Date
- Day
- Description
- Weekly Off: Yes/No

Business rules:

- Leave application should validate available leave balance.
- Leave approval workflow should be supported.
- Holiday List should support adding multiple holidays.
- Weekly offs should be configurable.
- Leave balance should be visible on Employee record.

## 14. Attendance and Employee Check-In

Create Attendance and Check-In tracking.

Attendance fields:

- Employee
- Employee Name
- Attendance Date
- Status: Present, Absent, Half Day, On Leave, Work From Home
- Shift
- In Time
- Out Time
- Working Hours

Employee Check-In fields:

- Employee
- Employee Name
- Time
- Log Type: IN, OUT
- Device ID
- Location

Business rules:

- Employee Check-In records should support Attendance generation.
- Employee profile should show attendance activity.
- Attendance dashboard should show daily and monthly attendance trends.

## 15. Payroll

Create Payroll functionality.

Required objects:

1. Salary Structure
2. Salary Structure Assignment
3. Salary Slip
4. Payroll Entry

Salary Structure fields:

- Structure Name
- Company
- Currency
- Earnings
- Deductions
- Is Active

Salary Slip fields:

- Employee
- Employee Name
- Company
- Department
- Designation
- Start Date
- End Date
- Payment Days
- Earnings
- Deductions
- Gross Pay
- Net Pay
- Status: Draft, Submitted, Paid, Cancelled

Business rules:

- Salary Structure should be assigned to Employee.
- Salary Slip should calculate gross pay, deductions, and net pay.
- Payroll Entry should create salary slips in bulk.
- Payroll should integrate with Full and Final Settlement.

## 16. Expense and Advance

Create Expense Claim and Employee Advance functionality.

Expense Claim fields:

- Employee
- Employee Name
- Expense Date
- Expense Type
- Amount
- Currency
- Status: Draft, Submitted, Approved, Rejected, Paid
- Approver
- Attachments

Employee Advance fields:

- Employee
- Employee Name
- Advance Amount
- Purpose
- Posting Date
- Status: Draft, Submitted, Approved, Paid, Returned
- Paid Amount
- Claimed Amount
- Return Amount

Business rules:

- Approved expenses can be included in settlement.
- Employee advances can be recovered during settlement.

## 17. Training

Create Training Management functionality.

Objects:

1. Training Program
2. Training Event
3. Training Result
4. Training Feedback

Training Event fields:

- Training Program
- Trainer
- Start Date
- End Date
- Location
- Employees
- Status

Training Result fields:

- Employee
- Training Event
- Result
- Score
- Remarks

Training Feedback fields:

- Employee
- Training Event
- Rating
- Feedback

## 18. Dashboards and Reports

Create dashboards for:

1. Recruitment Dashboard
2. HR Dashboard
3. Payroll Dashboard
4. Employee Lifecycle Dashboard
5. Leave Dashboard
6. Attendance Dashboard
7. Exit Dashboard

Reports should include:

- Monthly Attendance Sheet
- Employee Analytics
- Employee Leave Balance
- Employee Advance Summary
- Employee Exit Report
- Employees Working on Holiday
- Daily Work Summary
- Department-wise Headcount
- Recruitment Funnel
- Job Applicant Source
- Offer Acceptance Rate
- Full and Final Settlement Summary

## 19. User Interface Requirements

The system should include:

- List views for all major objects
- Detail views with tabs and sections
- Related records / connections panel
- Kanban board for onboarding tasks
- Public job portal
- Web forms
- Print preview for offer, promotion, transfer, and settlement documents
- Dashboards with charts
- Search and filters
- Role-based access

## 20. Automation Requirements

The system should include these automations:

1. Published Job Openings should appear on the job portal.
2. Submitted Job Applications should create Job Applicant records.
3. Job Applicant should allow Interview creation.
4. Interview Feedback should calculate average rating.
5. Cleared interview should allow marking candidate as Accepted.
6. Accepted applicant should allow Job Offer creation.
7. Accepted Job Offer should allow Employee creation.
8. Employee Onboarding should create tasks/projects from template.
9. Promotion should update Employee Master and work history.
10. Transfer should update Employee Master and work history.
11. Separation should create exit checklist tasks.
12. Full and Final Settlement should calculate payables and receivables.
13. Full and Final Settlement should create journal entries.
14. Leave Application should go through approval.
15. Attendance should be generated from employee check-ins where applicable.

## 21. Access Control

Create role-based access for:

- HR Manager
- HR User
- Recruiter
- Hiring Manager
- Interviewer
- Employee
- Payroll Manager
- Finance User
- System Administrator

Access rules:

- Employees can view their own profile, leaves, attendance, salary slips, referrals, and expenses.
- Recruiters can manage job openings, applicants, interviews, and offers.
- Interviewers can view assigned interviews and submit feedback.
- HR Managers can access all HR records.
- Payroll Managers can access salary and payroll data.
- Finance Users can access expense, advance, settlement, and journal entries.

## 22. Expected Output

Create a working system specification and implementation plan with:

1. Data model
2. Objects/tables
3. Fields
4. Relationships
5. Page layouts
6. User roles
7. Workflows
8. Automations
9. Dashboards
10. Reports
11. Public job portal
12. Forms
13. Approval processes
14. Print templates
15. Implementation phases
16. Testing scenarios

The final system should behave like a full HRMS and recruitment platform with similar processes and similar fields to the provided reference document.
