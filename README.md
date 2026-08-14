# 🚀 OrbitalMDT — Orbital Mechanics Mission Design Toolkit

> **Professional-grade interactive Scilab application for interplanetary mission design, orbital analysis, and spacecraft trajectory planning.**

[![Platform](https://img.shields.io/badge/Platform-Scilab%206.x-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)]()

---

## Overview

OrbitalMDT is a comprehensive orbital mechanics analysis suite built entirely in Scilab. It provides the same fundamental computational tools used by space agencies (NASA, ESA, ISRO) and rocket companies (SpaceX, Rocket Lab) for mission design — packaged in an interactive GUI with 7 specialized analysis tabs.

### Key Problem Solved
**Interplanetary Transfer Mission Design** — from computing optimal launch windows using Porkchop plots, to solving Lambert's boundary-value problem, to analyzing atmospheric re-entry conditions.

---

## 🖥️ Quick Start

```scilab
// In Scilab 6.x console:
cd("e:\GUIVerse\OrbitalMDT");
exec("main.sce", -1);
```

The application will load all modules and launch the interactive GUI.

---

## 📋 Features

### Tab 1: Mission Planner (Porkchop Plot Generator)
- Select departure/arrival planets (Mercury → Saturn)
- Define date ranges for departure and arrival windows
- Generate ΔV contour maps (Porkchop plots)
- Automatically find optimal launch windows
- Display C₃, V∞, and time-of-flight
- Show synodic period and future launch windows

### Tab 2: Orbital Transfers
- **Hohmann Transfer**: Classical two-impulse minimum-energy transfer
- **Bi-Elliptic Transfer**: Three-impulse maneuver (better for r₂/r₁ > 11.94)
- Quick presets: LEO→GEO, LEO→Moon, Earth→Mars, Earth→Jupiter
- Visual orbit diagram with transfer ellipse
- Automatic comparison between Hohmann and bi-elliptic

### Tab 3: Lambert Problem Solver
- Solve the fundamental astrodynamics boundary-value problem
- Input: two position vectors + time of flight → output: velocity vectors
- Multiple central bodies (Earth, Sun, Mars, Moon)
- Prograde and retrograde solutions
- 3D orbit visualization

### Tab 4: Orbit Propagator
- Numerical orbit propagation using Scilab's `ode()` integrator
- Two-body gravity + optional J2 perturbation (Earth oblateness)
- Presets: ISS, GPS, GEO, Molniya, Sun-Synchronous
- 5 plot types: 3D orbit, ground track, altitude, velocity, elements vs time
- Orbital parameter analysis (period, apoapsis, periapsis, energy)

### Tab 5: Solar System Viewer
- Real-time planet positions at any date using J2000 ephemeris
- Inner planets, outer planets, or full system views
- Distance calculations (AU and light-minutes) from Earth
- Sphere of influence calculator for all planets
- Orbit path overlay

### Tab 6: Rocket Equation & Mass Budget
- Tsiolkovsky rocket equation solver
- Engine presets: Merlin 1D, Raptor, RS-25, RL-10, Ion, NERVA
- Mission ΔV presets: LEO, GEO, Moon, Mars, Venus, Jupiter
- Complete mass budget breakdown (payload, propellant, initial mass)
- Visual bar chart of mass distribution

### Tab 7: Atmospheric Re-Entry Analysis
- Ballistic entry trajectory simulation
- Peak g-loading and deceleration altitude
- Stagnation-point heat flux (Sutton-Graves model)
- Vehicle presets: Apollo CM, Soyuz, Crew Dragon, Curiosity MSL, Stardust
- Earth and Mars atmospheric models
- Velocity, g-loading, and heat flux profile plots

---

## 📁 Project Structure

```
OrbitalMDT/
├── main.sce                     ← Run this to launch
├── README.md                    ← This file
├── DOCUMENTATION.md             ← Full technical documentation
│
├── core/                        ← Computation engines
│   ├── constants.sci            Physical constants & planet data
│   ├── kepler.sci               Kepler equation solver
│   ├── coordinates.sci          Coordinate transformations
│   ├── ephemeris.sci            Planetary ephemeris (J2000)
│   ├── lambert.sci              Lambert problem solver
│   ├── hohmann.sci              Hohmann transfer calculator
│   ├── bielliptic.sci           Bi-elliptic transfer
│   ├── propagator.sci           Orbit propagation (2-body + J2)
│   ├── porkchop.sci             Porkchop plot generator
│   ├── rocket_equation.sci      Tsiolkovsky equation
│   ├── flyby.sci                Gravity assist calculator
│   ├── reentry.sci              Atmospheric re-entry
│   ├── rendezvous.sci           Phasing maneuvers
│   ├── groundtrack.sci          Ground track computation
│   └── mission_utils.sci        Launch windows, lifetime, eclipse
│
└── gui/                         ← Interactive GUI
    ├── gui_main.sci             Main window & tabs
    ├── gui_mission_planner.sci  Tab 1: Porkchop plots
    ├── gui_hohmann.sci          Tab 2: Transfers
    ├── gui_lambert.sci          Tab 3: Lambert solver
    ├── gui_propagator.sci       Tab 4: Propagation
    ├── gui_solarsystem.sci      Tab 5: Solar system
    ├── gui_rocket.sci           Tab 6: Rocket equation
    └── gui_reentry.sci          Tab 7: Re-entry
```

---

## 🔧 Command-Line API

All core functions can be used directly from the Scilab console without the GUI:

```scilab
// Load all modules
exec("main.sce", -1);

// --- Hohmann Transfer: LEO to GEO ---
result = hohmann_transfer(6571, 42164, 398600.4418);
disp(result.dv_total);  // ≈ 3.94 km/s

// --- Planet Position ---
JD = date_to_jd(2028, 7, 1);
[r_mars, v_mars] = planet_state_heliocentric(4, JD);

// --- Lambert Problem ---
r1 = [5000; 10000; 2100];
r2 = [-14600; 2500; 7000];
[v1, v2, ok] = lambert_solver(r1, r2, 3600, 398600.4418);

// --- Rocket Equation ---
result = rocket_equation(9.4, 350, 5000);  // dv=9.4 km/s, Isp=350s, 5000 kg payload
disp(result.m_propellant);  // Propellant mass needed

// --- Orbit Propagation ---
[r0, v0] = orbital_elements_to_state(6771, 0.001, 51.6*%pi/180, 0, 0, 0, 398600.4418);
[t, states] = propagate_orbit(r0, v0, [0, 5400], 398600.4418);

// --- Re-Entry Analysis ---
result = ballistic_entry(11.0, -6.5, 120, 370e6, 4.69, "Earth");
disp(result.g_loading);  // Peak g-load

// --- Gravity Assist ---
v_inf = [3; 0; 0];  // 3 km/s approach
v_planet = [0; 13.07; 0];  // Venus velocity
result = gravity_assist(v_inf, v_planet, 324859, 6251, 6051.8);
```

---

## 📊 Core Algorithms

| Algorithm | Method | Reference |
|-----------|--------|-----------|
| Kepler's Equation | Newton-Raphson iteration | Bate, Mueller & White |
| Lambert's Problem | Universal Variable + Stumpff functions | Curtis, Ch. 5 |
| Orbit Propagation | Scilab `ode()` (RK45 adaptive) | Numerical Methods |
| Porkchop Plots | N×M Lambert grid search | JPL mission design |
| Planetary Ephemeris | J2000 mean elements + centennial rates | Standish (1992) |
| Re-Entry Heating | Sutton-Graves correlation | Allen & Eggers |
| Gravity Assist | Patched-conic hyperbolic flyby | Battin |

---

## ⚙️ System Requirements

- **Scilab 6.0+** (tested on 6.1.1 and 2024.1.0)
- No external toolboxes required (fully self-contained)
- **OS**: Windows, Linux, or macOS
- **RAM**: 512 MB minimum (2 GB recommended for large porkchop grids)

---

## 📖 References

1. Curtis, H.D. "Orbital Mechanics for Engineering Students" (4th ed.)
2. Bate, R.R., Mueller, D.D., White, J.E. "Fundamentals of Astrodynamics"
3. Battin, R.H. "An Introduction to the Mathematics and Methods of Astrodynamics"
4. Vallado, D.A. "Fundamentals of Astrodynamics and Applications"
5. JPL Solar System Dynamics: https://ssd.jpl.nasa.gov/

---

## 📄 License

This project is provided for educational and professional use. See DOCUMENTATION.md for detailed technical specifications.

---

*Built with Scilab — Free and Open Source Software for Numerical Computation*
