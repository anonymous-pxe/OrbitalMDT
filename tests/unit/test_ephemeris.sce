// OrbitalMDT Unit Test :: Planetary Ephemeris

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/ephemeris.sci", -1);

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

printf("--- Running unit/test_ephemeris.sce ---\n");

const = orbital_constants();
jd_j2000 = const.J2000_JD;

el_earth = get_planet_elements(3, jd_j2000);
assert_true(abs(el_earth.a - 1.00000011) < 1e-5, "Earth semi-major axis at J2000 (~1.0 AU)");
assert_true(abs(el_earth.e - 0.01671022) < 1e-5, "Earth eccentricity at J2000");

[r_earth, v_earth] = planet_state_heliocentric(3, jd_j2000);
r_mag = norm(r_earth);
v_mag = norm(v_earth);

assert_true(abs(r_mag - 1.496e8) < 5.0e6, "Earth distance from Sun (~149.6M km)");
assert_true(abs(v_mag - 29.78) < 1.0, "Earth orbital velocity (~29.78 km/s)");

pos_all = solar_system_state(jd_j2000);
assert_true(size(pos_all, 1) == 3 & size(pos_all, 2) == 6, "solar_system_state returns 3x6 matrix");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
