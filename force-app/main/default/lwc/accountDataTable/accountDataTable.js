import { LightningElement, api, track, wire } from 'lwc';
import getAccountsData from '@salesforce/apex/AccountLWCHandler.getAccountsData';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: "Contact Id", fieldName: "Id", type: "Id" ,  displayReadOnlyIcon: true, hidedefaultactions: true},
    { label: "First Name", fieldName: "FirstName", editable: true ,  hidedefaultactions: true},
    { label: "Last Name", fieldName: "LastName", editable: true ,  hidedefaultactions: true },
    { label: "Phone", fieldName: "Phone", editable: true ,  hidedefaultactions: true},
    { label: "Email", fieldName: "Email", editable: true ,  hidedefaultactions: true },
];

export default class AccountDataTable extends LightningElement {
    @api recordId;
    @track draftvalues = [];
    columns = columns;
    contactsResult; // to store wire result object
    contactData = [];

    @wire(getAccountsData, { accountId: '$recordId' })
    wiredContacts(result) {
        this.contactsResult = result;
        if (result.data) {
            this.contactData = result.data;
        } else if (result.error) {
            console.error('Wire error:', result.error);
        }
    }

    async handleSave(event) {
        const records = event.detail.draftValues.map(draft => ({ fields: { ...draft } }));
        this.draftvalues = [];

        try {
            await Promise.all(records.map(updateRecord));
            await refreshApex(this.contactsResult); 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Contacts updated",
                    variant: "success"
                })
            );
        } catch (error) {
            console.error('Update error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Error Updating Contacts",
                    variant: "error"
                })
            );
        }
    }
}
