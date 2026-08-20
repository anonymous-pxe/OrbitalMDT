// OrbitalMDT Unit Test :: Time Utilities

exec("core/constants.sci", -1);
exec("core/time.sci", -1);

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

printf("--- Running unit/test_time.sce ---\n");

jd_j2000 = date_to_jd(2000, 1, 1, 12, 0, 0);
assert_true(abs(jd_j2000 - 2451545.0) < 1e-6, "J2000 epoch JD value (2451545.0)");

[y, m, d, h, mn, s] = jd_to_date(2451545.0);
assert_true(y == 2000 & m == 1 & d == 1 & h == 12, "J2000 JD to date roundtrip");

[y2, m2, d2, h2, mn2, s2] = jd_to_date(date_to_jd(2026, 8, 15, 10, 20, 30));
assert_true(y2 == 2026 & m2 == 8 & d2 == 15 & h2 == 10 & mn2 == 20 & s2 == 30, "Arbitrary date -> JD -> date roundtrip");

T_cent = jd_to_centuries_j2000(2451545.0);
assert_true(abs(T_cent) < 1e-12, "Centuries past J2000 for J2000 is 0");

d_str = format_date_str(2026, 8, 15);
assert_true(d_str == "2026-08-15", "Date string formatting");

[py, pm, pd] = parse_date_str("2026-08-15");
assert_true(py == 2026 & pm == 8 & pd == 15, "Date string parsing");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
