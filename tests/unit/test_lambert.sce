// OrbitalMDT Unit Test :: Lambert Solver

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/lambert.sci", -1);

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

printf("--- Running unit/test_lambert.sce ---\n");

const = orbital_constants();
mu_sun = const.mu_Sun;

r1 = [149.6e6; 0; 0];
r2 = [0; 227.9e6; 0];
tof_sec = 200 * 86400;

[v1_trans, v2_trans, ok, iter] = lambert_solver(r1, r2, tof_sec, mu_sun, 1);
assert_true(ok, "Lambert solver basic prograde arc convergence");
assert_true(norm(v1_trans) > 20 & norm(v1_trans) < 50, "Lambert departure velocity in physical range");

v1_p = [0; 29.78; 0]; v2_p = [-24.1; 0; 0];
res = lambert_solve_mission(r1, r2, tof_sec, v1_p, v2_p, mu_sun, 1);
assert_true(res.converged, "lambert_solve_mission status converged");
assert_true(res.c3_dep > 0, "Positive C3 departure energy");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
