# EcoRoute AI: Future Work and Out-of-Scope Roadmap

This document clearly outlines capabilities, architectures, and algorithms that are **explicitly out of scope for the 25% prototype milestone** and reserved for future development phases.

In accordance with strict research integrity and transparent milestone reporting, none of these components are fabricated, faked, or claimed as currently active in this 25% milestone codebase.

---

## Explicitly Out-of-Scope Items (Reserved for Future Milestones)

### 1. Dynamic OSPF via Quagga / FRRouting (FRR)
- **Current 25% Status:** A centralized hop-count shortest path routing algorithm in `routing/baseline.py` and `controller/ryu_app.py` acts as the unweighted OSPF baseline proxy.
- **Future Milestone:** Integration of real dynamic routing protocol suites (FRRouting / Zebra / Quagga) running OSPFv2/OSPFv3 routing daemons inside Mininet host network namespaces with OpenFlow-OSPF hybrid peering.

### 2. Spatio-Temporal Graph Neural Network (GNN) Traffic Prediction
- **Current 25% Status:** Real-time port/flow stats collection and link utilization calculations from OpenFlow counters in `telemetry/collector.py`.
- **Future Milestone:** A spatio-temporal GNN (such as A3T-GCN or STGCN) to forecast link traffic volumes and impending congestion across varying diurnal network traffic profiles prior to path computation.

### 3. Multi-Agent Reinforcement Learning (MARL / MAPPO / CTDE)
- **Current 25% Status:** Multi-objective modified Dijkstra with static edge weights normalized across energy, carbon, and latency with SLA constraint pruning (`routing/carbon_aware.py`).
- **Future Milestone:** Multi-Agent Proximal Policy Optimization (MAPPO) with Centralized Training and Decentralized Execution (CTDE) to optimize autonomous flow distribution under non-stationary traffic and fluctuating grid conditions.

### 4. Digital Twin Simulation-Before-Deployment Layer
- **Current 25% Status:** Mininet emulation with Open vSwitch and NetworkX graph models.
- **Future Milestone:** A high-fidelity virtual network digital twin executing shadow verification of flow path modifications before rule commit into physical SDN flow tables.

### 5. LLM-Based Network Intent Parsing & ChatOps
- **Current 25% Status:** Configuration via declarative `config.yaml` parameters (`alpha`, `beta`, `gamma`, `sla_max_latency_ms`).
- **Future Milestone:** Natural language network intent compilation (e.g. translating "minimize carbon footprint for bulk backup traffic between 02:00 and 06:00 without exceeding 40ms latency" into reactive SDN flow rules).

### 6. Federated Learning Across Autonomous Domains
- **Current 25% Status:** Centralized telemetry collector querying a single controller instance.
- **Future Milestone:** Privacy-preserving federated model training across multiple regional network operators (autonomous systems) without sharing private transit traffic volumes.

### 7. Real Hardware Power Measurement
- **Current 25% Status:** Config-driven synthetic power models (`energy_model/model.py`) based on idle base-load and marginal per-Gbps dynamic draw. All figures are explicitly labeled as `"modeled"`.
- **Future Milestone:** Integration with physical power distribution units (iPDUs), RAPL (Running Average Power Limit), or IPMI energy telemetry on real physical switches and servers.

### 8. Explainable AI (XAI / SHAP) Interpretability
- **Current 25% Status:** Direct mathematical inspection of composite weights and SPARQL ontology query records.
- **Future Milestone:** SHAP (SHapley Additive exPlanations) attribution to decompose why specific routing decisions were taken by neural models.
