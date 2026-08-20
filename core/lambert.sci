// OrbitalMDT :: Lambert Problem Solver
// Universal Variable formulation with Stumpff functions.
// Ref: Curtis, "Orbital Mechanics for Engineering Students", Ch.5.
// Supports prograde (short-way) and retrograde (long-way) transfers.

function [c, s] = stumpff(z)
    // Stumpff functions C(z) and S(z).
    // Fast analytical branches for elliptic (z>0), parabolic (z~0), and hyperbolic (z<0).
    if z > 1e-6 then
        sz = sqrt(z);
        c = (1 - cos(sz)) / z;
        s = (sz - sin(sz)) / (sz * z);
    elseif z < -1e-6 then
        sz = sqrt(-z);
        c = (cosh(sz) - 1) / (-z);
        s = (sinh(sz) - sz) / (sz * (-z));
    else
        z2 = z * z;
        c = 0.5 - z / 24 + z2 / 720;
        s = 1/6 - z / 120 + z2 / 5040;
    end
endfunction


function [v1, v2, converged, iterations] = lambert_solver(r1_vec, r2_vec, dt, mu, direction)
    // Solve Lambert's boundary-value problem via Universal Variables.
    // Highly optimized Newton-Raphson solver with adaptive damping.
    // Ref: Curtis, "Orbital Mechanics for Engineering Students", Ch.5.

    if ~exists('direction', 'local') then direction = 1; end

    r1_vec = r1_vec(:);
    r2_vec = r2_vec(:);

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
    if abs(A) < 1e-12 then return; end

    sqrt_mu_dt = sqrt(mu) * dt;

    // Initial estimate for z
    z = 0;
    converged = %F;

    for iter = 1:40
        iterations = iter;
        
        // Fast inlined Stumpff calculation
        if z > 1e-6 then
            sz = sqrt(z);
            C = (1 - cos(sz)) / z;
            S = (sz - sin(sz)) / (sz * z);
        elseif z < -1e-6 then
            sz = sqrt(-z);
            C = (cosh(sz) - 1) / (-z);
            S = (sinh(sz) - sz) / (sz * (-z));
        else
            z2 = z * z;
            C = 0.5 - z / 24 + z2 / 720;
            S = 1/6 - z / 120 + z2 / 5040;
        end

        y = r1 + r2 + A * (z * S - 1) / sqrt(C);

        if y <= 0 then
            z = z * 0.5;
            continue;
        end

        sqrt_y = sqrt(y);
        y_over_C = y / C;
        y_over_C_1p5 = y_over_C * sqrt(y_over_C);

        F = y_over_C_1p5 * S + A * sqrt_y - sqrt_mu_dt;

        if abs(F) < 1e-6 * sqrt_mu_dt then
            converged = %T;
            break;
        end

        // Analytical derivative dF/dz (Curtis Eq. 5.40)
        if abs(z) > 1e-6 then
            dFdz = y_over_C_1p5 * (1/(2*z) * (C - 1.5*S/C) + 0.75*(S*S)/C) ..
                   + (A * 0.125) * (3*S*sqrt_y/C + A*sqrt(C/y));
        else
            dFdz = (sqrt(2)/40) * (y * sqrt_y) + (A * 0.125) * (sqrt_y + A * sqrt(0.5/y));
        end

        if abs(dFdz) > 1e-15 then
            z_step = F / dFdz;
            if abs(z_step) > 2.5 then
                z_step = 2.5 * sign(z_step);
            end
            z = z - z_step;
            if abs(z_step) < 1e-8 then
                converged = %T;
                break;
            end
        else
            break;
        end
    end

    if ~converged then return; end

    // Final Lagrange coefficients
    if z > 1e-6 then
        sz = sqrt(z);
        C = (1 - cos(sz)) / z;
        S = (sz - sin(sz)) / (sz * z);
    elseif z < -1e-6 then
        sz = sqrt(-z);
        C = (cosh(sz) - 1) / (-z);
        S = (sinh(sz) - sz) / (sz * (-z));
    else
        z2 = z * z;
        C = 0.5 - z / 24 + z2 / 720;
        S = 1/6 - z / 120 + z2 / 5040;
    end

    y = r1 + r2 + A * (z * S - 1) / sqrt(C);
    if y <= 0 then converged = %F; return; end

    f    = 1 - y / r1;
    g    = A * sqrt(y / mu);
    gdot = 1 - y / r2;

    if abs(g) < 1e-12 then converged = %F; return; end

    inv_g = 1 / g;
    v1 = inv_g * (r2_vec - f * r1_vec);
    v2 = inv_g * (gdot * r2_vec - r1_vec);
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


function res = lambert_solve_mission(r1_vec, r2_vec, dt, v1_planet, v2_planet, mu, direction)
    // Comprehensive Lambert solver for interplanetary mission design.
    // Returns detailed result struct with V_inf vectors, C3 energy, transfer angle, and status.

    if ~exists('direction', 'local') then direction = 1; end
    if ~exists('mu', 'local') then
        const = orbital_constants();
        mu = const.mu_Sun;
    end

    r1_vec    = r1_vec(:);
    r2_vec    = r2_vec(:);
    v1_planet = v1_planet(:);
    v2_planet = v2_planet(:);

    [v1, v2, ok, iter] = lambert_solver(r1_vec, r2_vec, dt, mu, direction);

    res.converged  = ok;
    res.iterations = iter;
    res.v1         = v1;
    res.v2         = v2;
    res.dt         = dt;

    if ~ok then
        res.v_inf_dep_vec = [%nan; %nan; %nan];
        res.v_inf_arr_vec = [%nan; %nan; %nan];
        res.v_inf_dep     = %nan;
        res.v_inf_arr     = %nan;
        res.c3_dep        = %nan;
        res.c3_arr        = %nan;
        res.dv_total      = %nan;
        res.dnu_deg       = %nan;
        return;
    end

    res.v_inf_dep_vec = v1 - v1_planet;
    res.v_inf_arr_vec = v2 - v2_planet;
    res.v_inf_dep     = norm(res.v_inf_dep_vec);
    res.v_inf_arr     = norm(res.v_inf_arr_vec);
    res.c3_dep        = res.v_inf_dep^2;
    res.c3_arr        = res.v_inf_arr^2;
    res.dv_total      = res.v_inf_dep + res.v_inf_arr;

    r1 = norm(r1_vec);
    r2 = norm(r2_vec);
    cos_dnu = max(-1, min(1, dot(r1_vec, r2_vec) / (r1 * r2)));
    res.dnu_deg = acos(cos_dnu) * 180 / %pi;
endfunction
