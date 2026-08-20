// OrbitalMDT Unit Test :: Mission Utilities
// Validates synodic periods, launch windows, vis-viva, Laplace SOI, lifetime, and eclipse analysis.

exec("core/constants.sci", -1);
exec("core/time.sci", -1);
exec("core/mission_utils.sci", -1);

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

printf("--- Running unit/test_mission_utils.sce ---\n");

const = orbital_constants();

// 1. Synodic period (Earth ~365.25 days, Mars ~687 days -> Synodic ~780 days)
T_earth = 365.25 * 86400;
T_mars  = 686.98 * 86400;
syn = synodic_period(T_earth, T_mars);

assert_true(abs(syn.T_synodic_days - 780.0) < 5.0, "Earth-Mars synodic period (~780 days)");
assert_true(abs(syn.T_synodic_years - 2.135) < 0.02, "Earth-Mars synodic period in years (~2.14 yr)");

// 2. Launch window analysis (Earth -> Mars)
res_lw = launch_window_analysis(3, 4, 2026, 4);
assert_true(res_lw.n_windows == 4, "Generated 4 launch window epochs");
assert_true(size(res_lw.windows, "*") == 4, "Windows array size 4x1");
assert_true(res_lw.window_dates(1).year >= 2026, "First launch window year >= 2026");

// 3. Vis-Viva Equation
mu_e = const.mu_Earth;
r_orb = 7000.0;
a_orb = 7000.0;
vv_res = vis_viva(r_orb, a_orb, mu_e);
v_exp = sqrt(mu_e / r_orb);
assert_true(abs(vv_res.v - v_exp) < 1e-10, "Vis-viva circular velocity match sqrt(mu/r)");

// 4. Laplace Sphere of Influence (SOI)
// Earth SOI around Sun: a_Earth * (mu_Earth / mu_Sun)^(2/5) ~ 9.24e5 km (~0.924 M km)
soi_earth = sphere_of_influence(const.a_Earth, const.mu_Earth, const.mu_Sun);
assert_true(abs(soi_earth.r_soi - 9.24e5) < 3.0e4, "Earth Laplace SOI radius (~924,000 km)");
assert_true(soi_earth.r_soi_AU > 0.005 & soi_earth.r_soi_AU < 0.007, "Earth SOI in AU (~0.0062 AU)");

// 5. Eclipse Analysis for LEO (a = 6778 km, R_Earth = 6378 km)
ecl_res = eclipse_analysis(6778.0, 0.0, 0.0, const.Re_Earth, const.AU);
assert_true(ecl_res.eclipse_fraction > 0.35 & ecl_res.eclipse_fraction < 0.45, "LEO cylindrical eclipse fraction (~35-45%)");
assert_true(ecl_res.t_eclipse_min > 30 & ecl_res.t_eclipse_min < 40, "LEO eclipse duration (~33-38 minutes)");
assert_true(abs(ecl_res.t_eclipse + ecl_res.t_sunlit - ecl_res.T_period) < 1e-6, "Eclipse + sunlit time equals orbital period");

// 6. Orbital Lifetime / Drag Decay estimation
// LEO spacecraft at 300 km altitude (a = 6678 km)
m_sc = 500.0; Cd = 2.2; Area = 2.0; // 500 kg, 2 m^2
life_res = orbital_lifetime(6678.0, 0.001, m_sc, Cd, Area, mu_e, const.rho0_Earth, const.H_Earth, const.Re_Earth);
assert_true(life_res.lifetime_days > 0, "Orbital lifetime is positive");
assert_true(life_res.beta > 50, "Ballistic coefficient computed (m/(Cd*A))");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
