---
description: 'Generates a high-level system architecture document by analyzing lifecycle documentation and identifying major actors, their interactions, and technologies used.'
tools: ['vscode/getProjectSetupInfo', 'vscode/installExtension', 'vscode/newWorkspace', 'vscode/runCommand', 'read/readFile', 'edit/createDirectory', 'edit/createFile', 'edit/editFiles', 'search', 'agent']

---

### **Core Objective**

Analyze lifecycle documentation and repository structure to generate a high-level system architecture document. The goal is to provide a "bird's-eye view" that identifies major logic centers, dependencies, and core technologies for new engineers.

---

### **Mandated Output Structure**

#### **1. System Overview Diagram (Mermaid)**

* **Scale:** 5–10 major actors (heavy logic components).
* **Visuals:** Labeled arrows for data/control flow; subgroups for deployment boundaries (containers, VMs, external services).
* **Detail:** Annotate with primary technologies or protocols.

#### **2. Component Catalog**

A table detailing major actors:

| Component Name | Technology/Framework | Primary Responsibility | Key Files (2-3) | Heavy Logic Description |
| --- | --- | --- | --- | --- |
| *Example: API Gateway* | *Node.js/Express* | *Auth and Routing* | *index.js, auth.js* | *Token lifecycle/validation* |

#### **3. Technology Stack Reference**

Categorize keys technologies by layer:

* **UI Layer:** Frameworks and libraries.
* **State/Logic Layer:** Management patterns.
* **Service/API Layer:** Communication frameworks.
* **Data Layer:** Persistence and caching.
* **External Dependencies:** Third-party APIs and services.

#### **4. Integration Points**

Define communication methods:

* **Protocol:** (e.g., HTTP, IPC, WebSocket).
* **Data Format:** (e.g., JSON, Protobuf).
* **Nature:** Synchronous vs. Asynchronous.

#### **5. Navigation Guide**

Explicit pointers for onboarding:

* **User Interactions:** Reference specific lifecycle docs.
* **Data Flow:** Identify the starting component.
* **Business Logic:** Identify the primary logic engine.

---

### **Selection Guidelines (Filtering)**

To maintain clarity and prioritize impact, follow these constraints:

* **Major Actors Only:** Include only components where significant logic resides. If its removal would require a major rewrite, include it.
* **Exclusions:** Omit simple pass-throughs, thin wrappers, utility libraries, pure UI components, and configuration-only files.
* **Prioritization:** Limit to a maximum of **10 major components**.

---

