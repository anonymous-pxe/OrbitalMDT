// OrbitalMDT Unit Test :: Physical & Astronomical Constants
// Validates single source of truth physical constants against IAU/CODATA reference values.

exec("core/constants.sci", -1);

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

printf("--- Running unit/test_constants.sce ---\n");

const = orbital_constants();

// 1. Gravitational parameters
assert_true(abs(const.mu_Sun - 1.32712440018e11) < 1.0, "Sun gravitational parameter mu_Sun (IAU 2012)");
assert_true(abs(const.mu_Earth - 3.986004418e5) < 1e-3, "Earth gravitational parameter mu_Earth (WGS84)");
assert_true(abs(const.mu_Mars - 4.282837e4) < 1e-1, "Mars gravitational parameter mu_Mars");
assert_true(abs(const.mu_Jupiter - 1.26686534e8) < 1.0, "Jupiter gravitational parameter mu_Jupiter");

// 2. Astronomical Unit and distance scales
assert_true(abs(const.AU - 149597870.7) < 1e-3, "Astronomical Unit (AU = 149,597,870.7 km)");
assert_true(const.Re_Earth == 6378.137, "Earth WGS84 equatorial radius Re_Earth (6378.137 km)");
assert_true(const.R_Earth == 6371.0, "Earth mean volumetric radius R_Earth (6371.0 km)");
assert_true(const.Re_Earth > const.Rp_Earth, "Earth equatorial radius > polar radius (oblate spheroid)");

// 3. Physical conversions
assert_true(abs(const.deg2rad * 180 - %pi) < 1e-12, "deg2rad conversion factor");
assert_true(abs(const.rad2deg * %pi - 180) < 1e-12, "rad2deg conversion factor");
assert_true(const.day2sec == 86400, "day2sec conversion factor (86400 s/day)");

// 4. Standard gravity & J2
assert_true(abs(const.g0 - 9.80665e-3) < 1e-8, "Standard acceleration of gravity g0 (9.80665 m/s^2 = 9.80665e-3 km/s^2)");
assert_true(abs(const.J2_Earth - 1.08263e-3) < 1e-7, "Earth J2 harmonic coefficient");

// 5. Vector helper functions
v1 = [1; 2; 3];
v2 = [4; 5; 6];
assert_true(abs(dot(v1, v2) - 32) < 1e-12, "Vector dot product dot([1,2,3], [4,5,6]) = 32");
c_exp = [-3; 6; -3];
assert_true(norm(cross(v1, v2) - c_exp) < 1e-12, "Vector cross product cross([1,2,3], [4,5,6]) = [-3, 6, -3]");
assert_true(abs(norm_vec(v1) - sqrt(14)) < 1e-12, "Vector norm_vec([1,2,3]) = sqrt(14)");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
