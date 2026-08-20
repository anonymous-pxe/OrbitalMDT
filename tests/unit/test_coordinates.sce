// OrbitalMDT Unit Test :: Coordinate Transformations & Orbital Elements
// Validates orbital_elements_to_state and state_to_orbital_elements conversions.

exec("core/constants.sci", -1);
exec("core/coordinates.sci", -1);

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

printf("--- Running unit/test_coordinates.sce ---\n");

const = orbital_constants();
mu = const.mu_Earth;
d2r = const.deg2rad;

// 1. General Elliptic Inclined Orbit (ISS-like)
a1 = 6778.0; e1 = 0.001; i1 = 51.6 * d2r; RAAN1 = 45.0 * d2r; w1 = 30.0 * d2r; nu1 = 60.0 * d2r;

[r1, v1] = orbital_elements_to_state(a1, e1, i1, RAAN1, w1, nu1, mu);
[a1_c, e1_c, i1_c, RAAN1_c, w1_c, nu1_c] = state_to_orbital_elements(r1, v1, mu);

assert_true(abs(a1_c - a1) < 1e-4, "ISS orbit: Semi-major axis roundtrip (a = 6778 km)");
assert_true(abs(e1_c - e1) < 1e-5, "ISS orbit: Eccentricity roundtrip (e = 0.001)");
assert_true(abs(i1_c - i1) < 1e-5, "ISS orbit: Inclination roundtrip (i = 51.6 deg)");
assert_true(abs(RAAN1_c - RAAN1) < 1e-5, "ISS orbit: RAAN roundtrip");
assert_true(abs(w1_c - w1) < 1e-5, "ISS orbit: Arg periapsis roundtrip");
assert_true(abs(nu1_c - nu1) < 1e-5, "ISS orbit: True anomaly roundtrip");

// 2. Equatorial Circular Orbit (GEO)
a_geo = 42164.0; e_geo = 0.0; i_geo = 0.0;
[r_geo, v_geo] = orbital_elements_to_state(a_geo, e_geo, i_geo, 0, 0, 0, mu);
v_expected = sqrt(mu / a_geo); // ~3.0746 km/s

assert_true(abs(norm(r_geo) - a_geo) < 1e-4, "GEO radius matches a = 42164 km");
assert_true(abs(norm(v_geo) - v_expected) < 1e-4, "GEO velocity matches sqrt(mu/r) (~3.075 km/s)");

[a_g_c, e_g_c, i_g_c] = state_to_orbital_elements(r_geo, v_geo, mu);
assert_true(abs(a_g_c - a_geo) < 1e-3, "GEO state to elements: Semi-major axis");
assert_true(e_g_c < 1e-5, "GEO state to elements: Zero eccentricity preserved");
assert_true(i_g_c < 1e-5, "GEO state to elements: Zero inclination preserved");

// 3. Polar Highly Elliptic Orbit (Molniya)
a_mol = 26600.0; e_mol = 0.74; i_mol = 63.4 * d2r; w_mol = 270.0 * d2r;
[r_mol, v_mol] = orbital_elements_to_state(a_mol, e_mol, i_mol, 0, w_mol, 0, mu);
[a_m_c, e_m_c, i_m_c, raan_m_c, w_m_c] = state_to_orbital_elements(r_mol, v_mol, mu);

assert_true(abs(a_m_c - a_mol) < 1e-3, "Molniya orbit: Semi-major axis roundtrip");
assert_true(abs(e_m_c - e_mol) < 1e-5, "Molniya orbit: High eccentricity roundtrip (e=0.74)");
assert_true(abs(i_m_c - i_mol) < 1e-5, "Molniya orbit: Critical inclination roundtrip (i=63.4 deg)");

// 4. Geodetic coordinates conversion (spherical Earth approximation)
r_sub = [const.Re_Earth + 400; 0; 0];
[lat, lon, alt] = eci_to_geodetic(r_sub, 0, const.omega_Earth);
assert_true(abs(lat) < 1e-6, "Equatorial position latitude = 0");
assert_true(abs(lon) < 1e-6, "Greenwich meridian longitude = 0 at t=0");
assert_true(abs(alt - 400) < 1e-4, "Altitude above Re_Earth matches 400 km");

// 5. Orbital period, circular velocity, escape velocity
T_leo = orbital_period(6778.0, mu);
assert_true(abs(T_leo - 5560) < 50, "LEO orbital period (~92.7 min = 5560 s)");

v_circ = circular_velocity(mu, 6778.0);
assert_true(abs(v_circ - 7.67) < 0.05, "LEO circular velocity (~7.67 km/s)");

v_esc = escape_velocity(mu, 6778.0);
assert_true(abs(v_esc - sqrt(2)*v_circ) < 1e-6, "Escape velocity v_esc = sqrt(2) * v_circ");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
