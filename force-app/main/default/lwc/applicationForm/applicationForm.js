import { LightningElement, track } from "lwc";

import submitApplication from "@salesforce/apex/ApplicationFormController.submitApplication";

export default class ApplicationForm extends LightningElement {
  defaultApplication = {
    companyName: "",
    federalTaxId: "",
    contact: {
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
    },
    annualRevenue: null,
  };

  @track application = {
    ...this.defaultApplication,
    contact: {
      ...this.defaultApplication.contact,
    },
  };

  isLoading = false;

  message = "";
  isSuccess = false;
  result;

  handleChange(event) {
    const field = event.target.dataset.field;
    const value = event.target.value;

    if (field.startsWith("contact.")) {
      const contactField = field.split(".")[1];

      this.application = {
        ...this.application,

        contact: {
          ...this.application.contact,

          [contactField]: value,
        },
      };
    } else {
      this.application = {
        ...this.application,

        [field]: value,
      };
    }
  }

  async handleSubmit() {

    if (this.isLoading) {
        return;
    }
    // Validate all inputs

    const allValid = [
      ...this.template.querySelectorAll("lightning-input"),
    ].reduce((validSoFar, input) => {
      input.reportValidity();

      return validSoFar && input.checkValidity();
    }, true);

    if (!allValid) {
      return;
    }

    this.isLoading = true;

    this.message = "";
    this.result = null;
    this.isSuccess = false;

    try {
      const result = await submitApplication({
        input: JSON.stringify(this.application),
      });

      this.result = result;

      this.message = result.message;
      this.isSuccess = result.success;

      // Reset form
      if (this.isSuccess) {
        this.application = {
          ...this.defaultApplication,

          contact: {
            ...this.defaultApplication.contact,
          },
        };
      }
    } catch (error) {
      this.message = error.body?.message || "An unexpected error occurred.";

      this.isSuccess = false;
    } finally {
      this.isLoading = false;
    }
  }
}