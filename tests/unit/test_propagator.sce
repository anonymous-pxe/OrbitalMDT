// OrbitalMDT Unit Test :: Orbit Propagator

exec("core/constants.sci", -1);
exec("core/coordinates.sci", -1);
exec("core/propagator.sci", -1);

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

printf("--- Running unit/test_propagator.sce ---\n");

const = orbital_constants();
mu = const.mu_Earth;

r0 = [7000; 0; 0];
v0 = [0; sqrt(mu / 7000); 0];
T_period = 2 * %pi * sqrt(7000^3 / mu);

[t_out, states] = propagate_orbit(r0, v0, [0, T_period], mu);

r_end = states(1:3, $);
pos_err = norm(r_end - r0);

assert_true(pos_err < 5.0, "Two-body 1-period closed orbit position match (< 5 km)");

metrics = check_conservation(states, mu);
assert_true(metrics.energy_rel_err < 1e-4, "Relative energy error < 1e-4 over 1 period");
assert_true(metrics.h_rel_err < 1e-4, "Relative angular momentum error < 1e-4 over 1 period");

opts.use_j2 = %T;
opts.J2     = const.J2_Earth;
opts.Re     = const.Re_Earth;

[t_j2, states_j2] = propagate_orbit(r0, v0, [0, 86400], mu, opts);
assert_true(size(states_j2, 2) == 1000, "J2 perturbed propagation output matrix size");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
