# 🧠 OrbitalMDT — Project Brain

> **Quick Reference**: This file tracks everything happening in the OrbitalMDT project. Read this instead of scanning all source files.

---

## 📋 Project Overview

| Field | Value |
|-------|-------|
| **Project** | OrbitalMDT — Orbital Mechanics Mission Design Toolkit |
| **Platform** | Scilab 6.x+ GUI Application |
| **Location** | `e:\GUIVerse\OrbitalMDT\` |
| **Purpose** | Professional-grade interplanetary mission design tool |
| **Target Users** | Space agencies (NASA, ESA, ISRO), rocket companies (SpaceX, Rocket Lab), aerospace engineers, university researchers |

---

## 🕐 Timeline

### Phase 1: Planning & Research (Aug 14, 2026)
- [x] Deep research on orbital mechanics problems used by space agencies
- [x] Identified core problem: **Interplanetary Transfer Mission Design**
- [x] Researched Lambert solver algorithms (Universal Variable + Stumpff functions)
- [x] Researched Porkchop plot generation workflow
- [x] Researched Scilab GUI capabilities (uicontrol, figure, callbacks)
- [x] Collected J2000 planetary ephemeris data (Mercury → Saturn)
- [x] Created implementation plan with 6 modules and 5-tab GUI
- [x] User approved the plan

### Phase 2: Core Engine Development (Aug 14, 2026)
- [x] Built `constants.sci` — All physical/astronomical constants
- [x] Built `ephemeris.sci` — Planetary position engine (J2000 mean elements)
- [x] Built `kepler.sci` — Kepler equation solver (Newton-Raphson)
- [x] Built `coordinates.sci` — Coordinate transforms (orbital → cartesian, ecliptic → equatorial)
- [x] Built `lambert.sci` — Lambert problem solver (Universal Variable formulation)
- [x] Built `hohmann.sci` — Hohmann transfer calculator
- [x] Built `propagator.sci` — Orbit propagation (2-body + J2 perturbation)
- [x] Built `porkchop.sci` — Porkchop plot contour generator
- [x] Built `bielliptic.sci` — Bi-elliptic transfer calculator
- [x] Built `rocket_equation.sci` — Tsiolkovsky rocket equation & propellant budget
- [x] Built `flyby.sci` — Gravity assist / planetary flyby calculator
- [x] Built `reentry.sci` — Atmospheric re-entry analysis
- [x] Built `rendezvous.sci` — Phasing & rendezvous maneuver calculator
- [x] Built `groundtrack.sci` — Satellite ground track computation
- [x] Built `mission_utils.sci` — Launch window, orbital lifetime, eclipse analysis

### Phase 3: GUI Development (Aug 14, 2026)
- [x] Built `gui_main.sci` — Main window with 7-tab layout
- [x] Built `gui_mission_planner.sci` — Porkchop plot + mission design tab
- [x] Built `gui_hohmann.sci` — Hohmann & bi-elliptic transfer tab
- [x] Built `gui_lambert.sci` — Direct Lambert solver tab
- [x] Built `gui_propagator.sci` — Orbit propagation + 3D viz tab
- [x] Built `gui_solarsystem.sci` — Solar system state viewer tab
- [x] Built `gui_rocket.sci` — Rocket equation & mission budget tab
- [x] Built `gui_reentry.sci` — Atmospheric re-entry analysis tab
- [x] Built `main.sce` — Application launcher

### Phase 4: Scilab 6.x Compatibility & Verification (Aug 14-15, 2026)
- [x] Converted all MATLAB-style `...` line continuations to official Scilab `..` line continuations
- [x] Replaced MATLAB `~` output ignore operators with Scilab dummy variables
- [x] Sanitized entire codebase to pure 7-bit ASCII (fixing Windows Scilab UTF-8 parser errors)
- [x] Fixed `uicontrol` property setters (`backgroundcolor`, `foregroundcolor`) in `gui_main.sci`
- [x] Added `dot(a, b)` and `cross(a, b)` vector math utilities in `constants.sci`
- [x] Added `funcprot(0);` to `main.sce` to suppress redefinition warnings
- [x] **Verified Application Launch**: Loaded all 15 core engines & 8 GUI tabs with interactive Porkchop & Lambert execution

### Phase 5: Documentation & Git Version Control (Aug 15, 2026)
- [x] Created `README.md` — Full user-facing documentation
- [x] Created `DOCUMENTATION.md` — Comprehensive technical manual (formulas, algorithms)
- [x] Created `brain.md` — Project brain & master roadmap tracking
- [x] Configured `.gitignore` — Ignore Scilab binaries, `.sod`, `.scg`, `.log`, `.bak`
- [x] Pushed code to GitHub repository: `https://github.com/anonymous-pxe/OrbitalMDT.git`


## 📁 File Map

```
OrbitalMDT/
├── main.sce                     # 🚀 Launch point — run this in Scilab
├── README.md                    # 📖 User-facing documentation
├── DOCUMENTATION.md             # 📚 Technical documentation (algorithms, formulas)
├── brain.md                     # 🧠 Project brain & roadmap tracking
│
├── core/                        # ⚙️ Computation engines (no GUI code)
│   ├── constants.sci            #    Physical constants (mu_Sun, AU, planet data)
│   ├── ephemeris.sci            #    Planet positions from J2000 elements
│   ├── kepler.sci               #    Kepler equation solver
│   ├── coordinates.sci          #    Coordinate transformations
│   ├── lambert.sci              #    Lambert problem solver
│   ├── hohmann.sci              #    Hohmann transfer calculator
│   ├── bielliptic.sci           #    Bi-elliptic transfer calculator
│   ├── propagator.sci           #    Orbit propagation (2-body + J2)
│   ├── porkchop.sci             #    Porkchop plot data generator
│   ├── rocket_equation.sci      #    Tsiolkovsky equation & mass budget
│   ├── flyby.sci                #    Gravity assist calculator
│   ├── reentry.sci              #    Atmospheric re-entry analysis
│   ├── rendezvous.sci           #    Phasing & rendezvous maneuvers
│   ├── groundtrack.sci          #    Ground track computation
│   └── mission_utils.sci        #    Launch windows, lifetime, eclipse
│
└── gui/                         # 🖥️ GUI layer (uicontrol-based)
    ├── gui_main.sci             #    Main window + tab management
    ├── gui_mission_planner.sci  #    Tab 1: Interplanetary mission planner
    ├── gui_hohmann.sci          #    Tab 2: Hohmann & bi-elliptic transfers
    ├── gui_lambert.sci          #    Tab 3: Lambert problem solver
    ├── gui_propagator.sci       #    Tab 4: Orbit propagation + 3D plot
    ├── gui_solarsystem.sci      #    Tab 5: Solar system viewer
    ├── gui_rocket.sci           #    Tab 6: Rocket equation & mass budget
    └── gui_reentry.sci          #    Tab 7: Atmospheric re-entry analysis
```

---

## 🔧 Key Algorithms

| Algorithm | File | Method | Complexity |
|-----------|------|--------|------------|
| Kepler's Equation | `kepler.sci` | Newton-Raphson iteration | O(k) where k ≈ 5-10 iterations |
| Lambert's Problem | `lambert.sci` | Universal Variable + Stumpff functions | O(k) Newton-Raphson, k ≈ 10-30 |
| Porkchop Plot | `porkchop.sci` | N×M grid of Lambert solutions | O(N×M×k) |
| Orbit Propagation | `propagator.sci` | Scilab `ode()` with RK4/RK45 | O(n_steps) |
| Gravity Assist | `flyby.sci` | Patched-conic hyperbolic flyby | O(1) analytical |
| Re-entry Analysis | `reentry.sci` | Ballistic entry + heating model | O(n_steps) |

---

## 🔑 Key Decisions

1. **Self-contained**: No external Scilab toolbox dependencies (no CelestLab required)
2. **J2000 Mean Elements**: Used for ephemeris instead of SPICE kernels (simpler, no file I/O)
3. **Universal Variable Lambert**: Chosen over Gauss/Battin methods for robustness across orbit types
4. **7 GUI Tabs**: Expanded from original 5 to include Rocket Equation and Re-entry Analysis
5. **Callback-based GUI**: Uses Scilab's `uicontrol` callback mechanism for interactivity

---

## ⚠️ Known Limitations

- Ephemeris accuracy: ±0.1° for inner planets, ±1° for outer planets (sufficient for preliminary design)
- No multi-revolution Lambert solutions (single-revolution only)
- Re-entry model is simplified (exponential atmosphere, no wind)
- No low-thrust trajectory optimization (impulsive maneuvers only)
- Porkchop plot computation can take 30-60 seconds for large grids

---

## 🎯 How to Run

```scilab
// In Scilab console:
cd("e:\GUIVerse\OrbitalMDT");
exec("main.sce", -1);
```

---

## 📊 Module Dependencies

```
constants.sci ← (used by everything)
    ↓
ephemeris.sci ← kepler.sci, coordinates.sci
    ↓
lambert.sci ← coordinates.sci
    ↓
porkchop.sci ← lambert.sci, ephemeris.sci
    ↓
hohmann.sci, bielliptic.sci ← (standalone, use constants)
propagator.sci ← coordinates.sci
flyby.sci ← (standalone)
rocket_equation.sci ← (standalone)
reentry.sci ← (standalone)
rendezvous.sci ← hohmann.sci
groundtrack.sci ← coordinates.sci
mission_utils.sci ← ephemeris.sci
```

---

## 🔮 NEXT UP: v0.2.0 Comprehensive Refactoring (Starting Aug 15, 2026)

> **Goal**: Transform OrbitalMDT from "correct algorithms" into "a coherent, numerically validated, maintainable preliminary mission-design application."
>
> **Rule**: Do NOT rebuild from scratch. Audit first, fix foundation, then refactor.

### Priority Order
1. Numerical correctness
2. Validation & testing
3. Time & coordinate/frame consistency
4. Robust error handling
5. Mission-data architecture
6. GUI integration
7. Performance
8. Visual improvements
9. New features (only if they support the above)

---

### Phase 5A: Foundation (Do First)

- [ ] **Full codebase audit** — inspect every `.sci`/`.sce` file, map dependencies, find bugs
  - [ ] Identify duplicated constants, time calcs, coordinate transforms
  - [ ] Identify GUI callbacks that contain physics calculations
  - [ ] Identify functions that silently return NaN/Inf/empty
  - [ ] Identify degree/radian inconsistencies
  - [ ] Identify frame/epoch ambiguity
  - [ ] Identify dead code
- [ ] **Create `core/time.sci`** — centralized time system
  - [ ] calendar date → JD, JD → calendar, MJD, days since J2000, seconds since epoch
  - [ ] Date validation & normalization
  - [ ] Remove duplicated date arithmetic from ephemeris.sci and elsewhere
  - [ ] Document epoch, units, time scale assumptions
- [ ] **Create `core/frames.sci`** — reference frame transformations
  - [ ] Ecliptic J2000 ↔ equatorial J2000
  - [ ] Heliocentric ↔ planet-centered
  - [ ] Keep `coordinates.sci` for math-only transforms (OE↔Cartesian, perifocal↔inertial)
  - [ ] Every function must document input/output frame, epoch, units
- [ ] **Unit standardization audit**
  - [ ] Enforce: km, km/s, seconds, radians, kg, km³/s² internally
  - [ ] Explicit conversion at all GUI boundaries (degrees→rad, days→sec, AU→km)
- [ ] **Improve `constants.sci`**
  - [ ] Organized sections: physical, astronomical, planetary μ, radii, J2, atmosphere
  - [ ] Unit comments on every constant
  - [ ] Kill all constant redefinitions in other files
- [ ] **Error handling framework**
  - [ ] Status codes: SUCCESS, INVALID_INPUT, NO_SOLUTION, NOT_CONVERGED, NUMERICAL_ERROR
  - [ ] GUI: never show raw Scilab errors, always readable messages with suggestions
  - [ ] Every major calculation returns status

---

### Phase 5B: Numerical Validation (Do Second)

- [ ] **Harden `kepler.sci`**
  - [ ] Validate eccentricity, normalize M, detect non-convergence
  - [ ] Return status struct (E, iterations, residual, converged)
  - [ ] Test: circular, low-e, moderate-e, high-e (0.9+), negative M, boundary cases
- [ ] **Overhaul `lambert.sci`** (highest priority numerical module)
  - [ ] Line-by-line audit of Universal Variable + Stumpff implementation
  - [ ] Support: short-way, long-way, near-180°, near-parabolic, hyperbolic
  - [ ] Configurable tolerance & max iterations, convergence detection
  - [ ] Return structured result: v1, v2, tof, transfer_angle, iterations, residual, converged, status
  - [ ] **Critical test**: Lambert → propagate for TOF → verify `norm(r2_reconstructed - r2) < tol`
- [ ] **Validate `ephemeris.sci`**
  - [ ] Test all 6 planets at multiple dates (near J2000, far from J2000)
  - [ ] Cross-check against JPL Horizons reference values
  - [ ] Document valid accuracy range and time window
- [ ] **Validate `propagator.sci`**
  - [ ] Test energy conservation and angular momentum conservation
  - [ ] Test orbital period accuracy for circular and elliptical orbits
  - [ ] Separate dynamics equations from integration from configuration
  - [ ] Explicit model labeling: `2BODY`, `2BODY_J2`
- [ ] **Create `tests/` directory** with automated test suite
  - [ ] `test_constants.sce`
  - [ ] `test_time.sce`
  - [ ] `test_kepler.sce`
  - [ ] `test_coordinates.sce`
  - [ ] `test_frames.sce`
  - [ ] `test_ephemeris.sce`
  - [ ] `test_lambert.sce`
  - [ ] `test_propagator.sce`
  - [ ] `test_transfers.sce`
  - [ ] `run_all_tests.sce` — outputs PASS/FAIL with readable summary

---

### Phase 5C: Integration & Polish (Do Third)

- [ ] **Create `app/app_state.sci`** — centralized mission state
  - [ ] Shared data: departurePlanet, arrivalPlanet, dates, trajectory, ΔV, C₃, status
  - [ ] All GUI tabs operate on shared mission data (not isolated)
- [ ] **Refactor porkchop** — separate calculation from plotting
  - [ ] Result struct: departure_dates, arrival_dates, tof, dv grids, convergence flags
  - [ ] Track failed/converged cells, don't corrupt grid with invalid data
  - [ ] Progress indicator for long computations
- [ ] **Mission Planner → central workflow**
  - [ ] Flow: select planets → dates → porkchop → select solution → Lambert → propagate → analyze
  - [ ] "Open in Lambert" button, "Propagate" button — auto-fills data, no manual copying
- [ ] **Inter-tab data flow**
  - [ ] Mission Planner → Lambert → Propagator → Rocket/Mass Budget
  - [ ] Selecting a porkchop solution auto-loads into Lambert tab
  - [ ] Lambert result auto-available for propagation
  - [ ] ΔV results auto-available for mass budget
- [ ] **Numerical status in GUI**
  - [ ] Show convergence info: "Lambert ✓ Converged, 8 iterations, residual 2.1e-9 km"
  - [ ] Show model disclaimers: "⚠ Simplified J2000 mean-element ephemeris"
- [ ] **Mission summary panel** — show all key results in one place
- [ ] **Module-specific improvements**
  - [ ] `flyby.sci` — clearly separate planet-relative vs heliocentric quantities
  - [ ] `rocket_equation.sci` — integrate with mission ΔV (auto-transfer from planner)
  - [ ] `reentry.sci` — label as "preliminary ballistic model", add dynamic pressure output
  - [ ] `groundtrack.sci` — validate Earth rotation assumptions
  - [ ] `solarsystem viewer` — use actual mission trajectory data, show spacecraft path
- [ ] **Performance** (after correctness)
  - [ ] Cache repeated ephemeris states
  - [ ] Precompute date grids
  - [ ] Separate computation from GUI redraws
- [ ] **Documentation updates**
  - [ ] Update README.md, DOCUMENTATION.md, brain.md
  - [ ] Create CHANGELOG.md
  - [ ] Document architecture, units, frames, tolerances, limitations
  - [ ] Use "preliminary mission design" terminology, never "flight-certified"
- [ ] **Version**: Tag as `OrbitalMDT v0.1.0` (current), target `v0.2.0` after refactoring

---

### New Files to Create in v0.2.0

```
OrbitalMDT/
├── core/
│   ├── time.sci              # [NEW] Centralized time system
│   └── frames.sci            # [NEW] Reference frame transforms
├── app/
│   └── app_state.sci         # [NEW] Centralized mission state
├── tests/
│   ├── test_constants.sce    # [NEW]
│   ├── test_time.sce         # [NEW]
│   ├── test_kepler.sce       # [NEW]
│   ├── test_coordinates.sce  # [NEW]
│   ├── test_frames.sce       # [NEW]
│   ├── test_ephemeris.sce    # [NEW]
│   ├── test_lambert.sce      # [NEW]
│   ├── test_propagator.sce   # [NEW]
│   ├── test_transfers.sce    # [NEW]
│   └── run_all_tests.sce     # [NEW] Test runner
└── CHANGELOG.md              # [NEW]
```

---

### Known Issues to Fix in v0.2.0

| Issue | File | Severity |
|-------|------|----------|
| Lambert can silently diverge on edge geometries | `lambert.sci` | 🔴 Critical |
| No validation tests exist | — | 🔴 Critical |
| `date_to_jd()` lives in ephemeris, not centralized | `ephemeris.sci` | 🟡 Medium |
| GUI callbacks contain physics calculations | `gui_*.sci` | 🟡 Medium |
| Degree/radian conversion not always explicit | multiple | 🟡 Medium |
| No frame labeling on vector outputs | `coordinates.sci` | 🟡 Medium |
| Porkchop computation coupled to plotting | `porkchop.sci` | 🟡 Medium |
| Tabs are isolated — no shared mission data | `gui_*.sci` | 🟡 Medium |
| No progress indicator for long computations | `gui_mission_planner.sci` | 🟢 Low |
| No CHANGELOG | — | 🟢 Low |
