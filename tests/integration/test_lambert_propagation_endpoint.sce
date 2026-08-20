// OrbitalMDT Integration Test :: Lambert Output Trajectory Propagation Endpoint Match
// CRITICAL VALIDATION: Takes r1, r2, TOF -> Solves Lambert v1 -> Propagates v1 over TOF -> Verifies ||r(TOF) - r2|| < tol.

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/ephemeris.sci", -1);
exec("core/lambert.sci", -1);
exec("core/propagator.sci", -1);

m_passed = 0;
m_failed = 0;

function assert_true(cond, name)
    global m_passed m_failed;
    if cond then
        m_passed = m_passed + 1;
        printf("  [PASS] %s\n", name);
    else
        m_failed = m_failed + 1;
        printf("  [FAIL] %s\n", name);
    end
endfunction

printf("--- Running integration/test_lambert_propagation_endpoint.sce ---\n");

const = orbital_constants();
mu_sun = const.mu_Sun;

jd_dep = date_to_jd(2028, 10, 15);
jd_arr = date_to_jd(2029, 5, 15);
tof_sec = (jd_arr - jd_dep) * 86400;

[r1, v1_pl] = planet_state_heliocentric(3, jd_dep);
[r2, v2_pl] = planet_state_heliocentric(4, jd_arr);

// 1. Lambert solver
[v1_trans, v2_trans, ok, iter] = lambert_solver(r1, r2, tof_sec, mu_sun, 1);
assert_true(ok, "Lambert solver converged on orbital arc");

// 2. Trajectory propagation endpoint verification
[t_out, states] = propagate_orbit(r1, v1_trans, [0, tof_sec], mu_sun);
r_endpoint = states(1:3, $);
rel_endpoint_error = norm(r_endpoint - r2) / norm(r2);
assert_true(rel_endpoint_error < 1e-4, "Propagated position endpoint r(TOF) matches target r2 (Rel Error < 1e-4)");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
