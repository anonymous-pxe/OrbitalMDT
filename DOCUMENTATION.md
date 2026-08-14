# 📚 OrbitalMDT — Technical Documentation

> Complete technical reference for all algorithms, formulas, and modules.

---

## Table of Contents

1. [Physical Constants](#1-physical-constants)
2. [Kepler Equation Solver](#2-kepler-equation-solver)
3. [Coordinate Transformations](#3-coordinate-transformations)
4. [Planetary Ephemeris Engine](#4-planetary-ephemeris-engine)
5. [Lambert Problem Solver](#5-lambert-problem-solver)
6. [Hohmann Transfer Calculator](#6-hohmann-transfer-calculator)
7. [Bi-Elliptic Transfer](#7-bi-elliptic-transfer)
8. [Orbit Propagator](#8-orbit-propagator)
9. [Porkchop Plot Generator](#9-porkchop-plot-generator)
10. [Tsiolkovsky Rocket Equation](#10-tsiolkovsky-rocket-equation)
11. [Gravity Assist Calculator](#11-gravity-assist-calculator)
12. [Atmospheric Re-Entry Analysis](#12-atmospheric-re-entry-analysis)
13. [Rendezvous & Phasing](#13-rendezvous--phasing)
14. [Ground Track Computation](#14-ground-track-computation)
15. [Mission Utilities](#15-mission-utilities)
16. [GUI Architecture](#16-gui-architecture)
17. [Validation & Testing](#17-validation--testing)

---

## 1. Physical Constants

File: `core/constants.sci`

All physical and astronomical constants are centralized in a single function `orbital_constants()` that returns a struct. This ensures consistency across all modules.

### Key Constants

| Constant | Symbol | Value | Unit |
|----------|--------|-------|------|
| Gravitational constant | G | 6.67430×10⁻²⁰ | km³/(kg·s²) |
| Sun μ | μ☉ | 1.32712×10¹¹ | km³/s² |
| Earth μ | μ⊕ | 3.98600×10⁵ | km³/s² |
| Mars μ | μ♂ | 4.28284×10⁴ | km³/s² |
| Earth radius | R⊕ | 6378.137 | km |
| Earth J₂ | J₂ | 1.08263×10⁻³ | — |
| 1 AU | AU | 149,597,870.7 | km |

### Unit Convention
- **Distances**: kilometers (km)
- **Velocities**: km/s
- **Time**: seconds (s)
- **Angles**: radians internally, degrees in GUI
- **Mass**: kilograms (kg)

---

## 2. Kepler Equation Solver

File: `core/kepler.sci`

### Problem Statement
Given mean anomaly M and eccentricity e, find eccentric anomaly E satisfying:

**Elliptic (e < 1):**
```
M = E - e·sin(E)
```

**Hyperbolic (e > 1):**
```
M = e·sinh(H) - H
```

### Algorithm: Newton-Raphson

```
E_{n+1} = E_n - f(E_n) / f'(E_n)
```

where:
- f(E) = E - e·sin(E) - M
- f'(E) = 1 - e·cos(E)

**Initial guess**: E₀ = M + e/2 (if M < π) or E₀ = M - e/2 (if M ≥ π)
**Convergence**: |ΔE| < 10⁻¹⁰ (typically 5-10 iterations)

### Functions
- `solve_kepler(M, e, tol)` → E (eccentric/hyperbolic anomaly)
- `eccentric_to_true(E, e)` → ν (true anomaly)
- `true_to_mean(ν, e)` → M (mean anomaly)

---

## 3. Coordinate Transformations

File: `core/coordinates.sci`

### Orbital Elements → State Vector

Given classical orbital elements (a, e, i, Ω, ω, ν) and μ:

1. **Semi-latus rectum**: p = a(1 - e²)
2. **Radius**: r = p / (1 + e·cos(ν))
3. **Perifocal position**: r_PQW = [r·cos(ν), r·sin(ν), 0]ᵀ
4. **Perifocal velocity**: v_PQW = √(μ/p) · [-sin(ν), e+cos(ν), 0]ᵀ
5. **Rotation matrix** R(Ω, i, ω) — 3-1-3 Euler rotation
6. **Inertial state**: r = R · r_PQW, v = R · v_PQW

### State Vector → Orbital Elements

Given r and v vectors:
1. **Angular momentum**: h = r × v
2. **Node vector**: n = K × h
3. **Eccentricity vector**: e = (1/μ)[(v² - μ/r)r - (r·v)v]
4. **Semi-major axis**: a = -μ / (2·ε) where ε = v²/2 - μ/r
5. **Inclination**: i = arccos(h_z / |h|)
6. **RAAN**: Ω = arccos(n_x / |n|)
7. **Argument of periapsis**: ω = arccos(n·e / |n||e|)
8. **True anomaly**: ν = arccos(e·r / |e||r|)

### Additional Functions
- `ecliptic_to_equatorial(r_ecl)` — rotate by obliquity ε = 23.4393°
- `eci_to_geodetic(r, t, ω_earth)` — ECI to lat/lon/alt
- `circular_velocity(μ, r)` — v_circ = √(μ/r)
- `escape_velocity(μ, r)` — v_esc = √(2μ/r)
- `orbital_period(a, μ)` — T = 2π√(a³/μ)

---

## 4. Planetary Ephemeris Engine

File: `core/ephemeris.sci`

### Method: J2000 Mean Orbital Elements

For each planet, we store base elements at J2000 epoch and linear rates per century:

```
element(T) = element₀ + rate × T
```

where T = (JD - 2451545.0) / 36525 is Julian centuries from J2000.

### Elements Computed
| Symbol | Meaning |
|--------|---------|
| a | Semi-major axis [AU] |
| e | Eccentricity |
| i | Inclination [°] |
| Ω | Longitude of ascending node [°] |
| ϖ | Longitude of perihelion [°] |
| L | Mean longitude [°] |

### Derived Quantities
- Argument of perihelion: ω = ϖ - Ω
- Mean anomaly: M = L - ϖ

### Julian Date Conversion
```
JD = floor(365.25(Y+4716)) + floor(30.6001(M+1)) + D + h/24 + B - 1524.5
```

### Accuracy
- Inner planets: ±0.1° over ±50 years from J2000
- Outer planets: ±0.5° (gas giants accumulate perturbation errors)
- For higher accuracy, use JPL HORIZONS or SPICE kernels

---

## 5. Lambert Problem Solver

File: `core/lambert.sci`

### Problem Statement
Given two position vectors **r₁** and **r₂**, time of flight Δt, and gravitational parameter μ, find the orbit connecting them (i.e., determine **v₁** and **v₂**).

### Algorithm: Universal Variable Formulation

#### Step 1: Transfer Angle
```
cos(Δν) = r₁·r₂ / (|r₁|·|r₂|)
A = sin(Δν) · √(r₁·r₂ / (1 - cos(Δν)))
```

#### Step 2: Stumpff Functions
```
C(z) = (1 - cos(√z)) / z       for z > 0 (elliptic)
C(z) = (cosh(√(-z)) - 1) / (-z)  for z < 0 (hyperbolic)

S(z) = (√z - sin(√z)) / (√z)³   for z > 0
S(z) = (sinh(√(-z)) - √(-z)) / (√(-z))³  for z < 0
```

#### Step 3: Newton-Raphson Iteration
Find z such that:
```
F(z) = [y(z)/C(z)]^(3/2) · S(z) + A·√y(z) - √μ · Δt = 0
```

where y(z) = r₁ + r₂ + A(z·S - 1)/√C

#### Step 4: Lagrange Coefficients
```
f = 1 - y/r₁
g = A · √(y/μ)
ġ = 1 - y/r₂
```

#### Step 5: Velocities
```
v₁ = (r₂ - f·r₁) / g
v₂ = (ġ·r₂ - r₁) / g
```

### Convergence
- Tolerance: |F| < 10⁻⁸
- Maximum iterations: 5000
- Uses bisection fallback for robustness

---

## 6. Hohmann Transfer Calculator

File: `core/hohmann.sci`

### Formulas

Transfer semi-major axis:
```
a_t = (r₁ + r₂) / 2
```

Transfer eccentricity:
```
e_t = |r₂ - r₁| / (r₁ + r₂)
```

Delta-V burns:
```
ΔV₁ = √(μ(2/r₁ - 1/a_t)) - √(μ/r₁)     (periapsis burn)
ΔV₂ = √(μ/r₂) - √(μ(2/r₂ - 1/a_t))      (apoapsis burn)
```

Transfer time:
```
t_transfer = π · √(a_t³/μ)
```

### With Parking Orbit
For departure from a parking orbit of radius r_park:
```
v_∞ = ΔV₁_Hohmann (hyperbolic excess velocity)
v_hyp = √(v_∞² + 2μ_planet/r_park)
ΔV_actual = v_hyp - √(μ_planet/r_park)
```

---

## 7. Bi-Elliptic Transfer

File: `core/bielliptic.sci`

Three-burn transfer via an intermediate radius r_int:

```
ΔV₁ = |v_t1_peri - v_circ1|   (enter first transfer ellipse)
ΔV₂ = |v_t2_apo - v_t1_apo|   (transition at intermediate point)
ΔV₃ = |v_circ2 - v_t2_peri|   (circularize at target)
```

**More efficient than Hohmann when r₂/r₁ > 11.94** (critical ratio).

---

## 8. Orbit Propagator

File: `core/propagator.sci`

### Equations of Motion

**Two-body:**
```
r̈ = -(μ/r³) · r
```

**Two-body + J₂:**
```
r̈ = -(μ/r³)·r + a_J2
```

where:
```
a_J2_x = (3/2)·J₂·μ·R²/r⁵ · x · (5z²/r² - 1)
a_J2_y = (3/2)·J₂·μ·R²/r⁵ · y · (5z²/r² - 1)
a_J2_z = (3/2)·J₂·μ·R²/r⁵ · z · (5z²/r² - 3)
```

### Integration
Uses Scilab's `ode()` function with default RK45 adaptive stepping.

---

## 9. Porkchop Plot Generator

File: `core/porkchop.sci`

### Algorithm
1. Create N×M grid of (departure_date, arrival_date) pairs
2. For each pair:
   a. Compute planet positions via ephemeris
   b. Solve Lambert's problem for the transfer
   c. Compute ΔV = |v_transfer - v_planet| at both ends
   d. Store total ΔV and C₃ = v_∞²
3. Generate contour plot of ΔV(departure, arrival)
4. Find minimum ΔV point (optimal window)

### Time-of-Flight Isolines
Diagonal lines at constant TOF (100, 200, 300, 400, 500 days) overlay the contour.

---

## 10. Tsiolkovsky Rocket Equation

File: `core/rocket_equation.sci`

### Fundamental Equation
```
ΔV = v_e · ln(m₀/m_f)
```

where:
- v_e = I_sp · g₀ (exhaust velocity)
- m₀ = initial mass
- m_f = final mass (payload + structure)

### Mass Ratio
```
MR = m₀/m_f = exp(ΔV/v_e)
m_propellant = m_payload · (MR - 1)
```

### Pre-computed Mission ΔV Budgets
| Mission | Total ΔV (km/s) |
|---------|----------------|
| LEO | 9.4 |
| GEO | 13.34 |
| Moon Landing | 15.22 |
| Mars Landing | 14.7 |
| Venus Orbit | 13.8 |
| Jupiter Orbit | 17.7 |

---

## 11. Gravity Assist Calculator

File: `core/flyby.sci`

### Turn Angle
```
δ = 2 · arcsin(1 / (1 + r_p·v_∞²/μ_planet))
```

### Hyperbola Parameters
```
e_hyp = 1 + r_p·v_∞²/μ
a_hyp = -μ/v_∞²
b = |a_hyp| · √(e² - 1)
v_periapsis = √(v_∞² + 2μ/r_p)
```

### Heliocentric Velocity Change
The outgoing v_∞ vector is rotated by angle δ in the flyby plane (Rodrigues rotation formula).

---

## 12. Atmospheric Re-Entry Analysis

File: `core/reentry.sci`

### Model: Allen-Eggers Ballistic Entry

**Peak deceleration altitude:**
```
h_peak = H · ln(ρ₀·H / (β·|sin(γ)|))
```

**Peak deceleration:**
```
a_peak = v_entry² · |sin(γ)| · ρ_peak / (2β)
```

**Peak heat flux (Sutton-Graves):**
```
q̇ = k · √(ρ/R_nose) · v³
```

where k ≈ 1.7415×10⁻⁴ W/cm² for Earth.

### Atmospheric Model
Exponential: ρ(h) = ρ₀ · exp(-h/H)

| Planet | ρ₀ (kg/m³) | H (km) |
|--------|-----------|--------|
| Earth | 1.225 | 8.5 |
| Mars | 0.020 | 11.1 |

---

## 13. Rendezvous & Phasing

File: `core/rendezvous.sci`

### Phasing Maneuver
To close a phase angle φ in n revolutions:
```
T_phasing = T_target - φ/(n·ω_target)
a_phasing = (μ·(T_phasing/2π)²)^(1/3)
ΔV = 2 · |v_phasing - v_circular|
```

---

## 14. Ground Track Computation

File: `core/groundtrack.sci`

### Algorithm
```
lat = arcsin(r_z / |r|)
lon = atan2(r_y, r_x) - ω_earth · t
```

Longitude wrapped to [-180°, 180°].

---

## 15. Mission Utilities

File: `core/mission_utils.sci`

- **Synodic period**: T_syn = |T₁·T₂/(T₁-T₂)|
- **Launch window analysis**: Based on synodic period intervals
- **Orbital lifetime**: Drag decay using exponential atmosphere
- **Eclipse analysis**: Shadow half-angle and eclipse fraction
- **Vis-viva equation**: v = √(μ(2/r - 1/a))
- **Sphere of influence**: r_SOI = a·(m_planet/m_sun)^(2/5)

---

## 16. GUI Architecture

### Framework
- Built with Scilab's native `uicontrol` system
- Main figure: 1200×800 pixels
- 7 tabs managed by `switch_tab()` function
- Callback-based event handling

### Tab Switching
Each tab is built/destroyed dynamically. UI elements use `content_XX_` tag prefixes for cleanup.

### Status Bar
Bottom status bar updated via `update_status(msg)` for operation feedback.

---

## 17. Validation & Testing

### Kepler Solver
| Input (e, M) | Expected E | Notes |
|-------------|-----------|-------|
| 0.1, π/4 | 0.8507 rad | Standard test |
| 0.9, π | π rad | High eccentricity |

### Hohmann Transfer (LEO → GEO)
| Parameter | Expected | Units |
|-----------|----------|-------|
| ΔV₁ | 2.457 | km/s |
| ΔV₂ | 1.478 | km/s |
| ΔV_total | 3.935 | km/s |
| Transfer time | 5.256 | hours |

### Lambert Solver (Curtis Example 5.2)
Cross-validate velocity vectors against textbook values.

### Planetary Ephemeris
Cross-check against JPL Horizons:
```
planet_state_heliocentric(3, date_to_jd(2000, 1, 1, 12))
// Should return Earth position near (1 AU, 0, 0) at J2000 epoch
```

---

*Last updated: August 14, 2026*
