// OrbitalMDT Unit Test :: Ballistic Re-entry & Dynamic Pressure

exec("core/constants.sci", -1);
exec("core/reentry.sci", -1);

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

printf("--- Running unit/test_reentry.sce ---\n");

res = ballistic_entry(11.0, -6.5, 120, 370e6, 4.69, "Earth");

assert_true(res.g_loading > 5 & res.g_loading < 25, "Peak g-loading in 5-25 g range");
assert_true(res.q_peak > 100, "Peak stagnation heat flux > 100 kW/m^2");
assert_true(res.peak_dyn_press > 0, "Peak dynamic pressure > 0 kPa");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
