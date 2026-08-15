// OrbitalMDT :: Kepler Equation Solver
// Newton-Raphson for elliptic (M = E - e*sin(E)),
// hyperbolic (M = e*sinh(H) - H), and parabolic (Barker's equation).

function [E, info] = solve_kepler(M, e, tol)
    // Solve Kepler's equation for eccentric/hyperbolic anomaly.
    // INPUTS:
    //   M   - mean anomaly [rad]
    //   e   - eccentricity (>=0)
    //   tol - convergence tolerance (default 1e-12)
    // OUTPUTS:
    //   E    - eccentric anomaly [rad] (hyperbolic anomaly if e>1)
    //   info - struct {converged, iterations, residual}

    if ~exists('tol', 'local') then tol = 1e-12; end

    max_iter = 50;
    info.converged  = %F;
    info.iterations = 0;
    info.residual   = %inf;

    if e < 0 then
        E = M;
        return;
    end

    if e < 1.0 then
        // --- Elliptic ---
        M = modulo(M, 2*%pi);
        if M < 0 then M = M + 2*%pi; end

        if M < %pi then
            E = M + e / 2;
        else
            E = M - e / 2;
        end

        for k = 1:max_iter
            f  = E - e * sin(E) - M;
            fp = 1 - e * cos(E);
            if abs(fp) < 1e-30 then break; end
            dE = f / fp;
            E  = E - dE;
            info.iterations = k;
            info.residual   = abs(dE);
            if abs(dE) < tol then
                info.converged = %T;
                return;
            end
        end

    elseif e > 1.0 then
        // --- Hyperbolic ---
        if abs(M) < 1e-14 then
            E = 0;
            info.converged = %T;
            return;
        end

        H = M / (e - 1);
        if abs(H) > 30 then H = sign(M) * log(2 * abs(M) / e); end

        for k = 1:max_iter
            f  = e * sinh(H) - H - M;
            fp = e * cosh(H) - 1;
            if abs(fp) < 1e-30 then break; end
            dH = f / fp;
            H  = H - dH;
            info.iterations = k;
            info.residual   = abs(dH);
            if abs(dH) < tol then
                info.converged = %T;
                E = H;
                return;
            end
        end
        E = H;

    else
        // --- Parabolic (e = 1) ---
        W = 3 * M;
        Y = (W + sqrt(W^2 + 1))^(1/3);
        E = Y - 1/Y;
        info.converged  = %T;
        info.iterations = 0;
        info.residual   = 0;
    end
endfunction


function nu = eccentric_to_true(E, e)
    // Eccentric anomaly -> true anomaly [rad].

    if e < 1.0 then
        nu = 2 * atan(sqrt((1 + e) / (1 - e)) * tan(E / 2));
        if nu < 0 then nu = nu + 2*%pi; end
    elseif e > 1.0 then
        nu = 2 * atan(sqrt((e + 1) / (e - 1)) * tanh(E / 2));
    else
        nu = 2 * atan(E);
    end
endfunction


function M = true_to_mean(nu, e)
    // True anomaly -> mean anomaly [rad].

    if e < 1.0 then
        E = 2 * atan(sqrt((1 - e) / (1 + e)) * tan(nu / 2));
        M = E - e * sin(E);
        if M < 0 then M = M + 2*%pi; end
    elseif e > 1.0 then
        H = 2 * atanh(sqrt((e - 1) / (e + 1)) * tan(nu / 2));
        M = e * sinh(H) - H;
    else
        D = tan(nu / 2);
        M = D + D^3 / 3;
    end
endfunction
