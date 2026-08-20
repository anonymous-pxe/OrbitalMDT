// OrbitalMDT Unit Test :: Tsiolkovsky Rocket Equation

exec("core/constants.sci", -1);
exec("core/rocket_equation.sci", -1);

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

printf("--- Running unit/test_rocket_equation.sce ---\n");

res = rocket_equation(9.4, 350, 5000); // dv = 9.4 km/s, Isp = 350 s, payload = 5000 kg

assert_true(res.mass_ratio > 10, "Mass ratio > 10 for 9.4 km/s LEO launcher");
assert_true(res.m_propellant > 50000, "Propellant mass > 50,000 kg");
assert_true(res.prop_fraction > 0.9, "Propellant fraction > 90%");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
