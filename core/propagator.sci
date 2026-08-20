// OrbitalMDT :: Orbit Propagator
// Numerical orbit propagation using Scilab's ode().
// Models: 2BODY, 2BODY_J2.

function dydt = two_body_eom(t, y, mu)
    // Two-body equations of motion.
    // y = [x;y;z;vx;vy;vz] (6x1)
    r_vec = y(1:3);
    r = norm(r_vec);
    a_grav = -(mu / r^3) * r_vec;
    dydt = [y(4:6); a_grav];
endfunction


function dydt = two_body_j2_eom(t, y, mu, J2, Re)
    // Two-body + J2 perturbation.
    r_vec = y(1:3);
    x = r_vec(1);
    yy = r_vec(2);
    z = r_vec(3);
    r = norm(r_vec);

    a_grav = -(mu / r^3) * r_vec;

    fac = 1.5 * J2 * mu * Re^2 / r^5;
    z2_r2 = (z / r)^2;
    a_j2 = fac * [x * (5*z2_r2 - 1); ..
                  yy * (5*z2_r2 - 1); ..
                  z * (5*z2_r2 - 3)];

    dydt = [y(4:6); a_grav + a_j2];
endfunction


function [t_out, states] = propagate_orbit(r0, v0, t_span, mu, options)
    // Propagate orbit from initial state.
    // INPUTS:
    //   r0      [km] (3x1)
    //   v0      [km/s] (3x1)
    //   t_span  [s] - [t_start, t_end] or full time vector
    //   mu      [km^3/s^2]
    //   options struct with optional fields:
    //           .use_j2  %T/%F (default %F)
    //           .J2      J2 coefficient
    //           .Re      reference radius [km]
    //           .n_steps output steps (default 1000)
    // OUTPUTS:
    //   t_out   time vector [s]
    //   states  6xN state matrix

    use_j2  = %F;
    J2_val  = 0;
    Re_val  = 0;
    n_steps = 1000;

    if exists('options', 'local') then
        if isfield(options, 'use_j2')  then use_j2  = options.use_j2; end
        if isfield(options, 'J2')      then J2_val  = options.J2;     end
        if isfield(options, 'Re')      then Re_val  = options.Re;     end
        if isfield(options, 'n_steps') then n_steps = options.n_steps; end
    end

    y0 = [r0(:); v0(:)];

    if size(t_span, "*") == 2 then
        t_out = linspace(t_span(1), t_span(2), n_steps);
    else
        t_out = t_span;
    end

    rtol_c = 1e-9;
    atol_c = 1e-9;
    if use_j2 then
        states = ode("adams", y0, t_out(1), t_out, rtol_c, atol_c, list(two_body_j2_eom, mu, J2_val, Re_val));
    else
        states = ode("adams", y0, t_out(1), t_out, rtol_c, atol_c, list(two_body_eom, mu));
    end
endfunction


function [r_mag, v_mag, a_km, e_val, i_val, h_mag] = orbit_analysis(states, mu)
    // Vectorized orbital parameter analysis along a trajectory matrix.
    r_mag = sqrt(sum(states(1:3, :).^2, "r"));
    v_mag = sqrt(sum(states(4:6, :).^2, "r"));
    
    energy = (v_mag.^2) / 2 - mu ./ r_mag;
    a_km = -mu ./ (2 * energy);
    a_km(abs(energy) <= 1e-10) = %inf;

    // Cross product h = r x v (vectorized)
    hx = states(2, :) .* states(6, :) - states(3, :) .* states(5, :);
    hy = states(3, :) .* states(4, :) - states(1, :) .* states(6, :);
    hz = states(1, :) .* states(5, :) - states(2, :) .* states(4, :);
    h_mag = sqrt(hx.^2 + hy.^2 + hz.^2);

    // Eccentricity vector e = (1/mu) * ((v^2 - mu/r)*r - (r.v)*v)
    rdotv = sum(states(1:3, :) .* states(4:6, :), "r");
    c_rv  = v_mag.^2 - mu ./ r_mag;
    ex = (1/mu) * (c_rv .* states(1, :) - rdotv .* states(4, :));
    ey = (1/mu) * (c_rv .* states(2, :) - rdotv .* states(5, :));
    ez = (1/mu) * (c_rv .* states(3, :) - rdotv .* states(6, :));
    e_val = sqrt(ex.^2 + ey.^2 + ez.^2);

    i_val = zeros(1, size(states, 2));
    mask = h_mag > 1e-10;
    i_val(mask) = acos(max(-1, min(1, hz(mask) ./ h_mag(mask))));
endfunction


function metrics = check_conservation(states, mu)
    // Quantify energy and angular momentum conservation along a trajectory.
    // INPUTS:
    //   states - 6xN matrix of states [r; v]
    //   mu     - gravitational parameter
    // OUTPUTS:
    //   metrics - struct with energy_rel_err, h_rel_err, max_r, min_r

    [r_mag, v_mag, a_km, e_val, i_val, h_mag] = orbit_analysis(states, mu);

    E0 = v_mag(1)^2 / 2 - mu / r_mag(1);
    E_end = v_mag($)^2 / 2 - mu / r_mag($);
    metrics.energy_rel_err = abs((E_end - E0) / E0);

    h0 = h_mag(1);
    h_end = h_mag($);
    metrics.h_rel_err = abs((h_end - h0) / h0);

    metrics.max_r = max(r_mag);
    metrics.min_r = min(r_mag);
endfunction
