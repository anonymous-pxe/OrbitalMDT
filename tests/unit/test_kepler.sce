// OrbitalMDT Unit Test :: Kepler Solver

exec("core/constants.sci", -1);
exec("core/kepler.sci", -1);

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

printf("--- Running unit/test_kepler.sce ---\n");

// Elliptic (low e)
M1 = 1.0; e1 = 0.1;
[E1, info1] = solve_kepler(M1, e1);
res1 = abs(E1 - e1 * sin(E1) - M1);
assert_true(info1.converged & res1 < 1e-10, "Elliptic low eccentricity (e=0.1)");

// Elliptic (high e)
M2 = 0.5; e2 = 0.95;
[E2, info2] = solve_kepler(M2, e2);
res2 = abs(E2 - e2 * sin(E2) - M2);
assert_true(info2.converged & res2 < 1e-10, "Elliptic high eccentricity (e=0.95)");

// Hyperbolic
M3 = 2.0; e3 = 1.5;
[H3, info3] = solve_kepler(M3, e3);
res3 = abs(e3 * sinh(H3) - H3 - M3);
assert_true(info3.converged & res3 < 1e-10, "Hyperbolic Kepler (e=1.5)");

// True <-> Mean anomaly roundtrip
e4 = 0.3; M4 = 1.8;
[E4, info4] = solve_kepler(M4, e4);
nu4 = eccentric_to_true(E4, e4);
M4_calc = true_to_mean(nu4, e4);
assert_true(abs(M4_calc - M4) < 1e-10, "True <-> Mean anomaly roundtrip");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
