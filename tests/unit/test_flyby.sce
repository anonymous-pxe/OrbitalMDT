// OrbitalMDT Unit Test :: Gravity Assist / Flyby

exec("core/constants.sci", -1);
exec("core/flyby.sci", -1);

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

printf("--- Running unit/test_flyby.sce ---\n");

const = orbital_constants();

v_inf_in = [5.0; 0; 0];
v_planet = [0; 35.0; 0];
mu_venus = const.mu_Venus;
r_peri   = const.R_Venus + 500;

res = gravity_assist(v_inf_in, v_planet, mu_venus, r_peri, const.R_Venus);

assert_true(res.valid, "Venus flyby valid execution");
assert_true(res.turn_angle_deg > 0 & res.turn_angle_deg < 180, "Hyperbolic turning angle > 0 and < 180 deg");
assert_true(abs(res.v_inf_mag - 5.0) < 1e-10, "V-infinity magnitude conserved in unpowered flyby");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
