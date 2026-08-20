// OrbitalMDT Integration Test :: Porkchop Grid Search & Optimal Selection

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/kepler.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/ephemeris.sci", -1);
exec("core/lambert.sci", -1);
exec("core/porkchop.sci", -1);

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

printf("--- Running integration/test_porkchop_workflow.sce ---\n");

dep_start = date_to_jd(2028, 9, 1);
dep_end   = date_to_jd(2028, 11, 30);
arr_start = date_to_jd(2029, 4, 1);
arr_end   = date_to_jd(2029, 7, 31);

[dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop( ..
    3, 4, dep_start, dep_end, arr_start, arr_end, 15, 15);

assert_true(size(dv_grid, 1) == 15 & size(dv_grid, 2) == 15, "Porkchop grid matrix size 15x15");

[opt_dep, opt_arr, opt_dv, opt_tof] = find_optimal_window(dv_grid, dep_jd, arr_jd);

assert_true(opt_dv > 3 & opt_dv < 20, "Optimal window Delta-V found in physical range");
assert_true(opt_tof > 100 & opt_tof < 400, "Optimal window TOF in 100-400 day range");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
