// OrbitalMDT Reference Mission Validation Suite
// Rigorously benchmarked against textbook reference cases and analytical orbital mechanics solutions.
// References:
//   [1] Curtis, H. D., "Orbital Mechanics for Engineering Students", 4th Ed.
//   [2] Bate, R. R., Mueller, D. D., and White, J. E., "Fundamentals of Astrodynamics".
//   [3] Standish, E. M., "JPL Planetary Ephemerides", 1992.

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/frames.sci", -1);
exec("core/ephemeris.sci", -1);
exec("core/lambert.sci", -1);
exec("core/hohmann.sci", -1);
exec("core/bielliptic.sci", -1);
exec("core/propagator.sci", -1);
exec("core/flyby.sci", -1);
exec("core/rocket_equation.sci", -1);
exec("core/reentry.sci", -1);
exec("core/rendezvous.sci", -1);
exec("core/groundtrack.sci", -1);
exec("core/mission_utils.sci", -1);

m_passed = 0;
m_failed = 0;

function assert_benchmark(val, expected, tol, test_name, unit_str)
    global m_passed m_failed;
    err = abs(val - expected);
    if err <= tol then
        m_passed = m_passed + 1;
        printf("  [PASS] %-48s (Got: %10.4f, Ref: %10.4f %s, Err: %.2e <= Tol: %.2e)\n", ..
            test_name, val, expected, unit_str, err, tol);
    else
        m_failed = m_failed + 1;
        printf("  [FAIL] %-48s (Got: %10.4f, Ref: %10.4f %s, Err: %.2e > Tol: %.2e)\n", ..
            test_name, val, expected, unit_str, err, tol);
    end
endfunction

printf("========================================================================\n");
printf("     OrbitalMDT Reference Mission Analytical Benchmark Suite            \n");
printf("========================================================================\n\n");

const = orbital_constants();
mu_e = const.mu_Earth;
mu_s = const.mu_Sun;

// -----------------------------------------------------------------------------
// Benchmark 1: Circular Low Earth Orbit (LEO, h = 400 km, r = 6778.137 km)
// Reference: v_circ = sqrt(mu/r) = 7.6686 km/s, T = 2*pi*sqrt(r^3/mu) = 5553.6243 s
// -----------------------------------------------------------------------------
r_leo = const.Re_Earth + 400.0;
v_leo_circ = circular_velocity(mu_e, r_leo);
T_leo_sec  = orbital_period(r_leo, mu_e);

assert_benchmark(v_leo_circ, 7.6686, 1e-3, "Ref 1.1: Circular LEO Speed (h=400 km)", "km/s");
assert_benchmark(T_leo_sec, 5553.6243, 1.0, "Ref 1.2: Circular LEO Period", "s");

// -----------------------------------------------------------------------------
// Benchmark 2: LEO -> GEO Hohmann Transfer (r1 = 6578.137 km, r2 = 42164.137 km)
// Reference: dv1 = 2.4546 km/s, dv2 = 1.4773 km/s, dv_tot = 3.9319 km/s, TOF = 5.259 hr
// -----------------------------------------------------------------------------
r_leo2 = const.Re_Earth + 200.0; // 6578.137 km
r_geo  = 42164.137;
res_hohmann = hohmann_transfer(r_leo2, r_geo, mu_e);

assert_benchmark(res_hohmann.dv1, 2.4546, 2e-3, "Ref 2.1: LEO->GEO Hohmann 1st Burn dv1", "km/s");
assert_benchmark(res_hohmann.dv2, 1.4773, 2e-3, "Ref 2.2: LEO->GEO Hohmann 2nd Burn dv2", "km/s");
assert_benchmark(res_hohmann.dv_total, 3.9319, 3e-3, "Ref 2.3: LEO->GEO Hohmann Total dv", "km/s");
assert_benchmark(res_hohmann.t_transfer / 3600, 5.2589, 0.05, "Ref 2.4: LEO->GEO Transfer Time", "hr");

// -----------------------------------------------------------------------------
// Benchmark 3: GEO -> LEO Orbit Lowering (Reversibility check)
// Reference: dv_total must exactly equal LEO -> GEO dv_total
// -----------------------------------------------------------------------------
res_lowering = hohmann_transfer(r_geo, r_leo2, mu_e);
assert_benchmark(res_lowering.dv_total, res_hohmann.dv_total, 1e-6, "Ref 3.1: GEO->LEO Lowering Total dv symmetry", "km/s");

// -----------------------------------------------------------------------------
// Benchmark 4: Earth Escape Velocity from 300 km Circular Orbit (r = 6678.137 km)
// Reference: v_esc = sqrt(2*mu/r) = 10.9259 km/s, Delta-V = v_esc - v_circ = 3.2001 km/s
// -----------------------------------------------------------------------------
r_300 = const.Re_Earth + 300.0;
v_circ_300 = circular_velocity(mu_e, r_300);
v_esc_300  = escape_velocity(mu_e, r_300);
dv_esc = v_esc_300 - v_circ_300;

assert_benchmark(v_esc_300, 10.9259, 1e-3, "Ref 4.1: Parabolic Escape Speed from 300 km", "km/s");
assert_benchmark(dv_esc, 3.2001, 1e-3, "Ref 4.2: Escape Delta-V from 300 km LEO", "km/s");

// -----------------------------------------------------------------------------
// Benchmark 5: Earth to Mars Interplanetary Lambert Arc (2028-10-15 -> 2029-05-15, TOF = 212 d)
// -----------------------------------------------------------------------------
jd_d = date_to_jd(2028, 10, 15);
jd_a = date_to_jd(2029, 5, 15);
[r1_e, v1_e] = planet_state_heliocentric(3, jd_d);
[r2_m, v2_m] = planet_state_heliocentric(4, jd_a);
tof_sec_mars = (jd_a - jd_d) * 86400;

res_lmb = lambert_solve_mission(r1_e, r2_m, tof_sec_mars, v1_e, v2_m, mu_s, 1);
assert_benchmark(res_lmb.c3_dep, 59.7493, 0.5, "Ref 5.1: Earth-Mars 2028 Departure C3 Energy", "km^2/s^2");
assert_benchmark(res_lmb.dv_total, 16.4016, 0.5, "Ref 5.2: Earth-Mars Interplanetary dv_total", "km/s");

// -----------------------------------------------------------------------------
// Benchmark 6: Orbit Propagation Energy & Angular Momentum Conservation (10 Orbits)
// -----------------------------------------------------------------------------
r0_test = [7000; 0; 0];
v0_test = [0; sqrt(mu_e / 7000); 0];
T_10 = 10 * 2 * %pi * sqrt(7000^3 / mu_e);
[t_prop, states_prop] = propagate_orbit(r0_test, v0_test, [0, T_10], mu_e);
metrics = check_conservation(states_prop, mu_e);

assert_benchmark(metrics.energy_rel_err, 0.0, 1e-4, "Ref 6.1: 10-Orbit Relative Energy Drift", "rel_err");
assert_benchmark(metrics.h_rel_err, 0.0, 1e-4, "Ref 6.2: 10-Orbit Relative Ang. Momentum Drift", "rel_err");

// -----------------------------------------------------------------------------
// Benchmark 7: Co-Orbital Phasing Catch-up (Target r = 7000 km, gap = 45 deg, 1 rev)
// -----------------------------------------------------------------------------
res_ph = phasing_maneuver(7000.0, 45.0, 1, mu_e);
assert_benchmark(res_ph.r_apogee, 7000.0, 1e-3, "Ref 7.1: Phasing orbit apogee equals target r", "km");
assert_benchmark(res_ph.dv_total, 0.7197, 1e-3, "Ref 7.2: 45-deg Phasing Delta-V", "km/s");

// -----------------------------------------------------------------------------
// Benchmark 8: Venus Gravity Assist Turn Angle (v_inf = 6.0 km/s, r_p = 6551.8 km)
// Reference: e_hyp = 1 + r_p * v_inf^2 / mu_Venus = 1.7261, turn_angle = 2*asin(1/e_hyp) = 70.81 deg
// -----------------------------------------------------------------------------
r_p_venus = const.R_Venus + 500.0;
res_flyby = gravity_assist([6.0; 0; 0], [0; 35.0; 0], const.mu_Venus, r_p_venus, const.R_Venus);
e_hyp_expected = 1 + r_p_venus * 36.0 / const.mu_Venus;
turn_expected  = 2 * asin(1 / e_hyp_expected) * 180 / %pi;

assert_benchmark(res_flyby.eccentricity, e_hyp_expected, 1e-4, "Ref 8.1: Flyby Hyperbolic Eccentricity", "[-]");
assert_benchmark(res_flyby.turn_angle_deg, turn_expected, 1e-3, "Ref 8.2: Flyby Asymptotic Turn Angle", "deg");

// -----------------------------------------------------------------------------
// Benchmark 9: Apollo CM Earth Ballistic Re-entry Deceleration & Heat Flux
// Reference: Entry at 11 km/s, -6.5 deg -> peak decel ~ 9.30 g at ~ 46.88 km
// -----------------------------------------------------------------------------
res_re = ballistic_entry(11.0, -6.5, 120.0, 370e6, 4.69, "Earth");
assert_benchmark(res_re.g_loading, 9.3011, 0.5, "Ref 9.1: Apollo CM Peak Deceleration", "g");
assert_benchmark(res_re.h_peak_decel, 46.8846, 0.5, "Ref 9.2: Apollo CM Peak Decel Altitude", "km");

// -----------------------------------------------------------------------------
// Benchmark 10: Tsiolkovsky Staging Mass Fraction
// -----------------------------------------------------------------------------
res_rk_ref = rocket_equation(9.4, 350.0, 5000.0);
MR_exp = exp(9.4 / (350.0 * const.g0));
assert_benchmark(res_rk_ref.mass_ratio, MR_exp, 1e-4, "Ref 10.1: Tsiolkovsky Mass Ratio (9.4 km/s, 350s)", "[-]");
assert_benchmark(res_rk_ref.prop_fraction, (MR_exp - 1)/MR_exp, 1e-4, "Ref 10.2: Propellant Mass Fraction", "[-]");

printf("\n------------------------------------------------------------------------\n");
printf(" REFERENCE MISSION BENCHMARK RESULT: %d Passed, %d Failed\n", m_passed, m_failed);
printf("------------------------------------------------------------------------\n\n");
