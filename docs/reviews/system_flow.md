# PWChrono HRMS — System Flow

This document captures end-to-end project flows in Mermaid so diagrams remain version-controlled and reviewable in pull requests.

## 1) High-level platform flow

```mermaid
flowchart TD
    U[End User] --> LWC[LWC UI Layer]
    LWC --> APEX[Apex Controllers]
    APEX --> OBJ[Salesforce Objects]
    APEX --> EXT[External Providers]
    EXT --> APEX
    OBJ --> RPT[Reports & Dashboards]
```

## 2) Delivery lifecycle flow

```mermaid
flowchart LR
    DEV[Feature Development] --> QA[Quality Gate\nLint + Tests + Format + Docs]
    QA --> PR[Pull Request]
    PR --> RVW[Code Review]
    RVW --> DEPLOY[Deploy to Org]
    DEPLOY --> VERIFY[Post-Deploy Validation]
```

## 3) Request-to-status reporting flow

```mermaid
flowchart TD
    REQ[Business Request] --> ANALYZE[Impact Analysis]
    ANALYZE --> BUILD[Implementation]
    BUILD --> TEST[Test & Review]
    TEST --> RELEASE[Release]
    RELEASE --> STATUS[Status Report Update]
    STATUS --> REQ
```

## Notes

- Keep node labels short and business-friendly.
- Prefer one diagram per concern (architecture, delivery, reporting).
- Update this file when adding/removing major LWC modules, Apex controllers, or process stages.
