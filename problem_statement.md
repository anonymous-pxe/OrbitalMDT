# 🚀 Problem Statement & Engineering Solution Architecture

<div align="center">

```
  ██████╗ ██████╗ ██████╗ ██╗████████╗ █████╗ ██╗     ███╗   ███╗██████╗ ████████╗
 ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝██╔══██╗██║     ████╗ ████║██╔══██╗╚══██╔══╝
 ██║   ██║██████╔╝██████╔╝██║   ██║   ███████║██║     ██╔████╔██║██║  ██║   ██║   
 ██║   ██║██╔══██╗██╔══██╗██║   ██║   ██╔══██║██║     ██║╚██╔╝██║██║  ██║   ██║   
 ╚██████╔╝██║  ██║██████╔╝██║   ██║   ██║  ██║███████╗██║ ╚═╝ ██║██████╔╝   ██║   
  ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═════╝    ╚═╝   
```

### *OrbitalMDT: Orbital Mechanics & Mission Design Toolkit*
**FOSSEE Scilab GUIVerse Hackathon Submission — IIT Bombay**

[![Theme](https://img.shields.io/badge/Theme-Science%20%26%20Engineering%20Simulators-orange.svg?style=for-the-badge)]()
[![Platform](https://img.shields.io/badge/Platform-Native%20Scilab%206.x%20%2F%202024.x%20%2F%202025.x-blue.svg?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-MIT%20%2F%20CC--BY--SA-green.svg?style=for-the-badge)]()

---

</div>

## 📑 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Domain Context & Problem Definition](#2-domain-context--problem-definition)
   - 2.1 The Multidisciplinary Nature of Space Mission Design
   - 2.2 The Educational & Software Gap
   - 2.3 Challenges in Existing Open-Source Tools
3. [Project Vision & Strategic Objectives](#3-project-vision--strategic-objectives)
4. [The OrbitalMDT Engineering Solution](#4-the-orbitalmdt-engineering-solution)
   - 4.1 System Architecture & Layered Design
   - 4.2 Inter-Tab Mission State Data Pipeline
   - 4.3 Interactive GUI Workbench Capabilities
5. [Core Domain Features & Capability Matrix](#5-core-domain-features--capability-matrix)
6. [Educational & Practical Impact](#6-educational--practical-impact)
7. [Compliance & Engineering Standards](#7-compliance--engineering-standards)

---

## 1. Executive Summary

Space mission design requires analyzing coupled nonlinear physical phenomena across multiple flight phases: interplanetary launch window optimization, orbital maneuver selection, numerical perturbation propagation, rocket vehicle sizing, and atmospheric re-entry. 

Historically, aerospace students and researchers face a sharp dichotomy: either rely on **expensive, proprietary commercial software** (e.g., AGI STK, FreeFlyer) that act as "black boxes" obscuring core physics, or write **isolated 1D scripts** that lack visual feedback, user interactivity, and automated data transfer between mission phases.

**OrbitalMDT (Orbital Mechanics & Mission Design Toolkit)** addresses this challenge by providing a **unified, interactive 7-tab GUI mission design workbench** built natively in **Scilab**. Designed for the **FOSSEE Scilab GUIVerse Hackathon**, OrbitalMDT pairs **19 decoupled numerical engines** with a **centralized mission state manager** and a **23-suite verification framework (100% pass rate)**, providing a zero-dependency, open-source astrodynamics software environment.

---

## 2. Domain Context & Problem Definition

### 2.1 The Multidisciplinary Nature of Space Mission Design
Preliminary space mission engineering requires solving coupled boundary-value problems across distinct physical regimes:

```
  ┌─────────────────────────┐      ┌─────────────────────────┐
  │ Interplanetary Trajectory│      │    Orbital Maneuvers    │
  │ (Porkchop & Lambert 3D) │      │  (Hohmann & Bi-elliptic)│
  └────────────┬────────────┘      └────────────┬────────────┘
               │                                │
               ▼                                ▼
  ┌─────────────────────────┐      ┌─────────────────────────┐
  │ Perturbed Orbit Dynamics│      │    Launch Vehicle Sizing│
  │ (Adams ODE + Earth J2)  │      │ (Tsiolkovsky Staging)   │
  └────────────┬────────────┘      └────────────┬────────────┘
               │                                │
               └────────────────┬───────────────┘
                                │
                                ▼
                   ┌─────────────────────────┐
                   │ Atmospheric Re-Entry    │
                   │ (Allen-Eggers & Heating)│
                   └─────────────────────────┘
```

1. **Trajectory Optimization**: Multi-month launch window searches require evaluating thousands of Lambert orbital arcs driven by planetary ephemerides to minimize departure energy ($C_3$) and total $\Delta V$.
2. **Orbital Maneuvers**: Choosing between 2-burn Hohmann and 3-burn Bi-elliptic transfers based on radius ratio efficiency criteria ($r_2/r_1 > 11.9387$).
3. **Perturbation Propagation**: Predicting orbital node regression, satellite lifetime, and sub-satellite ground tracks under Earth $J_2$ dynamic oblateness.
4. **Rocket Sizing**: Translating velocity increments ($\Delta V$) into multi-stage propellant mass budgets using the ideal Tsiolkovsky equation.
5. **Atmospheric Entry**: Predicting deceleration peak $g$-loads and Sutton-Graves stagnation-point convective heat flux during atmospheric entry.

### 2.2 The Educational & Software Gap
- **High Cost & Closed Code**: Commercial tools are cost-prohibitive for academic institutions and hide mathematical formulations inside compiled binaries.
- **Fragmented Codebases**: Standard academic scripts are typically static 1D routines written for single assignments. Students cannot pass optimal trajectory solutions directly into vehicle mass budget models or 3D visualizers.
- **Lack of GUI Tools in Pure Scilab**: While Scilab provides scientific computation capabilities, open-source astrodynamics toolkits with multi-tab GUI architectures, interactive parameter exploration, and real-time visualization have been absent.

### 2.3 Challenges in Existing Open-Source Tools
Existing introductory scripts suffer from key limitations:
- Hardcoded inputs requiring code modification for every parameter change.
- Absence of real-time error checking, allowing invalid numeric inputs (`NaN`, `Inf`, subterranean orbits) to crash calculations.
- No integrated plotting safety, causing consecutive runs to overwrite figures or corrupt GUI layouts.

---

## 3. Project Vision & Strategic Objectives

OrbitalMDT was engineered to achieve five core objectives:

| Objective | Engineering Strategy |
|---|---|
| **1. Universal Accessibility** | Built 100% in native Scilab (`.sci` / `.sce`) with **zero third-party toolbox dependencies** for cross-platform portability. |
| **2. Interactive Exploration** | Developed a 7-tab GUI with color-coded accent themes, responsive layout geometry, and $\ge 6$ distinct native `uicontrol` component types. |
| **3. Integrated Dataflow** | Implemented a global mission state manager (`app/app_state.sci`) enabling one-click data transfer from trajectory optimization to 3D solvers and rocket sizing. |
| **4. Rigorous V&V** | Created an automated test suite of 17 unit tests, 4 integration workflows, and 10 analytical reference benchmarks (Curtis 2014 & Bate 1971) achieving a 100% PASS rate. |
| **5. Robust Hardening** | Integrated input sanitization (`gui_get_num`, `gui_get_positive_num`) and `try/catch` exception boundaries across all GUI callbacks. |

---

## 4. The OrbitalMDT Engineering Solution

### 4.1 System Architecture & Layered Design

OrbitalMDT enforces a strict **3-Layer Decoupled Software Architecture**:

```
 ┌─────────────────────────────────────────────────────────────────┐
 │                   PRESENTATION LAYER (gui/*.sci)                 │
 │  7-Tab GUI Workbench, User Callbacks, Plots, Error Dialogs       │
 └────────────────────────────────┬────────────────────────────────┘
                                  │
                                  ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │                APPLICATION STATE LAYER (app/*.sci)              │
 │  Central Mission Store: dep/arr states, r1/r2, TOF, Delta-V     │
 └────────────────────────────────┬────────────────────────────────┘
                                  │
                                  ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │              NUMERICAL ENGINE LAYER (core/*.sci)                │
 │  19 Pure Math Engines: Lambert, Kepler, ODE, Ephemeris, etc.    │
 └─────────────────────────────────────────────────────────────────┘
```

### 4.2 Inter-Tab Mission State Data Pipeline
When a user computes an interplanetary Porkchop plot in Tab 1, the optimal departure/arrival dates, state vectors $\mathbf{r}_1, \mathbf{r}_2$, transfer velocities $\mathbf{v}_1, \mathbf{v}_2$, $C_3$, and total $\Delta V$ automatically populate the central mission state:
- In **Tab 3 (Lambert Solver)**: Clicking `Load from Mission State` automatically populates the exact 3D Cartesian position vectors and Time of Flight.
- In **Tab 6 (Rocket Equation)**: Clicking `Load from Mission State` automatically imports the mission $\Delta V$ requirement into the rocket sizing tool.

---

## 5. Core Domain Features & Capability Matrix

| Module | Core Mathematical Capabilities | Interactive GUI Features |
|---|---|---|
| **Mission Planner** | Standish (1992) ephemeris, Universal Variable Lambert solver, grid search min-$\Delta V$ optimization. | 2D Porkchop contour map, TOF lines, optimal star marker ($\star$), CSV itinerary export. |
| **Orbital Transfers** | Coplanar 2-burn Hohmann & 3-burn Bi-elliptic transfer engines, efficiency ratio ($r_2/r_1 > 11.94$). | True-scale 2D dual-arc orbit visualization, impulse burn markers, 6 presets. |
| **Lambert Solver** | Universal Variable Stumpff formulation, damped Newton-Raphson, prograde/retrograde arcs. | 3D ECI trajectory plot, orbital elements ($a, e, i, \Omega, \omega, \nu$), one-click state sync. |
| **Orbit Propagator** | Adams numerical ODE integrator, Earth $J_2$ dynamic oblateness perturbation, ground tracks. | 3D orbit trajectory, 2D cylindrical world map with Date Line wrapping, parameter time histories. |
| **Solar System** | Analytical ephemerides for Mercury through Saturn, Laplace Sphere of Influence (SOI). | 2D/3D heliocentric solar system viewer, planet markers, distance & light-travel time readouts. |
| **Rocket Sizing** | Ideal Tsiolkovsky equation, single & multi-stage mass budgeting, propellant fractions. | Dry payload vs propellant mass bar chart, 7 engine presets, one-click $\Delta V$ import. |
| **Re-Entry Analysis** | 1D Allen-Eggers ballistic entry, Sutton-Graves convective stagnation heat flux. | Peak $g$-load altitude, heat flux profiles, dynamic pressure graphs, human tolerability rating. |

---

## 6. Educational & Practical Impact

1. **Interactive Pedagogical Workbench**: Allows educators and students to visualize complex orbital concepts (e.g., bi-elliptic efficiency transitions, ground track node regression, entry thermal environments) in real time.
2. **Open-Science Transparency**: Full disclosure of mathematical formulations, reference citations, and AI development transparency statement.
3. **Headless Scripting Capabilities**: All 19 calculation engines operate independently of the GUI for use in automated computational scripts.

---

## 7. Compliance & Engineering Standards

- **Scilab Version Compatibility**: Tested and verified on Scilab 6.0.x, 6.1.x, 2024.0.x, 2024.1.x, and 2025.0.x.
- **Dependencies**: 100% pure native Scilab with **zero external toolboxes**.
- **Licensing**: Released under the open-source **MIT License** and **CC-BY-SA 4.0**.
- **Hackathon Alignment**: Designed specifically for the **FOSSEE Scilab GUIVerse Hackathon (IIT Bombay)** under the *Science & Engineering Simulators* category.
