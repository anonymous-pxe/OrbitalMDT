// OrbitalMDT :: Orbit Propagator Tab

function build_propagator_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

    uicontrol(fig, 'style', 'text', 'string', '[*] ORBIT PROPAGATOR', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.6, 0.2, 0.8], 'tag', 'content_op_title');

    uicontrol(fig, 'style', 'text', 'string', 'Input Mode:', ..
        'position', [x_panel, y_base+635, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_op_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Orbital Elements|State Vector (r,v)', ..
        'position', [x_panel+120, y_base+633, 155, 25], 'fontsize', 10, ..
        'tag', 'content_op_mode');

    oe_labels = ['SMA a (km):', 'Eccentricity e:', 'Inclination i (deg):', ..
                 'RAAN (deg):', 'Arg. Periapsis w (deg):', 'True Anomaly nu (deg):'];
    oe_defaults = ['6771', '0.001', '51.6', '0', '0', '0'];

    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', oe_labels(k), ..
            'position', [x_panel, y_base+610-(k-1)*28, 150, 20], 'fontsize', 10, ..
            'horizontalalignment', 'left', 'tag', 'content_op_lbl_oe' + string(k));
        uicontrol(fig, 'style', 'edit', 'string', oe_defaults(k), ..
            'position', [x_panel+155, y_base+608-(k-1)*28, 120, 25], 'fontsize', 10, ..
            'tag', 'content_op_oe' + string(k));
    end

    uicontrol(fig, 'style', 'text', 'string', '-- Propagation Settings --', ..
        'position', [x_panel, y_base+435, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_op_lbl_set');

    uicontrol(fig, 'style', 'text', 'string', 'Duration:', ..
        'position', [x_panel, y_base+408, 100, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_dur');
    uicontrol(fig, 'style', 'edit', 'string', '5', ..
        'position', [x_panel+100, y_base+406, 80, 25], 'fontsize', 10, ..
        'tag', 'content_op_duration');
    uicontrol(fig, 'style', 'popupmenu', 'string', 'orbits|hours|days', ..
        'position', [x_panel+185, y_base+406, 90, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_op_dur_unit');

    uicontrol(fig, 'style', 'checkbox', 'string', ' Include J2 perturbation', ..
        'position', [x_panel, y_base+378, 200, 22], 'fontsize', 10, ..
        'value', 0, 'tag', 'content_op_j2');

    uicontrol(fig, 'style', 'text', 'string', 'Central Body:', ..
        'position', [x_panel, y_base+352, 100, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_body');
    uicontrol(fig, 'style', 'popupmenu', 'string', 'Earth|Mars|Moon|Sun', ..
        'position', [x_panel+100, y_base+350, 175, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_op_body');

    uicontrol(fig, 'style', 'text', 'string', 'Plot Type:', ..
        'position', [x_panel, y_base+322, 100, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_plot');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', '3D Orbit|Ground Track|Altitude vs Time|Velocity vs Time|Elements vs Time', ..
        'position', [x_panel+100, y_base+320, 175, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_op_plottype');

    uicontrol(fig, 'style', 'text', 'string', 'Presets:', ..
        'position', [x_panel, y_base+292, 80, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_preset');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|ISS|GPS|GEO|Molniya|Sun-Sync', ..
        'position', [x_panel+80, y_base+290, 195, 25], 'fontsize', 10, ..
        'tag', 'content_op_preset', 'callback', 'cb_propagator_preset()');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'PROPAGATE ORBIT', ..
        'position', [x_panel, y_base+250, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.6, 0.2, 0.8], 'foreground', [1, 1, 1], ..
        'callback', 'cb_propagate_orbit()', 'tag', 'content_op_propagate');

    uicontrol(fig, 'style', 'text', 'string', '[*] ORBIT PARAMETERS', ..
        'position', [x_panel, y_base+220, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.5, 0.1, 0.7], 'tag', 'content_op_res_title');

    rl = ['Period:       --          '; ..
          'Apoapsis:     --          '; ..
          'Periapsis:    --          '; ..
          'V at peri:    --          '; ..
          'V at apo:     --          '; ..
          'Sp. Energy:   --          '; ..
          'Ang. Mom:     --          '];

    for k = 1:7
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+220-k*22, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_op_result_' + string(k));
    end

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: Numerical Adams Integrator, 2-Body + J2 Dynamic Oblateness', ..
        'position', [x_panel, y_base+38, pw, 18], 'fontsize', 8, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_op_assumptions');

    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Orbit visualization will appear here', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_op_plot_placeholder');
endfunction


function cb_propagator_preset()
    preset = get(findobj('tag', 'content_op_preset'), 'value');
    select preset
    case 2, vals = ['6771', '0.0006', '51.6', '0', '0', '0'];
    case 3, vals = ['26560', '0.01', '55.0', '0', '0', '0'];
    case 4, vals = ['42164', '0.0001', '0.1', '0', '0', '0'];
    case 5, vals = ['26600', '0.74', '63.4', '0', '270', '0'];
    case 6, vals = ['7078', '0.001', '98.2', '0', '0', '0'];
    else, return;
    end
    for k = 1:6
        set(findobj('tag', 'content_op_oe' + string(k)), 'string', vals(k));
    end
endfunction


function cb_propagate_orbit()

    const = orbital_constants();

    [a, oka, ma] = gui_get_positive_num('content_op_oe1', 'Semi-Major Axis a');
    if ~oka then gui_report_error(ma); return; end

    [e_val, oke, me] = gui_get_num('content_op_oe2', 'Eccentricity e', 0, 0.999);
    if ~oke then gui_report_error(me); return; end

    [i_deg, oki, mi] = gui_get_num('content_op_oe3', 'Inclination i', 0, 180);
    if ~oki then gui_report_error(mi); return; end

    [RAAN_deg, okr, mr] = gui_get_num('content_op_oe4', 'RAAN', -360, 360);
    if ~okr then gui_report_error(mr); return; end

    [omega_deg, okw, mw] = gui_get_num('content_op_oe5', 'Argument of Periapsis', -360, 360);
    if ~okw then gui_report_error(mw); return; end

    [nu_deg, okn, mn] = gui_get_num('content_op_oe6', 'True Anomaly', -360, 360);
    if ~okn then gui_report_error(mn); return; end

    body_id = get(findobj('tag', 'content_op_body'), 'value');
    select body_id
    case 1, mu = const.mu_Earth; R_body = const.Re_Earth; J2_val = const.J2_Earth;
    case 2, mu = const.mu_Mars;  R_body = const.R_Mars;   J2_val = const.J2_Mars;
    case 3, mu = const.mu_Moon;  R_body = const.R_Moon;   J2_val = 0;
    case 4, mu = const.mu_Sun;   R_body = const.R_Sun;    J2_val = 0;
    end

    // Check periapsis altitude
    r_peri = a * (1 - e_val);
    if r_peri < R_body then
        gui_report_error(msprintf("Periapsis radius (%.1f km) is below body surface (R=%.1f km). Trajectory impacts surface.", r_peri, R_body));
        return;
    end

    [dur_val, okd, md] = gui_get_positive_num('content_op_duration', 'Duration');
    if ~okd then gui_report_error(md); return; end

    dur_unit = get(findobj('tag', 'content_op_dur_unit'), 'value');
    T_orbit  = 2 * %pi * sqrt(a^3 / mu);

    select dur_unit
    case 1, t_end = dur_val * T_orbit;
    case 2, t_end = dur_val * 3600;
    case 3, t_end = dur_val * 86400;
    end

    d2r = %pi / 180;
    try
        [r0, v0] = orbital_elements_to_state(a, e_val, i_deg*d2r, RAAN_deg*d2r, ..
                                              omega_deg*d2r, nu_deg*d2r, mu);
    catch
        gui_report_error("Failed to convert orbital elements to state vectors: " + lasterror());
        return;
    end

    use_j2 = get(findobj('tag', 'content_op_j2'), 'value');
    opts.use_j2  = (use_j2 == 1);
    opts.J2      = J2_val;
    opts.Re      = R_body;
    opts.n_steps = 1000;

    update_status('Propagating orbit numerically...');
    try
        [t_out, states] = propagate_orbit(r0, v0, [0, t_end], mu, opts);
    catch
        gui_report_error("Numerical ODE propagation failed: " + lasterror());
        return;
    end

    T_min  = T_orbit / 60;
    r_apo  = a * (1 + e_val);
    v_peri = sqrt(mu * (2/r_peri - 1/a));
    v_apo  = sqrt(mu * (2/r_apo - 1/a));
    energy = -mu / (2*a);
    h_mag  = sqrt(mu * a * (1 - e_val^2));

    set(findobj('tag', 'content_op_result_1'), 'string', ..
        msprintf('Period:     %.2f min (%.2f hr)', T_min, T_min/60));
    set(findobj('tag', 'content_op_result_2'), 'string', ..
        msprintf('Apoapsis:   %.1f km (alt %.1f)', r_apo, r_apo-R_body));
    set(findobj('tag', 'content_op_result_3'), 'string', ..
        msprintf('Periapsis:  %.1f km (alt %.1f)', r_peri, r_peri-R_body));
    set(findobj('tag', 'content_op_result_4'), 'string', ..
        msprintf('V at peri:  %.4f km/s', v_peri));
    set(findobj('tag', 'content_op_result_5'), 'string', ..
        msprintf('V at apo:   %.4f km/s', v_apo));
    set(findobj('tag', 'content_op_result_6'), 'string', ..
        msprintf('Sp. Energy: %.4f km^2/s^2', energy));
    set(findobj('tag', 'content_op_result_7'), 'string', ..
        msprintf('Ang. Mom:   %.2f km^2/s', h_mag));

    ph = findobj('tag', 'content_op_plot_placeholder');
    if ph <> [] then
        for p_idx = 1:size(ph, "*")
            try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
        end
    end

    plot_type = get(findobj('tag', 'content_op_plottype'), 'value');

    ax = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);
    fig = get_main_figure();

    select plot_type
    case 1
        param3d(states(1,:), states(2,:), states(3,:));
        e_c = gce(); e_c.foreground = color(100, 50, 200); e_c.thickness = 2;
        param3d([0], [0], [0]);
        e_p = gce(); e_p.mark_mode = 'on'; e_p.mark_style = 9; e_p.mark_size = 3;
        e_p.mark_foreground = color(0, 100, 255);
        title('3D Orbit Visualization (ECI)');
        xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');

    case 2
        [lat, lon] = compute_ground_track(states, t_out, const.omega_Earth);
        seg_start = 1;
        for k = 2:size(lon, "*")
            if abs(lon(k) - lon(k-1)) > 180 then
                plot(lon(seg_start:k-1), lat(seg_start:k-1), 'b-', 'LineWidth', 2);
                seg_start = k;
            end
        end
        plot(lon(seg_start:$), lat(seg_start:$), 'b-', 'LineWidth', 2);
        plot(lon(1), lat(1), 'go', 'MarkerSize', 8);
        for lg = -120:60:120, plot([lg,lg], [-90,90], 'k:'); end
        for lt = -60:30:60, plot([-180,180], [lt,lt], 'k:'); end
        gca().data_bounds = [-180, -90; 180, 90];
        title('Ground Track (Spherical Earth)'); xlabel('Longitude [deg]'); ylabel('Latitude [deg]');

    case 3
        r_mag = sqrt(states(1,:).^2 + states(2,:).^2 + states(3,:).^2);
        plot(t_out/60, r_mag - R_body, 'b-', 'LineWidth', 1.5);
        title('Altitude vs Time'); xlabel('Time [min]'); ylabel('Altitude [km]');
        xgrid();

    case 4
        v_mag = sqrt(states(4,:).^2 + states(5,:).^2 + states(6,:).^2);
        plot(t_out/60, v_mag, 'r-', 'LineWidth', 1.5);
        title('Velocity Magnitude vs Time'); xlabel('Time [min]'); ylabel('Velocity [km/s]');
        xgrid();

    case 5
        [r_m, v_m, a_h, e_h, i_h, h_h] = orbit_analysis(states, mu);

        ax.axes_bounds = [0.32, 0.06, 0.64, 0.23];
        plot(t_out/3600, a_h, 'b-');
        title('Semi-major axis vs Time'); ylabel('a [km]'); xgrid();

        try; scf(fig); newaxes(fig); catch; newaxes(); end
        gca().axes_bounds = [0.32, 0.36, 0.64, 0.23];
        plot(t_out/3600, e_h, 'r-');
        title('Eccentricity vs Time'); ylabel('e'); xgrid();

        try; scf(fig); newaxes(fig); catch; newaxes(); end
        gca().axes_bounds = [0.32, 0.66, 0.64, 0.23];
        plot(t_out/3600, i_h*180/%pi, 'g-');
        title('Inclination vs Time'); xlabel('Time [hr]'); ylabel('i [deg]'); xgrid();
    end

    update_status(msprintf('Propagation complete. Period=%.2f min, Alt range=%.0f-%.0f km', ..
        T_min, r_peri-R_body, r_apo-R_body));
endfunction
