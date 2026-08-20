// OrbitalMDT Unit Test :: Rendezvous & Phasing Maneuvers
// Validates co-orbital phasing orbits and Hohmann-based coplanar rendezvous.

exec("core/constants.sci", -1);
exec("core/hohmann.sci", -1);
exec("core/rendezvous.sci", -1);

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

printf("--- Running unit/test_rendezvous.sce ---\n");

const = orbital_constants();
mu = const.mu_Earth;

// 1. Phasing maneuver in LEO (Target r = 7000 km, chaser 30 deg behind, 1 rev)
r_target = 7000.0;
phase_gap_deg = 30.0; // chaser behind
n_revs = 1;

res_phase = phasing_maneuver(r_target, phase_gap_deg, n_revs, mu);

// Phasing orbit should be smaller (shorter period to catch up)
assert_true(res_phase.a_phasing < r_target, "Phasing orbit SMA is smaller to close gap from behind");
assert_true(res_phase.T_phasing < res_phase.T_target, "Phasing orbit period is shorter than target orbit");
assert_true(res_phase.dv_total > 0 & res_phase.dv_total < 1.0, "Phasing Delta-V total in reasonable range (0 < dV < 1 km/s)");
assert_true(abs(res_phase.r_apogee - r_target) < 1e-4, "Phasing orbit apogee touches target orbit radius");

// 2. Phasing maneuver with chaser ahead (negative phase angle -> larger phasing orbit)
res_phase_ahead = phasing_maneuver(r_target, -30.0, 1, mu);
assert_true(res_phase_ahead.a_phasing > r_target, "Phasing orbit SMA is larger when chaser is ahead");
assert_true(res_phase_ahead.T_phasing > res_phase_ahead.T_target, "Phasing orbit period is longer when chaser is ahead");

// 3. Coplanar rendezvous from LEO (6778 km) to higher orbit (7000 km)
r_chaser = 6778.0;
r_tgt2   = 7000.0;
res_rend = coplanar_rendezvous(r_chaser, r_tgt2, 0.0, mu);

assert_true(res_rend.dv_total > 0, "Coplanar rendezvous Delta-V > 0");
assert_true(res_rend.t_wait >= 0, "Non-negative phasing wait time");
assert_true(res_rend.t_total > res_rend.hohmann.t_transfer, "Total time includes wait time plus Hohmann transfer time");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
