# BulkContactReports

Allows our users to upload a file of up to 500 external IDs to Salesforce and create identical task records for matching contacts.

## Business case

We have a custom record type of the Task object called Contact Reports, which users create to record interactions with contacts. These can be entered on the per-contact basis natively through Salesforce. However, there are cases where our users want to create these records in bulk, based on the university ID, and they want to be able to do this themselves.

## Solution

This code extends Salesforce to meet our business case with a multi-step import and record creation process. This is exposed via a tab to select users. 
