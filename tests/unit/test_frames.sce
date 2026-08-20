// OrbitalMDT Unit Test :: Reference Frame Transformations

exec("core/constants.sci", -1);
exec("core/frames.sci", -1);

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

printf("--- Running unit/test_frames.sce ---\n");

// Ecliptic <-> Equatorial roundtrip
v_ecl = [1.49e8; 2.5e7; -1.2e6];
v_eq  = ecliptic_to_equatorial(v_ecl);
v_ecl_rt = equatorial_to_ecliptic(v_eq);

assert_true(norm(v_ecl_rt - v_ecl) < 1e-6, "Ecliptic -> Equatorial -> Ecliptic vector roundtrip");
assert_true(abs(norm(v_eq) - norm(v_ecl)) < 1e-6, "Vector norm preserved under rotation");

// Heliocentric <-> Planetocentric roundtrip
r_sc_h = [1.5e8; 2.0e7; 5.0e5];
v_sc_h = [-5.0; 29.8; 0.1];
r_pl_h = [1.49e8; 0; 0];
v_pl_h = [0; 29.78; 0];

[r_p, v_p] = heliocentric_to_planetocentric(r_sc_h, v_sc_h, r_pl_h, v_pl_h);
[r_sc_rt, v_sc_rt] = planetocentric_to_heliocentric(r_p, v_p, r_pl_h, v_pl_h);

assert_true(norm(r_sc_rt - r_sc_h) < 1e-10, "Helio -> Planetocentric -> Helio position roundtrip");
assert_true(norm(v_sc_rt - v_sc_h) < 1e-10, "Helio -> Planetocentric -> Helio velocity roundtrip");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
