// ============================================================================
// OrbitalMDT — Orbit Propagator
// ============================================================================
// Numerical orbit propagation using Scilab's ode() function.
// Supports two-body and two-body + J2 perturbation.
// ============================================================================

function dydt = two_body_eom(t, y, mu)
    // Two-body equations of motion
    // y = [x, y, z, vx, vy, vz]' (6x1 state vector)
    
    r_vec = y(1:3);
    v_vec = y(4:6);
    r = norm(r_vec);
    
    // Gravitational acceleration
    a_grav = -(mu / r^3) * r_vec;
    
    dydt = [v_vec; a_grav];
    
endfunction


function dydt = two_body_j2_eom(t, y, mu, J2, Re)
    // Two-body + J2 perturbation equations of motion
    // INPUTS:
    //   t  - Time [s]
    //   y  - State vector [x, y, z, vx, vy, vz]' [km, km/s]
    //   mu - Gravitational parameter [km^3/s^2]
    //   J2 - J2 coefficient
    //   Re - Reference equatorial radius [km]
    
    r_vec = y(1:3);
    v_vec = y(4:6);
    
    x = r_vec(1); yy = r_vec(2); z = r_vec(3);
    r = norm(r_vec);
    
    // Two-body gravity
    a_grav = -(mu / r^3) * r_vec;
    
    // J2 perturbation acceleration
    factor = (3/2) * J2 * mu * Re^2 / r^5;
    
    a_j2 = zeros(3,1);
    a_j2(1) = factor * x * (5 * z^2 / r^2 - 1);
    a_j2(2) = factor * yy * (5 * z^2 / r^2 - 1);
    a_j2(3) = factor * z * (5 * z^2 / r^2 - 3);
    
    dydt = [v_vec; a_grav + a_j2];
    
endfunction


function [t_out, states] = propagate_orbit(r0, v0, t_span, mu, options)
    // Propagate orbit from initial state
    // INPUTS:
    //   r0     - Initial position [km] (3x1)
    //   v0     - Initial velocity [km/s] (3x1)
    //   t_span - Time span [t_start, t_end] or vector of times [s]
    //   mu     - Gravitational parameter [km^3/s^2]
    //   options - struct with optional fields:
    //             .use_j2 - %T to include J2 (%F default)
    //             .J2     - J2 coefficient
    //             .Re     - Reference radius [km]
    //             .n_steps - Number of output steps (default 1000)
    // OUTPUTS:
    //   t_out  - Time vector [s]
    //   states - 6×N matrix of states [x,y,z,vx,vy,vz]
    
    // Default options
    use_j2 = %F;
    J2_val = 0;
    Re_val = 0;
    n_steps = 1000;
    
    if exists('options', 'local') then
        if isfield(options, 'use_j2') then use_j2 = options.use_j2; end
        if isfield(options, 'J2') then J2_val = options.J2; end
        if isfield(options, 'Re') then Re_val = options.Re; end
        if isfield(options, 'n_steps') then n_steps = options.n_steps; end
    end
    
    // Initial state vector
    y0 = [r0(:); v0(:)];
    
    // Time vector
    if length(t_span) == 2 then
        t_out = linspace(t_span(1), t_span(2), n_steps);
    else
        t_out = t_span;
    end
    
    // Integrate
    if use_j2 then
        function dy = eom_j2(t, y)
            dy = two_body_j2_eom(t, y, mu, J2_val, Re_val);
        endfunction
        states = ode(y0, t_out(1), t_out, eom_j2);
    else
        function dy = eom_2body(t, y)
            dy = two_body_eom(t, y, mu);
        endfunction
        states = ode(y0, t_out(1), t_out, eom_2body);
    end
    
endfunction


function [r_mag, v_mag, a_km, e_val, i_val, h_mag] = orbit_analysis(states, mu)
    // Compute orbital parameters along a propagated trajectory
    // INPUTS:
    //   states - 6×N state matrix
    //   mu     - Gravitational parameter
    // OUTPUTS:
    //   r_mag  - Radius magnitudes [km]
    //   v_mag  - Velocity magnitudes [km/s]
    //   a_km   - Semi-major axis history [km]
    //   e_val  - Eccentricity history
    //   i_val  - Inclination history [rad]
    //   h_mag  - Angular momentum magnitude history
    
    N = size(states, 2);
    r_mag = zeros(1, N);
    v_mag = zeros(1, N);
    a_km  = zeros(1, N);
    e_val = zeros(1, N);
    i_val = zeros(1, N);
    h_mag = zeros(1, N);
    
    for k = 1:N
        r_vec = states(1:3, k);
        v_vec = states(4:6, k);
        r = norm(r_vec);
        v = norm(v_vec);
        
        r_mag(k) = r;
        v_mag(k) = v;
        
        // Angular momentum
        h_vec = cross(r_vec, v_vec);
        h_mag(k) = norm(h_vec);
        
        // Energy → semi-major axis
        energy = v^2/2 - mu/r;
        if abs(energy) > 1e-10 then
            a_km(k) = -mu / (2 * energy);
        else
            a_km(k) = %inf;
        end
        
        // Eccentricity
        e_vec = (1/mu) * ((v^2 - mu/r) * r_vec - dot(r_vec, v_vec) * v_vec);
        e_val(k) = norm(e_vec);
        
        // Inclination
        i_val(k) = acos(h_vec(3) / h_mag(k));
    end
    
endfunction
