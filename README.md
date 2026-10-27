# EcoRoute AI

EcoRoute AI is a research prototype for carbon- and energy-aware Software-Defined Networking (SDN) routing. It combines an interactive web dashboard, a small route-selection demo, an RDF knowledge graph, SNDlib-compatible benchmark inputs, and three offline research experiments.

The dashboard is a prototype: modeled energy and emissions are not physical power measurements, telemetry is simulated unless the separate Ryu collector is connected, and fallback carbon values are illustrative scenarios rather than observations.

## Contents

- [Features](#features)
- [Quick start on Windows](#quick-start-on-windows)
- [Quick start on macOS or Linux](#quick-start-on-macos-or-linux)
- [Dashboard guide](#dashboard-guide)
- [Routing and energy model](#routing-and-energy-model)
- [Research experiments](#research-experiments)
- [Carbon data and Electricity Maps](#carbon-data-and-electricity-maps)
- [Knowledge graph](#knowledge-graph)
- [API routes](#api-routes)
- [Tests and command-line tools](#tests-and-command-line-tools)
- [Optional Mininet and Ryu emulation](#optional-mininet-and-ryu-emulation)
- [Project layout](#project-layout)
- [Limitations and interpretation](#limitations-and-interpretation)
- [Troubleshooting](#troubleshooting)

## Features

- **Sidebar navigation:** Routing, SNDlib WAN topologies, E1, E2, E3, Statistical Rigor, telemetry, knowledge graph, and regional carbon pages/tools.
- **Interactive route demo:** A six-node topology, shortest-hop and carbon-aware path comparison, weight controls, SLA limit, and route recomputation.
- **Network visualization:** Local SVG topology with hosts, switches, links, latency, and selected paths.
- **Telemetry demo:** Idle and active simulated traffic readings with port throughput and utilization.
- **Regional carbon panel:** Live Electricity Maps values for the configured routing regions when a key is set; otherwise labeled fallback scenarios. The CSV contains 15 country rows plus three internal routing-region rows.
- **Visual knowledge graph:** Selectable host, switch, link, region, and carbon-intensity nodes. The API builds graph entities from the application topology and carbon client, and reports the populated RDF graph triple count.
- **Research pages:** Interactive SVG charts, local experiment figures, formula cards, result tables, forecast error metrics, and statistical confidence intervals.
- **Light and dark themes.**

## Quick start on Windows

Open PowerShell in the repository root. The virtual environment keeps the project packages separate from system Python.

```powershell
py -3 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt numpy scipy pandas
.\.venv\Scripts\python.exe web\server.py 8050
```

Keep the server terminal open. Visit **http://127.0.0.1:8050/** in a browser. Do not open `web/index.html` directly: the dashboard fetches its data from the local API served by Python.

To stop the server, press `Ctrl+C` in its terminal. If port 8050 is already occupied, choose another port, for example `8051`, and open `http://127.0.0.1:8051/`. After code changes, restart the server and hard-refresh the page (`Ctrl+F5`) so the browser loads the latest JavaScript and styles.

## Quick start on macOS or Linux

From the repository root:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt numpy scipy pandas
.venv/bin/python web/server.py 8050
```

Then open **http://127.0.0.1:8050/**. The server uses Python's standard-library HTTP server; no separate Node build or frontend server is required. `package.json` includes convenience `start`/`dev` scripts, but Node is not needed to serve the dashboard.

### Requirements

- Python 3.11 or newer is recommended.
- `requirements.txt` installs the base routing, graph, HTTP, plotting, and test packages.
- NumPy and SciPy are required by the research experiments and statistical routines; pandas is needed if the server must regenerate the E2 significance report from its raw CSV.
- The browser uses local HTML, CSS, JavaScript, and SVG assets. Google Fonts are an optional external font enhancement; the page has system-font fallbacks.

## Dashboard guide

### Routing

The demo uses hosts `h1` and `h2`, switches `s1` through `s4`, and North/South path alternatives. Adjust energy (`alpha`), carbon (`beta`), and latency (`gamma`) weights, set the maximum latency, and select **Recompute Routes**. Presets set common weight profiles. The comparison table reports path, latency, carbon intensity, modeled power, and SLA status.

### SNDlib WAN topologies

Choose Abilene or GÉANT to view the benchmark topology. Select nodes to inspect topology metadata and connected links. The dashboard's WAN view uses the bundled benchmark node and link definitions; the research tools also parse the SNDlib-compatible XML inputs.

### E1 — Upper-Bound Gate

E1 compares shortest-hop routing with a perfect-foresight carbon-aware oracle on GÉANT across 0%, 50%, and 80% idle-power-share scenarios. The configured decision rule checks whether the 50% scenario reaches a 2% reduction.

The saved result currently reports a 2.3304% reduction at 50% idle share, so the stored decision passes the 2% gate. At 0% idle share it reports 11.7072%; at 80% idle share it reports 0.8864%. These are modeled results from the checked-in analysis file, not live measurements. The page plots the saved baseline/oracle totals and reduction values and displays the local figure assets.

Formula:

```text
reduction (%) = 100 × (baseline emissions − carbon-aware emissions) / baseline emissions
```

### E2 — Forecast-Aware Traffic Engineering

E2 evaluates routing policies on the Abilene benchmark input over 24 time steps. It includes shortest-hop, latency-aware, reactive, AR(4) forecast policies, forecast-noise scenarios, and perfect foresight. The page presents policy emissions/reductions, route churn, solver time, maximum link utilization, forecast-noise sensitivity, and the result table.

The checked-in AR(4) forecast report has 264 evaluation samples, MAE 22.346 gCO₂/kWh, RMSE 26.814 gCO₂/kWh, and MAPE 10.34%. These metrics are loaded from the saved experiment output; the dashboard does not invent evaluation scores.

Formulae:

```text
MAE  = mean(|actual − forecast|)
RMSE = sqrt(mean((actual − forecast)²))
MAPE = 100 × mean(|(actual − forecast) / actual|)
reduction (%) = 100 × (shortest-hop emissions − policy emissions) / shortest-hop emissions
```

MAPE can be undefined or unstable when actual values are zero or close to zero; interpret it with MAE/RMSE and the evaluation context.

### E3 — Limits and Link Sleep

E3 shows the saved latency/emissions frontier, no-sleep versus EEE sleep emissions at several idle shares, and regional carbon-divergence scenarios. It illustrates that sleeping idle links can reduce modeled power, while route latency, capacity, and detours constrain feasible savings. The saved frontier contains latency multipliers from 1.0× through 5.0×. Hop-count deltas are not recorded in the current result file, so the dashboard does not report a numeric extra-hop result.

The experiment sets sleep-state transceiver power to 15% of idle transceiver power. Results are modeled, not measurements of hardware.

```text
path latency = sum(link latency along the route)
path must satisfy: latency ≤ SLA bound
link flow must satisfy: flow ≤ link capacity
modeled network power = active-link power + sleep-link power + switch power
sleep-state link power = 0.15 × idle transceiver power
```

### Statistical Rigor

The page includes the E1 and E2 mean-reduction confidence-interval charts and the E2 policy statistics table. It reports paired t-tests, Wilcoxon signed-rank tests, bootstrap intervals, p-values, and Cohen's d where present in the result files. Statistical significance is not an effect-size measure; read the interval, effect size, and test assumptions together.

The E1 report uses a 95% moving-block bootstrap (block size 4) in its saved report. E2's saved report uses its configured bootstrap analysis. The API can regenerate E2 statistics from `e2_raw_results.csv` if the cached report is missing; this path needs pandas.

### Telemetry, knowledge graph, and carbon tools

- **Telemetry:** The dashboard switch toggles a deterministic simulated idle/active traffic fixture. It is not a live Mininet or switch feed by default.
- **Knowledge Graph:** Select nodes to inspect their type, capacity, latency, regional carbon intensity, properties, and connected relationships. SPARQL remains available in the backend endpoint.
- **Regional Carbon:** Each card labels a live API result or a synthetic fallback scenario, with units, source, and timestamp where available. The fallback rows are explicitly not real-time readings.

## Routing and energy model

The small interactive routing demo retains a hop-count baseline and a carbon-aware Dijkstra-style route evaluator. The carbon-aware score combines normalized energy, carbon intensity, and latency:

```text
w(link) = alpha × normalized_energy
        + beta  × normalized_carbon_intensity
        + gamma × normalized_latency
```

The route evaluator rejects paths that exceed the SLA latency bound. The normalized weights are controlled by the dashboard sliders. The hard latency bound remains in force regardless of the weight settings.

The power model estimates chassis, port, transceiver, and traffic-dependent power. For idle-share sensitivity experiments, a simplified form is:

```text
P = P_reference × (idle_share + (1 − idle_share) × load_fraction)
```

Emissions are estimated as energy multiplied by the applicable carbon intensity:

```text
emissions (gCO₂eq) = energy (kWh) × carbon intensity (gCO₂eq/kWh)
```

The baseline is a hop-count proxy. This prototype does not run a production OSPF control plane, perform physical power metering, or control device sleep states on real hardware.

## Research experiments

Experiment modules live under `ecoroute/experiments/`; the dashboard reads saved JSON/CSV outputs under `results/`.

| Experiment | Focus | Main saved outputs |
|---|---|---|
| E1 Upper-Bound Gate | GÉANT, idle power shares 0/50/80%, oracle versus shortest-hop, 2% gate | `results/e1_upper_bound/e1_analysis.json`, raw CSV, summary CSV, figures |
| E2 Forecast-Aware TE | Abilene, AR(4), policy comparison, forecast error/noise, churn and utilization | `results/e2_forecast_routing/e2_analysis.json`, forecast accuracy JSON, stats JSON, raw/summary CSV, figures |
| E3 Sensitivity and Link Sleep | Idle shares, EEE sleep, latency frontier, spatial carbon divergence | `results/e3_sensitivity/e3_analysis.json` and figures |
| Statistical evaluation | Paired policy comparisons, confidence intervals, p-values, effect size | `results/statistical_evaluation_report.json` and E2 `stats_report.json` |

The checked-in Abilene/GÉANT topology XML is benchmark-format input. Traffic matrices and research carbon-intensity sequences are generated or derived for reproducible offline evaluation; they should not be described as current measured traffic or live grid data. Result timestamps and checksums are included in the JSON where available.

To regenerate the existing experiment outputs, run from the repository root:

```bash
python -m ecoroute.experiments.e1_upper_bound
python -m ecoroute.experiments.e2_forecast_routing
python -m ecoroute.experiments.e3_sensitivity_and_limits
```

These commands can overwrite files under `results/`. The dashboards can be run without regenerating them as long as the saved result JSON files remain present.

## Carbon data and Electricity Maps

The live client uses Electricity Maps v4 latest carbon intensity for the three configured routing regions (Germany/DE, Poland/PL, and Sweden/SE). Set either `ELECTRICITY_MAPS_API_KEY` or the legacy `ELECTRICITY_MAPS_TOKEN` before starting the server.

PowerShell:

```powershell
$env:ELECTRICITY_MAPS_API_KEY = "YOUR_API_KEY"
.\.venv\Scripts\python.exe web\server.py 8050
```

macOS/Linux:

```bash
export ELECTRICITY_MAPS_API_KEY="YOUR_API_KEY"
.venv/bin/python web/server.py 8050
```

The key is sent in the request's `auth-token` header. The client uses the `/v4/carbon-intensity/latest` endpoint, displays the returned zone, timestamp/update metadata and estimated flag, and attributes live values to Electricity Maps. A failed or unavailable live request falls back to the local CSV and is labeled as fallback data.

`carbon/sample_carbon_data.csv` contains 15 country-code rows (DE, PL, SE, FR, NO, DK, GB, NL, ES, IT, FI, CH, AT, BE, CZ) and three internal route-region aliases (`Region-Hub`, `Region-North`, `Region-South`). Values are synthetic illustrative scenarios; source and dataset timestamp are shown in the dashboard. Only the configured routing regions make live API requests. The other country cards remain CSV fallback scenarios even when an API key is configured.

The CSV field `carbon_intensity_gco2_per_kwh` specifies the units. `data_source` identifies the scenario source, and `timestamp` is the scenario dataset timestamp; it is not a claim that these are live readings.

The local PNG/SVG research illustrations are under `web/assets/research/`. The experiment runners also save their original analysis figures in their respective `results/` directories.

Electricity Maps documentation: [authorization](https://app.electricitymaps.com/docs/quickstart/authorization) · [latest carbon intensity endpoint](https://app.electricitymaps.com/docs/reference/carbon-intensity/latest).

## Knowledge graph

The visual graph is assembled from the current application network topology and the regional carbon client. Node types include hosts, switches, link entities, regions, and carbon-intensity records. Relationship edges represent link endpoints, switch location, and region-to-carbon-intensity association. Selecting a node shows its available properties and connected relationships.

The backend also populates an in-memory RDFLib graph from application data. SPARQL query execution remains available through `POST /api/sparql` for:

1. High-carbon links (threshold configurable; default 250 gCO₂/kWh).
2. Switch regional inventory.
3. Low-carbon links (100 gCO₂/kWh threshold).

The browser presents the visual graph as the primary knowledge-graph view; SPARQL source is not required to use it.

## API routes

The Python server serves the static dashboard and its JSON API on the same origin.

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/overview` | Application topology and regional carbon data |
| POST | `/api/compute_routes` | Recompute baseline and carbon-aware routes from weights and SLA |
| GET | `/api/telemetry?mode=idle` or `?mode=active` | Simulated telemetry readings |
| GET | `/api/carbon` | Configured route regions plus fallback country cards |
| GET | `/api/knowledge-graph` | Graph nodes, relationships, properties, and RDF triple count |
| POST | `/api/sparql` | Run one of the backend SPARQL query choices |
| GET | `/api/research/e1` | Saved E1 analysis JSON |
| GET | `/api/research/e2` | Saved E2 policy summary and metadata |
| GET | `/api/research/e3` | Saved E3 analysis JSON |
| GET | `/api/research/stats` | E2 statistics plus available E1 interval data |
| GET | `/api/research/topologies` | Abilene and GÉANT topology data for the WAN view |

Example SPARQL request:

```json
{"query_id": 1, "threshold": 250}
```

`query_id` is 1 (high-carbon links), 2 (switch/region inventory), or 3 (low-carbon links). The response contains result rows and the selected query title; the dashboard's knowledge-graph view does not require sending a SPARQL request.

## Tests and command-line tools

Install the packages above, then run the test suite from the repository root:

```bash
python -m pytest tests -v
```

Useful standalone commands:

```bash
# Route comparison demo
python experiments/compare_routes.py

# Knowledge-graph SPARQL query demo
python knowledge_graph/queries.py

# Simulated telemetry table
python telemetry/collector.py

# Rebuild benchmark-format topology/traffic inputs if needed
python -m ecoroute.data.benchmarks
```

The separate `TelemetryCollector.collect_network_telemetry()` can poll a running Ryu REST endpoint at `http://127.0.0.1:8080`; the dashboard API currently serves its deterministic simulated telemetry fixture instead.

## Optional Mininet and Ryu emulation

The web dashboard and research experiments run without Mininet. Full SDN emulation is optional and requires Linux (including a suitable WSL2 setup), Open vSwitch, Mininet, and a Ryu-compatible controller installation. It is not required for the dashboard's simulated route/telemetry views.

A typical Linux setup uses the repository's setup script:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh
```

Then, in separate terminals:

```bash
ryu-manager controller/ryu_app.py ryu.app.ofctl_rest
sudo python3 topo/topology.py
python3 telemetry/collector.py
```

The collector polls Ryu's `/stats/port/<dpid>` endpoint. Inside Mininet, `pingall` checks host reachability and `iperf h1 h2` can generate traffic. Validate the exact Ryu/Mininet versions for the host OS; this optional path is separate from the web dashboard workflow.

## Project layout

```text
web/                       Python dashboard server, HTML, CSS, JavaScript, local chart assets
routing/                   Hop-count baseline and carbon-aware route evaluator
energy_model/              Small prototype's modeled power calculations
carbon/                    Electricity Maps client and labeled fallback CSV
telemetry/                 Ryu REST collector and simulated telemetry fixture
knowledge_graph/            RDFLib ontology and SPARQL query helpers
topo/                       Six-node application topology and optional Mininet topology
controller/                 Optional Ryu controller

ecoroute/data/              SNDlib-compatible parser, benchmark topology and traffic inputs
ecoroute/models/            Research power/emissions models
ecoroute/forecasting/       Forecast models and evaluation metrics
ecoroute/optimization/      Capacity-constrained multi-commodity-flow LP

ecoroute/experiments/       E1, E2, and E3 experiment runners
ecoroute/evaluation/        Statistical methods
results/                    Saved experimental data, analysis JSON/CSV, and figures
data/sndlib/                Topology XML and time-indexed traffic-matrix XML
tests/                      Unit and research regression tests
```

## Troubleshooting

- **The page is blank or still shows old content:** start the server from the repository root, keep its terminal open, and hard-refresh the browser. Restart Python after changing backend code. Do not launch the page as a `file://` URL.
- **`ModuleNotFoundError` on startup:** install the packages in the quick-start instructions using the same Python interpreter used to launch `web/server.py`.
- **Port is already in use:** stop the old server with `Ctrl+C`, or start another port such as `8051` and open that port in the browser.
- **Knowledge graph does not load:** open `http://127.0.0.1:8050/api/knowledge-graph` (replace the port if needed). A successful response has `status: "success"`, `nodes`, `edges`, and `triple_count`. Check the server terminal for Python errors.
- **Research charts report unavailable data:** confirm the corresponding saved JSON exists under `results/e1_upper_bound/`, `results/e2_forecast_routing/`, or `results/e3_sensitivity/`. Run the matching experiment module to regenerate missing outputs.
- **Live carbon values are absent:** confirm the API key is set in the same terminal before starting the server. The dashboard falls back to clearly labeled CSV scenarios if the key is missing or the request fails.
- **Live carbon values appear slow:** the server performs external API requests for the configured regions. Without network access, values fall back to the CSV after the request timeout.

## Limitations and interpretation

- Power, energy, and carbon emissions in the routing and research evaluations are modeled estimates.
- The dashboard's idle/active telemetry switch is simulated. Live switch telemetry requires the optional Ryu collector path.
- The live Electricity Maps path is limited to the configured DE/PL/SE routing regions. Additional country cards use synthetic CSV scenarios.
- The research carbon series and generated traffic traces are offline experimental inputs, not current measurements.
- A perfect-foresight result is an oracle upper bound; it is not a deployable forecast policy.
- Statistical significance depends on the evaluated samples, pairing, tests, and assumptions. A non-significant result is not proof of no effect.
- The prototype does not provide a production-grade SDN controller, a real OSPF implementation, physical power metering, or real equipment sleep control.
