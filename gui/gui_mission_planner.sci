// OrbitalMDT :: Mission Planner Tab (Porkchop Plot)

function build_mission_planner_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

    uicontrol(fig, 'style', 'text', 'string', '[*] MISSION PARAMETERS', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.2, 0.4, 0.8], 'tag', 'content_mp_title');

    // departure planet
    uicontrol(fig, 'style', 'text', 'string', 'Departure Planet:', ..
        'position', [x_panel, y_base+630, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl1');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Mercury|Venus|Earth|Mars|Jupiter|Saturn', ..
        'position', [x_panel+135, y_base+628, 140, 25], 'fontsize', 10, ..
        'value', 3, 'tag', 'content_mp_dep_planet');

    // arrival planet
    uicontrol(fig, 'style', 'text', 'string', 'Arrival Planet:', ..
        'position', [x_panel, y_base+598, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl2');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Mercury|Venus|Earth|Mars|Jupiter|Saturn', ..
        'position', [x_panel+135, y_base+596, 140, 25], 'fontsize', 10, ..
        'value', 4, 'tag', 'content_mp_arr_planet');

    // departure window
    uicontrol(fig, 'style', 'text', 'string', '-- Departure Window --', ..
        'position', [x_panel, y_base+565, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_mp_lbl3');

    uicontrol(fig, 'style', 'text', 'string', 'Start (YYYY MM DD):', ..
        'position', [x_panel, y_base+540, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl4');
    uicontrol(fig, 'style', 'edit', 'string', '2028 5 1', ..
        'position', [x_panel+140, y_base+538, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_dep_start');

    uicontrol(fig, 'style', 'text', 'string', 'End (YYYY MM DD):', ..
        'position', [x_panel, y_base+510, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl5');
    uicontrol(fig, 'style', 'edit', 'string', '2028 11 30', ..
        'position', [x_panel+140, y_base+508, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_dep_end');

    // arrival window
    uicontrol(fig, 'style', 'text', 'string', '-- Arrival Window --', ..
        'position', [x_panel, y_base+475, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_mp_lbl6');

    uicontrol(fig, 'style', 'text', 'string', 'Start (YYYY MM DD):', ..
        'position', [x_panel, y_base+450, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl7');
    uicontrol(fig, 'style', 'edit', 'string', '2029 1 1', ..
        'position', [x_panel+140, y_base+448, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_arr_start');

    uicontrol(fig, 'style', 'text', 'string', 'End (YYYY MM DD):', ..
        'position', [x_panel, y_base+420, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl8');
    uicontrol(fig, 'style', 'edit', 'string', '2029 8 30', ..
        'position', [x_panel+140, y_base+418, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_arr_end');

    // grid resolution
    uicontrol(fig, 'style', 'text', 'string', 'Grid Resolution:', ..
        'position', [x_panel, y_base+385, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl9');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', '20x20 (Fast)|30x30 (Medium)|40x40 (Fine)|50x50 (High)', ..
        'position', [x_panel+135, y_base+383, 140, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_mp_resolution');

    // generate button
    uicontrol(fig, 'style', 'pushbutton', ..
        'string', 'GENERATE PORKCHOP PLOT', ..
        'position', [x_panel, y_base+345, pw, 32], ..
        'fontsize', 11, 'fontweight', 'bold', ..
        'background', [0.2, 0.5, 0.9], 'foreground', [1, 1, 1], ..
        'callback', 'cb_generate_porkchop()', ..
        'tag', 'content_mp_generate');

    // results
    uicontrol(fig, 'style', 'text', 'string', '[*] OPTIMAL WINDOW RESULTS', ..
        'position', [x_panel, y_base+315, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.1, 0.6, 0.2], 'tag', 'content_mp_res_title');

    init_res = ['Departure:     --'; ..
                'Arrival:       --'; ..
                'Delta-V Total: --'; ..
                'C3 Departure:  --'; ..
                'TOF:           --'; ..
                'Vinf Depart:   --'; ..
                'Vinf Arrive:   --'];

    for k = 1:7
        uicontrol(fig, 'style', 'text', 'string', init_res(k,:), ..
            'position', [x_panel, y_base+315-k*21, pw, 18], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', ..
            'tag', 'content_mp_result_' + string(k));
    end

    // action buttons
    uicontrol(fig, 'style', 'pushbutton', 'string', 'Launch Windows', ..
        'position', [x_panel, y_base+145, pw/2-5, 28], 'fontsize', 10, ..
        'callback', 'cb_show_launch_windows()', 'tag', 'content_mp_windows');
    uicontrol(fig, 'style', 'pushbutton', 'string', 'Export Data (CSV)', ..
        'position', [x_panel+pw/2+5, y_base+145, pw/2-5, 28], 'fontsize', 10, ..
        'callback', 'cb_export_porkchop()', 'tag', 'content_mp_export');

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: Standish (1992) Ephemeris, Patched-Conics, Single-Rev Lambert', ..
        'position', [x_panel, y_base+122, pw, 18], 'fontsize', 8, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_mp_assumptions');

    // plot placeholder
    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Porkchop Plot will appear here after generation', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_mp_plot_placeholder');
endfunction


function cb_generate_porkchop()

    dep_id = get_tag_val('content_mp_dep_planet', 3);
    arr_id = get_tag_val('content_mp_arr_planet', 4);

    if dep_id == arr_id then
        gui_report_error('Departure and arrival planets must be distinct.');
        return;
    end

    // parse & validate dates
    [ds_y, ds_m, ds_d, ok1, m1] = parse_date_str(get_tag_str('content_mp_dep_start', '2028 5 1'));
    if ~ok1 then gui_report_error("Departure Start: " + m1); return; end

    [de_y, de_m, de_d, ok2, m2] = parse_date_str(get_tag_str('content_mp_dep_end', '2028 11 30'));
    if ~ok2 then gui_report_error("Departure End: " + m2); return; end

    [as_y, as_m, as_d, ok3, m3] = parse_date_str(get_tag_str('content_mp_arr_start', '2029 1 1'));
    if ~ok3 then gui_report_error("Arrival Start: " + m3); return; end

    [ae_y, ae_m, ae_d, ok4, m4] = parse_date_str(get_tag_str('content_mp_arr_end', '2029 8 30'));
    if ~ok4 then gui_report_error("Arrival End: " + m4); return; end

    dep_start_jd = date_to_jd(ds_y, ds_m, ds_d);
    dep_end_jd   = date_to_jd(de_y, de_m, de_d);
    arr_start_jd = date_to_jd(as_y, as_m, as_d);
    arr_end_jd   = date_to_jd(ae_y, ae_m, ae_d);

    if dep_start_jd >= dep_end_jd then
        gui_report_error('Departure Start Date must be earlier than Departure End Date.');
        return;
    end

    if arr_start_jd >= arr_end_jd then
        gui_report_error('Arrival Start Date must be earlier than Arrival End Date.');
        return;
    end

    if dep_start_jd >= arr_end_jd then
        gui_report_error('Departure window must be earlier than arrival window.');
        return;
    end

    update_status('Generating porkchop plot... Computing orbital arcs.');

    res_val = get_tag_val('content_mp_resolution', 1);
    res_map = [20, 30, 40, 50];
    n_grid = res_map(res_val);

    try
        [dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop( ..
            dep_id, arr_id, dep_start_jd, dep_end_jd, arr_start_jd, arr_end_jd, n_grid, n_grid);
    catch
        gui_report_error("Porkchop generation error: " + lasterror());
        return;
    end

    [opt_dep, opt_arr, opt_dv, opt_tof] = find_optimal_window(dv_grid, dep_jd, arr_jd);

    const = orbital_constants();
    dep_name = const.planet_names(dep_id);
    arr_name = const.planet_names(arr_id);

    [dy, dm, dd] = jd_to_date(opt_dep);
    dep_date_str = msprintf('%d-%02d-%02d', dy, floor(dm), floor(dd));
    [ay, am, ad] = jd_to_date(opt_arr);
    arr_date_str = msprintf('%d-%02d-%02d', ay, floor(am), floor(ad));

    // find C3 at optimal cell
    dv_temp = dv_grid;
    dv_temp(dv_temp == %inf) = 1e10;
    [mtmp, idx] = min(dv_temp);
    opt_c3 = c3_grid(idx(1), idx(2));

    // compute vectors for optimal solution to update App State
    [r1_opt, v1_opt] = planet_state_heliocentric(dep_id, opt_dep);
    [r2_opt, v2_opt] = planet_state_heliocentric(arr_id, opt_arr);
    tof_sec_opt = opt_tof * const.day2sec;
    [v1_trans_opt, v2_trans_opt, ok_opt] = lambert_solver(r1_opt, r2_opt, tof_sec_opt, const.mu_Sun, 1);

    vinf_dep = norm(v1_trans_opt - v1_opt);
    vinf_arr = norm(v2_trans_opt - v2_opt);

    set(findobj('tag', 'content_mp_result_1'), 'string', ..
        'Departure:     ' + dep_date_str);
    set(findobj('tag', 'content_mp_result_2'), 'string', ..
        'Arrival:       ' + arr_date_str);
    set(findobj('tag', 'content_mp_result_3'), 'string', ..
        msprintf('Delta-V Total: %.4f km/s', opt_dv));
    set(findobj('tag', 'content_mp_result_4'), 'string', ..
        msprintf('C3 Departure:  %.3f km^2/s^2', opt_c3));
    set(findobj('tag', 'content_mp_result_5'), 'string', ..
        msprintf('TOF:           %.0f days', opt_tof));
    set(findobj('tag', 'content_mp_result_6'), 'string', ..
        msprintf('Vinf Depart:   %.4f km/s', vinf_dep));
    set(findobj('tag', 'content_mp_result_7'), 'string', ..
        msprintf('Vinf Arrive:   %.4f km/s', vinf_arr));

    ph = findobj('tag', 'content_mp_plot_placeholder');
    if ph <> [] then
        for p_idx = 1:size(ph, "*")
            try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
        end
    end

    a = gui_create_plot_axes([0.33, 0.10, 0.58, 0.82]);
    sca(a);

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

    contourf(dep_days, arr_days, dv_plot, levels);

    // plot optimal point
    plot(opt_dep - dep_jd(1), opt_arr - arr_jd(1), 'rp', 'MarkerSize', 12);

    // plot TOF contour lines
    for tof_line = [100, 150, 200, 250, 300, 350, 400, 450, 500]
        x_l = dep_days;
        y_l = x_l + tof_line;
        mask = (y_l >= min(arr_days)) & (y_l <= max(arr_days));
        if sum(mask) > 1 then
            plot(x_l(mask), y_l(mask), 'k--');
        end
    end

    xlabel('Departure [days from start]');
    ylabel('Arrival [days from start]');
    title(msprintf('%s -> %s Porkchop Plot (Delta-V km/s)', dep_name, arr_name));

    try
        colorbar(min(levels), max(levels));
    catch
    end

    // sync optimal solution to Central Mission State
    st_upd.departurePlanet = dep_id;
    st_upd.arrivalPlanet   = arr_id;
    st_upd.dep_year        = dy;
    st_upd.dep_month       = floor(dm);
    st_upd.dep_day         = floor(dd);
    st_upd.arr_year        = ay;
    st_upd.arr_month       = floor(am);
    st_upd.arr_day         = floor(ad);
    st_upd.dep_jd          = opt_dep;
    st_upd.arr_jd          = opt_arr;
    st_upd.tof_days        = opt_tof;
    st_upd.r1_vec          = r1_opt;
    st_upd.r2_vec          = r2_opt;
    st_upd.v1_trans        = v1_trans_opt;
    st_upd.v2_trans        = v2_trans_opt;
    st_upd.c3_dep          = opt_c3;
    st_upd.v_inf_dep       = vinf_dep;
    st_upd.v_inf_arr       = vinf_arr;
    st_upd.dv_total        = opt_dv;
    st_upd.dv_req          = opt_dv;
    st_upd.converged       = ok_opt;

    update_app_state(st_upd);

    update_status(msprintf('Porkchop complete! Synced to Mission State. Optimal: %s -> %s, dV=%.3f km/s, TOF=%.0f d', ..
        dep_date_str, arr_date_str, opt_dv, opt_tof));
endfunction


function cb_show_launch_windows()

    dep_id = get_tag_val('content_mp_dep_planet', 3);
    arr_id = get_tag_val('content_mp_arr_planet', 4);

    if dep_id == arr_id then
        gui_report_error('Departure and arrival planets must be distinct.');
        return;
    end

    try
        result = launch_window_analysis(dep_id, arr_id, 2026, 8);
    catch
        gui_report_error("Failed to compute synodic launch windows: " + lasterror());
        return;
    end

    const = orbital_constants();

    msg = msprintf('%s -> %s Launch Windows\n', const.planet_names(dep_id), const.planet_names(arr_id));
    msg = msg + msprintf('Synodic Period: %.1f days (%.2f years)\n\n', ..
        result.synodic_period.T_synodic_days, result.synodic_period.T_synodic_years);

    for k = 1:result.n_windows
        wd = result.window_dates(k);
        msg = msg + msprintf('Window %d: %d-%02d-%02d\n', k, wd.year, wd.month, wd.day);
    end

    messagebox(msg, 'Launch Windows', 'info');
endfunction


function cb_export_porkchop()
    st = get_app_state();
    if st.dv_total == 0 then
        messagebox('No porkchop data to export. Generate a porkchop plot first.', 'Export', 'warning');
        return;
    end

    fname = uiputfile(['*.csv', 'CSV Files (*.csv)'], '', 'porkchop_export.csv');
    if fname == '' then return; end

    const = orbital_constants();
    dep_name = const.planet_names(st.departurePlanet);
    arr_name = const.planet_names(st.arrivalPlanet);

    [fd, err] = mopen(fname, 'w');
    if err <> 0 then
        messagebox('Could not open file for writing: ' + fname, 'Export Error', 'error');
        return;
    end

    mfprintf(fd, 'OrbitalMDT Porkchop Mission Export\n');
    mfprintf(fd, 'Route,%s -> %s\n', dep_name, arr_name);
    mfprintf(fd, 'Departure Date,%d-%02d-%02d\n', st.dep_year, st.dep_month, st.dep_day);
    mfprintf(fd, 'Arrival Date,%d-%02d-%02d\n', st.arr_year, st.arr_month, st.arr_day);
    mfprintf(fd, 'Optimal Delta-V (km/s),%.4f\n', st.dv_total);
    mfprintf(fd, 'C3 Departure (km2/s2),%.4f\n', st.c3_dep);
    mfprintf(fd, 'V-inf Departure (km/s),%.4f\n', st.v_inf_dep);
    mfprintf(fd, 'V-inf Arrival (km/s),%.4f\n', st.v_inf_arr);
    mfprintf(fd, 'TOF (days),%.1f\n', st.tof_days);
    mfprintf(fd, '\nDeparture Position (km),%.4f,%.4f,%.4f\n', st.r1_vec(1), st.r1_vec(2), st.r1_vec(3));
    mfprintf(fd, 'Arrival Position (km),%.4f,%.4f,%.4f\n', st.r2_vec(1), st.r2_vec(2), st.r2_vec(3));
    mfprintf(fd, 'Transfer V1 (km/s),%.6f,%.6f,%.6f\n', st.v1_trans(1), st.v1_trans(2), st.v1_trans(3));
    mfprintf(fd, 'Transfer V2 (km/s),%.6f,%.6f,%.6f\n', st.v2_trans(1), st.v2_trans(2), st.v2_trans(3));

    mclose(fd);
    update_status('Exported mission data to ' + fname);
    messagebox('Mission data exported to:\n' + fname, 'Export Complete', 'info');
endfunction
