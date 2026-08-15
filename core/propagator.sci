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

    if length(t_span) == 2 then
        t_out = linspace(t_span(1), t_span(2), n_steps);
    else
        t_out = t_span;
    end

    // Build right-hand-side as a proper Scilab function (avoids closure issues)
    if use_j2 then
        mu_c = mu; J2_c = J2_val; Re_c = Re_val;
        deff('dy = _rhs(t,y)', 'dy = two_body_j2_eom(t, y, mu_c, J2_c, Re_c)');
        states = ode(y0, t_out(1), t_out, _rhs);
    else
        mu_c = mu;
        deff('dy = _rhs(t,y)', 'dy = two_body_eom(t, y, mu_c)');
        states = ode(y0, t_out(1), t_out, _rhs);
    end
endfunction


function [r_mag, v_mag, a_km, e_val, i_val, h_mag] = orbit_analysis(states, mu)
    // Orbital parameters along a propagated trajectory.

    N = size(states, 2);
    r_mag = zeros(1, N);
    v_mag = zeros(1, N);
    a_km  = zeros(1, N);
    e_val = zeros(1, N);
    i_val = zeros(1, N);
    h_mag = zeros(1, N);

    for k = 1:N
        rv = states(1:3, k);
        vv = states(4:6, k);
        r = norm(rv);
        v = norm(vv);

        r_mag(k) = r;
        v_mag(k) = v;

        hv = cross(rv, vv);
        h_mag(k) = norm(hv);

        energy = v^2/2 - mu/r;
        if abs(energy) > 1e-10 then
            a_km(k) = -mu / (2 * energy);
        else
            a_km(k) = %inf;
        end

        ev = (1/mu) * ((v^2 - mu/r) * rv - dot(rv, vv) * vv);
        e_val(k) = norm(ev);

        if h_mag(k) > 1e-10 then
            i_val(k) = acos(max(-1, min(1, hv(3) / h_mag(k))));
        end
    end
endfunction
