// OrbitalMDT Integration Test :: Earth to Mars Interplanetary Lambert Arc

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/ephemeris.sci", -1);
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

printf("--- Running integration/test_earth_mars_lambert.sce ---\n");

const = orbital_constants();

jd_dep = date_to_jd(2028, 10, 15);
jd_arr = date_to_jd(2029, 5, 15);
tof_sec = (jd_arr - jd_dep) * const.day2sec;

[r_earth, v_earth] = planet_state_heliocentric(3, jd_dep);
[r_mars, v_mars]   = planet_state_heliocentric(4, jd_arr);

res = lambert_solve_mission(r_earth, r_mars, tof_sec, v_earth, v_mars, const.mu_Sun, 1);

assert_true(res.converged, "Earth-Mars Lambert solution converged");
assert_true(res.dv_total > 3 & res.dv_total < 30, "Total transfer Delta-V in physical range (3-30 km/s)");
assert_true(res.c3_dep > 0 & res.c3_dep < 100, "Earth departure C3 in physical range (0-100 km^2/s^2)");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
