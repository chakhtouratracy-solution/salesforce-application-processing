# Salesforce External Application Processing Solution

## Overview

This project implements a Salesforce application intake solution that allows external partners to submit applications through two different channels:

1. Public Experience Cloud site using a Lightning Web Component (LWC) form.
2. Public REST API webhook endpoint receiving JSON payloads from external systems.

Both entry points use the same Apex business service to ensure consistent processing logic and avoid duplicated business rules.

---

# Demo Access

The public application submission form is available through the Experience Cloud site:

```
https://orgfarm-ee15bc1143-dev-ed.develop.my.site.com/applicationform
```

External users can access the form without Salesforce credentials and submit applications through the public LWC form.

---

# Business Logic

When an application is submitted:

- The system searches for an existing Account:

  - First by Federal Tax ID.
  - If Federal Tax ID is not provided, by exact Account Name match.

- If a matching Account exists:

  - An Opportunity is created.

- If no matching Account exists:

  - A Lead is created.

All application submissions are processed through the shared `ApplicationProcessingService` Apex class to ensure the same logic is applied regardless of the submission channel.

---

# Components

## Apex Classes

- `ApplicationDTO`

  - Wrapper class representing application input data.

- `ApplicationResult`

  - Wrapper class returning processing results.

- `ApplicationFormController`

  - Apex controller used by the Experience Cloud Lightning Web Component.

- `ApplicationWebhook`

  - Public REST endpoint receiving external application submissions.

- `ApplicationProcessingService`

  - Shared business logic responsible for:
    - Account matching.
    - Lead creation.
    - Opportunity creation.
    - Application source handling.

- `ApplicationProcessingServiceTest`

  - Apex test class covering Lead and Opportunity creation scenarios.

---

# Lightning Web Component

Component:

```
applicationForm
```

Responsibilities:

- Display application fields.
- Validate required inputs.
- Call Apex controller.
- Display loading state.
- Display success and error messages.
- Submit applications from the public Experience Cloud site.

---

# Salesforce Configuration

The solution includes the following Salesforce metadata:

- Custom fields.
- Custom labels.
- Apex classes.
- Lightning Web Component.
- Experience Cloud configuration.
- REST API endpoint.

---

# Custom Labels

The solution uses Salesforce Custom Labels for configurable values and messages instead of hardcoding values inside Apex or Lightning components.

Custom Labels can be managed from:

```
Setup → Custom Labels
```

Benefits:

- Easier maintenance.
- Supports future translations.
- Allows administrators to update messages without changing code.

---

# Data Model

The solution uses standard Salesforce objects with custom fields.

---

## Lead

Custom Fields:

### `Federal_Tax_Id__c`

- Stores the applicant Federal Tax ID.

### `Application_Source__c`

Picklist values:

- Community
- Webhook

---

## Account

Custom Field:

### `Federal_Tax_Id__c`

- Stores the Account Federal Tax ID.
- Configured as **Unique** to ensure each Federal Tax ID belongs to only one Account.

---

## Opportunity

Custom Field:

### `Application_Source__c`

Picklist values:

- Community
- Webhook

---

# Deployment Instructions

## Prerequisites

- Salesforce Developer Org or Sandbox.
- Salesforce CLI installed.
- Authorized Salesforce org.

---

## Deploy Metadata

From the project root:

```bash
sf project deploy start
```

---

# Run Apex Tests

Run:

```bash
sf apex run test --tests ApplicationProcessingServiceTest --result-format human
```

The test class covers:

- Lead creation when no Account matches.
- Opportunity creation using Federal Tax ID matching.
- Opportunity creation using Account Name matching.
- Application source values from Community and Webhook submissions.

---

# Experience Cloud Configuration

## Setup Steps

1. Enable Digital Experiences.

2. Create an Experience Cloud site.

3. Add the `applicationForm` Lightning Web Component to a public page.

4. Publish the site.

5. Configure Guest User permissions:

   - Enable access to required Apex classes.
   - Provide required object permissions.
   - Provide required field-level permissions.

6. Configure the public URL.

---

## Public Application Form URL

After publishing the Experience Cloud site, the application form can be accessed using:

```
https://orgfarm-ee15bc1143-dev-ed.develop.my.site.com/applicationform
```

The form does not require Salesforce authentication and can be accessed by external users.

---

# REST API

## Endpoint

```
POST /services/apexrest/external/applications
```

---

## Example Request

```json
{
    "companyName": "Acme Corp",
    "federalTaxId": "BG123456789",
    "contact": {
        "firstName": "Ivan",
        "lastName": "Ivanov",
        "email": "ivan@example.com",
        "phone": "+359888123456"
    },
    "annualRevenue": 500000
}
```

---

## Example Successful Response

```json
{
    "success": true,
    "recordType": "Opportunity",
    "recordId": "006XXXXXXXXXXXX",
    "message": "Application processed successfully"
}
```

---

# Assumptions

- Federal Tax ID is considered a unique identifier for Accounts.
- Account matching is performed using:

  1. Federal Tax ID when available.
  2. Exact Account Name when Federal Tax ID is blank.

- Duplicate Account Federal Tax IDs are prevented through Salesforce field uniqueness.
- No attachment download or processing is required for this exercise.
- Authentication/security hardening for the public webhook would be added in a production implementation.

---

# Future Improvements

For a production implementation, additional improvements could include:

- API authentication using OAuth/JWT.
- CRUD/FLS validation.
- Duplicate management rules.
- Asynchronous processing for high-volume integrations.
- Enhanced logging and monitoring.
- Platform Events for event-driven processing.
- Custom error logging object for failed submissions.

---