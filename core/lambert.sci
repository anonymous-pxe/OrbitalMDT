// ============================================================================
// OrbitalMDT — Lambert Problem Solver
// ============================================================================
// Solves Lambert's problem using the Universal Variable formulation
// with Stumpff functions. Given two position vectors and time of flight,
// determines the orbit connecting them.
// Reference: Curtis, "Orbital Mechanics for Engineering Students"
// ============================================================================

function [c, s] = stumpff(z)
    // Stumpff functions C(z) and S(z)
    // These are well-defined for all z (elliptic z>0, parabolic z=0, hyperbolic z<0)
    
    if z > 1e-6 then
        // Elliptic
        sz = sqrt(z);
        c = (1 - cos(sz)) / z;
        s = (sz - sin(sz)) / (sz^3);
    elseif z < -1e-6 then
        // Hyperbolic
        sz = sqrt(-z);
        c = (cosh(sz) - 1) / (-z);
        s = (sinh(sz) - sz) / (sz^3);
    else
        // Near-parabolic (Taylor series)
        c = 1/2 - z/24 + z^2/720;
        s = 1/6 - z/120 + z^2/5040;
    end
    
endfunction


function [v1, v2, converged] = lambert_solver(r1_vec, r2_vec, dt, mu, direction)
    // Solve Lambert's problem
    // INPUTS:
    //   r1_vec    - Initial position vector [km] (3x1)
    //   r2_vec    - Final position vector [km] (3x1)
    //   dt        - Time of flight [seconds]
    //   mu        - Gravitational parameter [km^3/s^2]
    //   direction - +1 for prograde (short way), -1 for retrograde (long way)
    // OUTPUTS:
    //   v1        - Velocity at r1 [km/s] (3x1)
    //   v2        - Velocity at r2 [km/s] (3x1)
    //   converged - %T if solution converged, %F otherwise
    
    if ~exists('direction', 'local') then direction = 1; end
    
    converged = %F;
    v1 = zeros(3,1);
    v2 = zeros(3,1);
    
    r1 = norm(r1_vec);
    r2 = norm(r2_vec);
    
    // Cross product to determine geometry
    cross12 = cross(r1_vec, r2_vec);
    
    // Transfer angle (delta_nu)
    cos_dnu = dot(r1_vec, r2_vec) / (r1 * r2);
    // Clamp for numerical safety
    cos_dnu = max(-1, min(1, cos_dnu));
    
    if direction >= 0 then
        // Prograde: short way
        if cross12(3) >= 0 then
            dnu = acos(cos_dnu);
        else
            dnu = 2*%pi - acos(cos_dnu);
        end
    else
        // Retrograde: long way
        if cross12(3) < 0 then
            dnu = acos(cos_dnu);
        else
            dnu = 2*%pi - acos(cos_dnu);
        end
    end
    
    // Geometric parameter A
    sin_dnu = sin(dnu);
    if abs(sin_dnu) < 1e-12 then
        // Degenerate case (0 or 180 degree transfer)
        return;
    end
    
    A = sin_dnu * sqrt(r1 * r2 / (1 - cos_dnu));
    
    // Newton-Raphson iteration on universal variable z
    // Initial guess
    z = 0.0;  // Start near parabolic
    
    // Find initial z bounds
    z_low  = -4 * %pi^2;
    z_high = 4 * %pi^2;
    
    max_iter = 5000;
    tol = 1e-8;
    
    for iter = 1:max_iter
        [C, S] = stumpff(z);
        
        // y(z) function
        y = r1 + r2 + A * (z * S - 1) / sqrt(C);
        
        if y < 0 then
            // Adjust z to make y positive
            // Use bisection if Newton fails
            z = z + 0.1;
            continue;
        end
        
        // chi = sqrt(y / C)
        chi = sqrt(y / C);
        
        // Time of flight equation: F(z) = [y/C]^(3/2) * S + A*sqrt(y) - sqrt(mu)*dt
        F = (y/C)^(1.5) * S + A * sqrt(y) - sqrt(mu) * dt;
        
        // Derivative dF/dz
        if abs(z) > 1e-6 then
            dFdz = (y/C)^(1.5) * (1/(2*z) * (C - 3*S/(2*C)) + 3*S^2/(4*C)) + ...
                   (A/8) * (3 * S * sqrt(y) / C + A * sqrt(C/y));
        else
            dFdz = (sqrt(2)/40) * y^(1.5) + (A/8) * (sqrt(y) + A * sqrt(1/(2*y)));
        end
        
        // Newton update
        if abs(dFdz) < 1e-20 then
            // Use bisection step instead
            z = (z_low + z_high) / 2;
        else
            z_new = z - F / dFdz;
            
            // Update bisection bounds
            if F < 0 then
                z_low = z;
            else
                z_high = z;
            end
            
            z = z_new;
        end
        
        // Check convergence
        if abs(F) < tol then
            converged = %T;
            break;
        end
    end
    
    if ~converged then
        return;
    end
    
    // Compute final y
    [C, S] = stumpff(z);
    y = r1 + r2 + A * (z * S - 1) / sqrt(C);
    
    // Lagrange coefficients
    f    = 1 - y / r1;
    g    = A * sqrt(y / mu);
    gdot = 1 - y / r2;
    
    // Velocity vectors
    v1 = (1/g) * (r2_vec - f * r1_vec);
    v2 = (1/g) * (gdot * r2_vec - r1_vec);
    
endfunction


function [dv1, dv2, dv_total, v_inf_dep, v_inf_arr] = lambert_dv(r1_vec, r2_vec, dt, ...
    v1_planet, v2_planet, mu)
    // Compute delta-V for a Lambert transfer between two planets
    // INPUTS:
    //   r1_vec    - Departure position [km]
    //   r2_vec    - Arrival position [km]
    //   dt        - Time of flight [s]
    //   v1_planet - Departure planet velocity [km/s]
    //   v2_planet - Arrival planet velocity [km/s]
    //   mu        - Central body mu [km^3/s^2]
    // OUTPUTS:
    //   dv1       - Departure delta-V magnitude [km/s]
    //   dv2       - Arrival delta-V magnitude [km/s]
    //   dv_total  - Total delta-V [km/s]
    //   v_inf_dep - Departure hyperbolic excess velocity [km/s]
    //   v_inf_arr - Arrival hyperbolic excess velocity [km/s]
    
    [v1_trans, v2_trans, ok] = lambert_solver(r1_vec, r2_vec, dt, mu, 1);
    
    if ~ok then
        dv1 = %inf;
        dv2 = %inf;
        dv_total = %inf;
        v_inf_dep = %inf;
        v_inf_arr = %inf;
        return;
    end
    
    // Hyperbolic excess velocities
    v_inf_dep_vec = v1_trans - v1_planet;
    v_inf_arr_vec = v2_trans - v2_planet;
    
    v_inf_dep = norm(v_inf_dep_vec);
    v_inf_arr = norm(v_inf_arr_vec);
    
    // For direct interplanetary, dv ≈ v_infinity magnitudes
    dv1 = v_inf_dep;
    dv2 = v_inf_arr;
    dv_total = dv1 + dv2;
    
endfunction
