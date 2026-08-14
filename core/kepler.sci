// ============================================================================
// OrbitalMDT — Kepler Equation Solver
// ============================================================================
// Solves Kepler's equation M = E - e*sin(E) using Newton-Raphson iteration.
// Handles elliptic, parabolic, and hyperbolic orbits.
// ============================================================================

function E = solve_kepler(M, e, tol)
    // Solve Kepler's equation for eccentric anomaly E
    // INPUTS:
    //   M   - Mean anomaly [rad]
    //   e   - Eccentricity
    //   tol - Convergence tolerance (default 1e-10)
    // OUTPUT:
    //   E   - Eccentric anomaly [rad] (or hyperbolic anomaly for e > 1)
    
    if ~exists('tol', 'local') then
        tol = 1e-10;
    end
    
    max_iter = 100;
    
    // Normalize M to [0, 2*pi] for elliptic case
    if e < 1.0 then
        M = modulo(M, 2*%pi);
        if M < 0 then M = M + 2*%pi; end
        
        // Initial guess (smart start)
        if M < %pi then
            E = M + e/2;
        else
            E = M - e/2;
        end
        
        // Newton-Raphson for elliptic orbit: f(E) = E - e*sin(E) - M = 0
        for i = 1:max_iter
            f  = E - e * sin(E) - M;
            fp = 1 - e * cos(E);
            dE = f / fp;
            E  = E - dE;
            if abs(dE) < tol then
                return;
            end
        end
        
    elseif e > 1.0 then
        // Hyperbolic orbit: M = e*sinh(H) - H
        if M > 0 then
            H = M + e;
        else
            H = M - e;
        end
        
        for i = 1:max_iter
            f  = e * sinh(H) - H - M;
            fp = e * cosh(H) - 1;
            dH = f / fp;
            H  = H - dH;
            if abs(dH) < tol then
                E = H;  // Return hyperbolic anomaly
                return;
            end
        end
        E = H;
        
    else
        // Parabolic case (e = 1): Use Barker's equation
        // M = D + D^3/3, solve cubic
        W = 3 * M;
        Y = (W + sqrt(W^2 + 1))^(1/3);
        E = Y - 1/Y;  // Parabolic anomaly D
    end
    
endfunction


function nu = eccentric_to_true(E, e)
    // Convert eccentric anomaly to true anomaly
    // INPUTS:
    //   E - Eccentric anomaly [rad]
    //   e - Eccentricity
    // OUTPUT:
    //   nu - True anomaly [rad]
    
    if e < 1.0 then
        // Elliptic
        nu = 2 * atan(sqrt((1+e)/(1-e)) * tan(E/2));
        if nu < 0 then nu = nu + 2*%pi; end
    elseif e > 1.0 then
        // Hyperbolic
        nu = 2 * atan(sqrt((e+1)/(e-1)) * tanh(E/2));
    else
        // Parabolic
        nu = 2 * atan(E);
    end
    
endfunction


function M = true_to_mean(nu, e)
    // Convert true anomaly to mean anomaly
    // INPUTS:
    //   nu - True anomaly [rad]
    //   e  - Eccentricity
    // OUTPUT:
    //   M  - Mean anomaly [rad]
    
    if e < 1.0 then
        // True → Eccentric
        E = 2 * atan(sqrt((1-e)/(1+e)) * tan(nu/2));
        M = E - e * sin(E);
        if M < 0 then M = M + 2*%pi; end
    elseif e > 1.0 then
        // True → Hyperbolic
        H = 2 * atanh(sqrt((e-1)/(e+1)) * tan(nu/2));
        M = e * sinh(H) - H;
    else
        D = tan(nu/2);
        M = D + D^3/3;
    end
    
endfunction
