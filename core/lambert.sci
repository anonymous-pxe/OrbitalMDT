// OrbitalMDT :: Lambert Problem Solver
// Universal Variable formulation with Stumpff functions.
// Ref: Curtis, "Orbital Mechanics for Engineering Students", Ch.5.
// Supports prograde (short-way) and retrograde (long-way) transfers.

function [c, s] = stumpff(z)
    // Stumpff functions C(z) and S(z).
    // Elliptic z>0, parabolic z~0, hyperbolic z<0.

    if z > 1e-6 then
        sz = sqrt(z);
        c = (1 - cos(sz)) / z;
        s = (sz - sin(sz)) / sz^3;
    elseif z < -1e-6 then
        sz = sqrt(-z);
        c = (cosh(sz) - 1) / (-z);
        s = (sinh(sz) - sz) / sz^3;
    else
        c = 1/2 - z/24 + z^2/720;
        s = 1/6 - z/120 + z^2/5040;
    end
endfunction


function [v1, v2, converged, iterations] = lambert_solver(r1_vec, r2_vec, dt, mu, direction)
    // Solve Lambert's problem.
    // INPUTS:
    //   r1_vec    [km] (3x1)    initial position
    //   r2_vec    [km] (3x1)    final position
    //   dt        [s]           time of flight (must be > 0)
    //   mu        [km^3/s^2]    gravitational parameter
    //   direction +1 prograde / -1 retrograde   (default +1)
    // OUTPUTS:
    //   v1, v2    [km/s] (3x1)  departure and arrival velocities
    //   converged %T/%F
    //   iterations number of iterations used

    if ~exists('direction', 'local') then direction = 1; end

    converged  = %F;
    iterations = 0;
    v1 = zeros(3, 1);
    v2 = zeros(3, 1);

    if dt <= 0 then return; end

    r1 = norm(r1_vec);
    r2 = norm(r2_vec);
    if r1 < 1e-10 | r2 < 1e-10 then return; end

    cross12 = cross(r1_vec, r2_vec);
    cos_dnu = dot(r1_vec, r2_vec) / (r1 * r2);
    cos_dnu = max(-1, min(1, cos_dnu));

    if direction >= 0 then
        if cross12(3) >= 0 then
            dnu = acos(cos_dnu);
        else
            dnu = 2*%pi - acos(cos_dnu);
        end
    else
        if cross12(3) < 0 then
            dnu = acos(cos_dnu);
        else
            dnu = 2*%pi - acos(cos_dnu);
        end
    end

    sin_dnu = sin(dnu);
    if abs(sin_dnu) < 1e-12 then return; end

    A = sin_dnu * sqrt(r1 * r2 / (1 - cos_dnu));

    // bisection bounds
    z_low  = -4 * %pi^2;
    z_high = 4 * %pi^2;
    z = 0;

    max_iter = 200;
    tol = 1e-10;

    for iter = 1:max_iter
        iterations = iter;
        [C, S] = stumpff(z);

        y = r1 + r2 + A * (z * S - 1) / sqrt(C);

        if y < 0 then
            // bisect upward until y >= 0
            z_low = z;
            z = (z_low + z_high) / 2;
            continue;
        end

        F = (y / C)^1.5 * S + A * sqrt(y) - sqrt(mu) * dt;

        // derivative dF/dz
        if abs(z) > 1e-6 then
            dFdz = (y / C)^1.5 * (1/(2*z) * (C - 3*S/(2*C)) + 3*S^2/(4*C)) ..
                   + (A / 8) * (3*S*sqrt(y)/C + A*sqrt(C/y));
        else
            dFdz = (sqrt(2)/40) * y^1.5 + (A/8) * (sqrt(y) + A*sqrt(1/(2*y)));
        end

        // Newton step with bisection fallback
        if abs(dFdz) < 1e-20 then
            z = (z_low + z_high) / 2;
        else
            z_new = z - F / dFdz;

            if F < 0 then
                z_low = z;
            else
                z_high = z;
            end

            // keep Newton step if within bounds, otherwise bisect
            if z_new > z_low & z_new < z_high then
                z = z_new;
            else
                z = (z_low + z_high) / 2;
            end
        end

        if abs(F) < tol then
            converged = %T;
            break;
        end
    end

    if ~converged then return; end

    // final Lagrange coefficients
    [C, S] = stumpff(z);
    y = r1 + r2 + A * (z * S - 1) / sqrt(C);

    f    = 1 - y / r1;
    g    = A * sqrt(y / mu);
    gdot = 1 - y / r2;

    v1 = (1 / g) * (r2_vec - f * r1_vec);
    v2 = (1 / g) * (gdot * r2_vec - r1_vec);
endfunction


function [dv1, dv2, dv_total, v_inf_dep, v_inf_arr] = lambert_dv( ..
        r1_vec, r2_vec, dt, v1_planet, v2_planet, mu)
    // Delta-V for an interplanetary Lambert arc.
    // v1_planet, v2_planet are the planet heliocentric velocities.

    [v1_trans, v2_trans, ok] = lambert_solver(r1_vec, r2_vec, dt, mu, 1);

    if ~ok then
        dv1 = %inf; dv2 = %inf; dv_total = %inf;
        v_inf_dep = %inf; v_inf_arr = %inf;
        return;
    end

    v_inf_dep = norm(v1_trans - v1_planet);
    v_inf_arr = norm(v2_trans - v2_planet);
    dv1 = v_inf_dep;
    dv2 = v_inf_arr;
    dv_total = dv1 + dv2;
endfunction
