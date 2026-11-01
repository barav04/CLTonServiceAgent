import { LightningElement, api } from "lwc";

const PAGE_SIZE = 5;

const STATUS_VARIANTS = {
  New: "slds-theme_info",
  Working: "slds-theme_warning",
  Escalated: "slds-theme_error",
  Closed: "slds-theme_success"
};

export default class CaseStatusCard extends LightningElement {
  // Populated by the Agentforce runtime with a CS_CaseStatusCard payload.
  // Enhanced Chat v2 can deliver it as a JSON string instead of an object.
  @api value;

  // null until the user types, so the payload's searchTerm is used as the initial value.
  typedSearch = null;
  pageIndex = 0;

  get card() {
    const raw = this.value;
    if (raw == null) {
      return {};
    }
    if (typeof raw === "string") {
      try {
        return raw.trim() ? JSON.parse(raw) : {};
      } catch {
        return {};
      }
    }
    return typeof raw === "object" ? raw : {};
  }

  get allCases() {
    const card = this.card;
    if (typeof card.casesJson === "string") {
      try {
        const parsed = JSON.parse(card.casesJson);
        return Array.isArray(parsed) ? parsed : [];
      } catch {
        return [];
      }
    }
    if (Array.isArray(card.cases)) {
      return card.cases;
    }
    // Older single-case payloads (caseNumber/status/lastUpdated at the top level).
    return card.caseNumber ? [card] : [];
  }

  get searchTerm() {
    return this.typedSearch ?? this.card.searchTerm ?? "";
  }

  get filteredCases() {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.allCases;
    }
    return this.allCases.filter((c) =>
      (c.caseNumber || "").toLowerCase().includes(term)
    );
  }

  get totalCount() {
    return this.allCases.length;
  }

  get pageCount() {
    return Math.max(1, Math.ceil(this.filteredCases.length / PAGE_SIZE));
  }

  get currentPage() {
    return Math.min(this.pageIndex, this.pageCount - 1);
  }

  get visibleCases() {
    const start = this.currentPage * PAGE_SIZE;
    return this.filteredCases.slice(start, start + PAGE_SIZE).map((c) => ({
      ...c,
      status: c.status || "Unknown",
      badgeClass: `slds-badge ${STATUS_VARIANTS[c.status] || ""}`.trim()
    }));
  }

  get hasResults() {
    return this.filteredCases.length > 0;
  }

  get showControls() {
    return this.totalCount > 1;
  }

  get pageLabel() {
    return `Page ${this.currentPage + 1} of ${this.pageCount}`;
  }

  get rangeLabel() {
    const count = this.filteredCases.length;
    const start = this.currentPage * PAGE_SIZE;
    return `${start + 1}–${Math.min(start + PAGE_SIZE, count)} of ${count}`;
  }

  get isFirstPage() {
    return this.currentPage === 0;
  }

  get isLastPage() {
    return this.currentPage >= this.pageCount - 1;
  }

  handleSearch(event) {
    this.typedSearch = event.target.value || "";
    this.pageIndex = 0;
  }

  handlePrevious() {
    this.pageIndex = Math.max(0, this.currentPage - 1);
  }

  handleNext() {
    this.pageIndex = Math.min(this.pageCount - 1, this.currentPage + 1);
  }
}
