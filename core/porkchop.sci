// OrbitalMDT :: Porkchop Plot Generator
// Delta-V contour data for interplanetary transfer windows.
// Computation is separated from plotting.

function [dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop( ..
        dep_planet, arr_planet, dep_start_jd, dep_end_jd, ..
        arr_start_jd, arr_end_jd, n_dep, n_arr)
    // INPUTS:
    //   dep_planet, arr_planet  planet IDs (1-6)
    //   dep_start_jd..arr_end_jd  Julian Date window boundaries
    //   n_dep, n_arr  grid resolution (default 40)
    // OUTPUTS:
    //   dv_grid   n_dep x n_arr  total Delta-V [km/s]
    //   c3_grid   n_dep x n_arr  departure C3 [km^2/s^2]
    //   tof_grid  n_dep x n_arr  time-of-flight [days]
    //   dep_jd, arr_jd  date vectors

    if ~exists('n_dep', 'local') then n_dep = 40; end
    if ~exists('n_arr', 'local') then n_arr = 40; end

    const = orbital_constants();

    dep_jd = linspace(dep_start_jd, dep_end_jd, n_dep);
    arr_jd = linspace(arr_start_jd, arr_end_jd, n_arr);

    dv_grid  = %inf * ones(n_dep, n_arr);
    c3_grid  = %inf * ones(n_dep, n_arr);
    tof_grid = zeros(n_dep, n_arr);

    // Precompute heliocentric planet states to optimize performance
    dep_r = zeros(3, n_dep);
    dep_v = zeros(3, n_dep);
    for i = 1:n_dep
        [r_tmp, v_tmp] = planet_state_heliocentric(dep_planet, dep_jd(i));
        dep_r(:, i) = r_tmp;
        dep_v(:, i) = v_tmp;
    end

    arr_r = zeros(3, n_arr);
    arr_v = zeros(3, n_arr);
    for j = 1:n_arr
        [r_tmp, v_tmp] = planet_state_heliocentric(arr_planet, arr_jd(j));
        arr_r(:, j) = r_tmp;
        arr_v(:, j) = v_tmp;
    end

    for i_dep = 1:n_dep
        r1 = dep_r(:, i_dep);
        v1_planet = dep_v(:, i_dep);

        for i_arr = 1:n_arr
            tof_days = arr_jd(i_arr) - dep_jd(i_dep);
            if tof_days <= 10 | tof_days > 1200 then continue; end

            tof_grid(i_dep, i_arr) = tof_days;
            tof_sec = tof_days * const.day2sec;

            r2 = arr_r(:, i_arr);
            v2_planet = arr_v(:, i_arr);

            [dv1, dv2, dv_tot, vinf_d, vinf_a] = lambert_dv( ..
                r1, r2, tof_sec, v1_planet, v2_planet, const.mu_Sun);

            dv_grid(i_dep, i_arr) = dv_tot;
            c3_grid(i_dep, i_arr) = vinf_d^2;
        end
    end

    // cap extreme values for visualization
    dv_grid(dv_grid > 30) = %inf;
    c3_grid(c3_grid > 200) = %inf;
endfunction


function res = porkchop_compute(dep_planet, arr_planet, dep_start_jd, dep_end_jd, arr_start_jd, arr_end_jd, n_dep, n_arr)
    // Structured Porkchop computation returning PorkchopResult struct.
    [dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop( ..
        dep_planet, arr_planet, dep_start_jd, dep_end_jd, arr_start_jd, arr_end_jd, n_dep, n_arr);

    [opt_dep, opt_arr, opt_dv, opt_tof] = find_optimal_window(dv_grid, dep_jd, arr_jd);

    res.departure_dates = dep_jd;
    res.arrival_dates   = arr_jd;
    res.dv_grid         = dv_grid;
    res.c3_grid         = c3_grid;
    res.tof_grid        = tof_grid;
    res.valid_grid      = (dv_grid < 30);
    res.converged_grid  = (dv_grid <> %inf);
    res.best_solution.departure_jd = opt_dep;
    res.best_solution.arrival_jd   = opt_arr;
    res.best_solution.opt_dv       = opt_dv;
    res.best_solution.opt_tof      = opt_tof;
    res.status          = 0;
endfunction



function [opt_dep_jd, opt_arr_jd, opt_dv, opt_tof] = find_optimal_window( ..
        dv_grid, dep_jd, arr_jd)
    // Minimum Delta-V launch window from porkchop data.

    dv_temp = dv_grid;
    dv_temp(dv_temp == %inf) = 1e10;

    [min_val, idx] = min(dv_temp);
    i_dep = idx(1);
    i_arr = idx(2);

    opt_dep_jd = dep_jd(i_dep);
    opt_arr_jd = arr_jd(i_arr);
    opt_dv     = dv_grid(i_dep, i_arr);
    opt_tof    = opt_arr_jd - opt_dep_jd;
endfunction


function plot_porkchop(dv_grid, dep_jd, arr_jd, dep_planet_name, arr_planet_name)
    // Plot porkchop contour.

    dep_days = dep_jd - dep_jd(1);
    arr_days = arr_jd - arr_jd(1);

    dv_plot = dv_grid;
    valid_dv = dv_plot(dv_plot <> %inf & ~isnan(dv_plot));
    if size(valid_dv, "*") > 0 then
        dv_min = min(valid_dv);
        dv_max_plot = min(max(valid_dv), 30);
        if dv_max_plot <= dv_min then dv_max_plot = dv_min + 10; end
        levels = linspace(dv_min, dv_max_plot, 16);
    else
        dv_min = 5;
        dv_max_plot = 30;
        levels = linspace(5, 30, 16);
    end

    // Replace out-of-bounds / infinite cells with dv_max_plot to eliminate black artifacts
    dv_plot(dv_plot == %inf | isnan(dv_plot) | dv_plot > dv_max_plot) = dv_max_plot;

    // Safe figure/axes initialization: do not clear the whole GUI if invoked within OrbitalMDT
    is_gui = %F;
    try
        f_cur = gcf();
        if is_valid_handle(f_cur) then
            if f_cur.tag == 'main_fig' then
                is_gui = %T;
            end
        end
    catch
    end

    if is_gui then
        clear_plot_axes();
        newaxes();
        gca().axes_bounds = [0.33, 0.10, 0.58, 0.82];
    else
        clf();
    end
    try
        try
            gcf().color_map = jet(64);
        catch
            gcf().color_map = jetcolormap(64);
        end
        gcf().background = -2;
        gca().background = -2;
    catch
    end

    contourf(dep_days, arr_days, dv_plot, levels);
    colorbar(min(levels), max(levels));

    xlabel("Departure (days from start)");
    ylabel("Arrival (days from start)");
    title(dep_planet_name + " -> " + arr_planet_name + " Porkchop Plot (Delta-V km/s)");

    [opt_dep, opt_arr, opt_dv_val, tof_tmp] = find_optimal_window(dv_grid, dep_jd, arr_jd);
    plot(opt_dep - dep_jd(1), opt_arr - arr_jd(1), 'rp', 'MarkerSize', 12);

    for tof = [100, 200, 300, 400, 500]
        x_line = dep_days;
        y_line = x_line + tof;
        mask = (y_line >= min(arr_days)) & (y_line <= max(arr_days));
        if sum(mask) > 1 then
            plot(x_line(mask), y_line(mask), 'k--');
        end
    end
endfunction
