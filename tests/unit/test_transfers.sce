// OrbitalMDT Unit Test :: Transfers

exec("core/constants.sci", -1);
exec("core/hohmann.sci", -1);
exec("core/bielliptic.sci", -1);

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

printf("--- Running unit/test_transfers.sce ---\n");

const = orbital_constants();
mu = const.mu_Earth;

h_res = hohmann_transfer(7000, 42164, mu);
assert_true(abs(h_res.dv_total - 3.93) < 0.2, "LEO-GEO Hohmann total Delta-V (~3.9 km/s)");
assert_true(h_res.t_transfer > 18000 & h_res.t_transfer < 20000, "LEO-GEO transfer time (~5.2 hours)");

b_res = bielliptic_transfer(7000, 100000, 300000, mu);
assert_true(b_res.is_better, "Bi-elliptic beats Hohmann for r2/r1 > 11.94 with high intermediate apoapsis");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
