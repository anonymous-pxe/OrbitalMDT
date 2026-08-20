// OrbitalMDT Integration Test :: Mission Planner to Rocket Mass Budget Pipeline

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/ephemeris.sci", -1);
exec("core/lambert.sci", -1);
exec("core/rocket_equation.sci", -1);
exec("app/app_state.sci", -1);

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

printf("--- Running integration/test_planner_to_rocket.sce ---\n");

st = init_app_state();

// Set simulated Mission Planner optimum
st_upd.dv_req = 5.6; // km/s
st_upd.m_pay  = 1200; // kg
st_upd.isp    = 380;  // s

update_app_state(st_upd);

st_cur = get_app_state();
res_rk = rocket_equation(st_cur.dv_req, st_cur.isp, st_cur.m_pay);

assert_true(res_rk.m_payload == 1200, "App state payload mass transferred to rocket engine");
assert_true(res_rk.m_propellant > 0, "Propellant budget calculated successfully");
assert_true(res_rk.mass_ratio > 4, "Mass ratio > 4 for 5.6 km/s interplanetary ΔV arc");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
