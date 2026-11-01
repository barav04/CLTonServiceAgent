import { LightningElement, api } from 'lwc';

const STATUS_VARIANTS = {
    New: 'slds-theme_info',
    Working: 'slds-theme_warning',
    Escalated: 'slds-theme_error',
    Closed: 'slds-theme_success'
};

export default class CaseStatusCard extends LightningElement {
    // Populated by the Agentforce runtime with a CS_CaseStatusCard payload.
    // Enhanced Chat v2 can deliver it as a JSON string instead of an object.
    @api value;

    get card() {
        const raw = this.value;
        if (raw == null) {
            return {};
        }
        if (typeof raw === 'string') {
            try {
                return raw.trim() ? JSON.parse(raw) : {};
            } catch (e) {
                return {};
            }
        }
        return typeof raw === 'object' ? raw : {};
    }

    get caseNumber() {
        return this.card.caseNumber;
    }

    get status() {
        return this.card.status || 'Unknown';
    }

    get lastUpdated() {
        return this.card.lastUpdated;
    }

    get badgeClass() {
        const variant = STATUS_VARIANTS[this.status] || '';
        return `slds-badge ${variant}`.trim();
    }
}
