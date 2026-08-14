// ============================================================================
// OrbitalMDT — Porkchop Plot Generator
// ============================================================================
// Generates ΔV contour data for interplanetary transfer windows.
// Sweeps departure/arrival dates and solves Lambert's problem for each pair.
// ============================================================================

function [dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop(...
    dep_planet, arr_planet, dep_start_jd, dep_end_jd, arr_start_jd, arr_end_jd, n_dep, n_arr)
    // Generate porkchop plot data
    // INPUTS:
    //   dep_planet   - Departure planet ID (1-6)
    //   arr_planet   - Arrival planet ID (1-6)
    //   dep_start_jd - Departure window start (Julian Date)
    //   dep_end_jd   - Departure window end (Julian Date)
    //   arr_start_jd - Arrival window start (Julian Date)
    //   arr_end_jd   - Arrival window end (Julian Date)
    //   n_dep        - Number of departure date samples (default 40)
    //   n_arr        - Number of arrival date samples (default 40)
    // OUTPUTS:
    //   dv_grid  - n_dep × n_arr matrix of total ΔV [km/s]
    //   c3_grid  - n_dep × n_arr matrix of C3 [km²/s²]
    //   tof_grid - n_dep × n_arr matrix of time-of-flight [days]
    //   dep_jd   - Vector of departure Julian Dates
    //   arr_jd   - Vector of arrival Julian Dates
    
    if ~exists('n_dep', 'local') then n_dep = 40; end
    if ~exists('n_arr', 'local') then n_arr = 40; end
    
    const = orbital_constants();
    
    // Create date grids
    dep_jd = linspace(dep_start_jd, dep_end_jd, n_dep);
    arr_jd = linspace(arr_start_jd, arr_end_jd, n_arr);
    
    // Initialize output grids
    dv_grid  = %inf * ones(n_dep, n_arr);
    c3_grid  = %inf * ones(n_dep, n_arr);
    tof_grid = zeros(n_dep, n_arr);
    
    // Sweep over all departure/arrival combinations
    for i_dep = 1:n_dep
        // Get departure planet state
        [r1, v1_planet] = planet_state_heliocentric(dep_planet, dep_jd(i_dep));
        
        for i_arr = 1:n_arr
            // Skip if arrival before departure
            tof_days = arr_jd(i_arr) - dep_jd(i_dep);
            if tof_days <= 10 then
                continue;
            end
            
            tof_grid(i_dep, i_arr) = tof_days;
            tof_seconds = tof_days * const.day2sec;
            
            // Get arrival planet state
            [r2, v2_planet] = planet_state_heliocentric(arr_planet, arr_jd(i_arr));
            
            // Solve Lambert's problem
            [dv1, dv2, dv_total, v_inf_dep, v_inf_arr] = lambert_dv(...
                r1, r2, tof_seconds, v1_planet, v2_planet, const.mu_Sun);
            
            // Store results
            dv_grid(i_dep, i_arr) = dv_total;
            c3_grid(i_dep, i_arr) = v_inf_dep^2;
            
        end
    end
    
    // Cap extreme values for better visualization
    dv_max = 30;  // km/s
    dv_grid(dv_grid > dv_max) = %inf;
    c3_grid(c3_grid > 200) = %inf;
    
endfunction


function [opt_dep_jd, opt_arr_jd, opt_dv, opt_tof] = find_optimal_window(dv_grid, dep_jd, arr_jd)
    // Find the optimal (minimum ΔV) launch window from porkchop data
    // OUTPUTS:
    //   opt_dep_jd - Optimal departure Julian Date
    //   opt_arr_jd - Optimal arrival Julian Date
    //   opt_dv     - Minimum total ΔV [km/s]
    //   opt_tof    - Corresponding time-of-flight [days]
    
    // Replace inf with large number for min search
    dv_temp = dv_grid;
    dv_temp(dv_temp == %inf) = 1e10;
    
    [min_val, idx] = min(dv_temp);
    
    // idx gives [row, col]
    i_dep = idx(1);
    i_arr = idx(2);
    
    opt_dep_jd = dep_jd(i_dep);
    opt_arr_jd = arr_jd(i_arr);
    opt_dv     = dv_grid(i_dep, i_arr);
    opt_tof    = opt_arr_jd - opt_dep_jd;
    
endfunction


function plot_porkchop(dv_grid, dep_jd, arr_jd, dep_planet_name, arr_planet_name)
    // Plot the porkchop contour
    // INPUTS:
    //   dv_grid         - ΔV data matrix
    //   dep_jd          - Departure Julian Dates
    //   arr_jd          - Arrival Julian Dates
    //   dep_planet_name - Name of departure planet
    //   arr_planet_name - Name of arrival planet
    
    // Convert JD to days from start for axis labels
    dep_days = dep_jd - dep_jd(1);
    arr_days = arr_jd - arr_jd(1);
    
    // Replace inf for contouring
    dv_plot = dv_grid;
    dv_plot(dv_plot == %inf) = %nan;
    
    // Determine contour levels
    valid_dv = dv_plot(~isnan(dv_plot));
    if length(valid_dv) > 0 then
        dv_min = min(valid_dv);
        dv_max_plot = min(max(valid_dv), 30);
        levels = linspace(dv_min, dv_max_plot, 15);
    else
        levels = linspace(5, 30, 15);
    end
    
    // Plot
    clf();
    contourf(dep_days, arr_days, dv_plot', levels);
    colorbar(min(levels), max(levels));
    
    xlabel("Departure (days from start)");
    ylabel("Arrival (days from start)");
    title(dep_planet_name + " → " + arr_planet_name + " Porkchop Plot (ΔV km/s)");
    
    // Find and mark optimal point
    [opt_dep, opt_arr, opt_dv, ~] = find_optimal_window(dv_grid, dep_jd, arr_jd);
    opt_dep_day = opt_dep - dep_jd(1);
    opt_arr_day = opt_arr - arr_jd(1);
    
    plot(opt_dep_day, opt_arr_day, 'rp', 'MarkerSize', 12);
    
    // Add time-of-flight isolines
    for tof = [100, 200, 300, 400, 500]
        x_line = dep_days;
        y_line = x_line + tof;
        valid = (y_line >= min(arr_days)) & (y_line <= max(arr_days));
        if sum(valid) > 1 then
            plot(x_line(valid), y_line(valid), 'k--');
        end
    end
    
endfunction
