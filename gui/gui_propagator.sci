// ============================================================================
// OrbitalMDT — Orbit Propagator Tab
// ============================================================================

function build_propagator_tab(fig)
    // Build the Orbit Propagator tab content
    
    y_base = 25;
    x_panel = 15;
    panel_w = 280;
    
    // ---- Title ----
    uicontrol(fig, 'style', 'text', 'string', '■ ORBIT PROPAGATOR', ...
        'position', [x_panel, y_base+660, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.6, 0.2, 0.8], 'tag', 'content_op_title');
    
    // ---- Input Mode ----
    uicontrol(fig, 'style', 'text', 'string', 'Input Mode:', ...
        'position', [x_panel, y_base+635, 120, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_op_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Orbital Elements|State Vector (r,v)', ...
        'position', [x_panel+120, y_base+633, 155, 25], 'fontsize', 10, ...
        'tag', 'content_op_mode');
    
    // ---- Orbital Elements Input ----
    oe_labels = ['SMA a (km):', 'Eccentricity e:', 'Inclination i (°):', ...
                 'RAAN Ω (°):', 'Arg. Periapsis ω (°):', 'True Anomaly ν (°):'];
    oe_defaults = ['6771', '0.001', '51.6', '0', '0', '0'];
    
    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', oe_labels(k), ...
            'position', [x_panel, y_base+610-(k-1)*28, 150, 20], 'fontsize', 10, ...
            'horizontalalignment', 'left', 'tag', 'content_op_lbl_oe' + string(k));
        uicontrol(fig, 'style', 'edit', 'string', oe_defaults(k), ...
            'position', [x_panel+155, y_base+608-(k-1)*28, 120, 25], 'fontsize', 10, ...
            'tag', 'content_op_oe' + string(k));
    end
    
    // ---- Propagation Settings ----
    uicontrol(fig, 'style', 'text', 'string', '— Propagation Settings —', ...
        'position', [x_panel, y_base+435, panel_w, 20], 'fontsize', 10, ...
        'fontweight', 'bold', 'horizontalalignment', 'center', ...
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_op_lbl_set');
    
    uicontrol(fig, 'style', 'text', 'string', 'Duration:', ...
        'position', [x_panel, y_base+408, 100, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_dur');
    uicontrol(fig, 'style', 'edit', 'string', '5', ...
        'position', [x_panel+100, y_base+406, 80, 25], 'fontsize', 10, ...
        'tag', 'content_op_duration');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'orbits|hours|days', ...
        'position', [x_panel+185, y_base+406, 90, 25], 'fontsize', 10, ...
        'value', 1, 'tag', 'content_op_dur_unit');
    
    // J2 perturbation toggle
    uicontrol(fig, 'style', 'checkbox', ...
        'string', ' Include J2 perturbation', ...
        'position', [x_panel, y_base+378, 200, 22], 'fontsize', 10, ...
        'value', 0, 'tag', 'content_op_j2');
    
    // Central body
    uicontrol(fig, 'style', 'text', 'string', 'Central Body:', ...
        'position', [x_panel, y_base+352, 100, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_body');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Earth|Mars|Moon|Sun', ...
        'position', [x_panel+100, y_base+350, 175, 25], 'fontsize', 10, ...
        'value', 1, 'tag', 'content_op_body');
    
    // Plot type
    uicontrol(fig, 'style', 'text', 'string', 'Plot Type:', ...
        'position', [x_panel, y_base+322, 100, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_plot');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', '3D Orbit|Ground Track|Altitude vs Time|Velocity vs Time|Elements vs Time', ...
        'position', [x_panel+100, y_base+320, 175, 25], 'fontsize', 10, ...
        'value', 1, 'tag', 'content_op_plottype');
    
    // ---- Quick Presets ----
    uicontrol(fig, 'style', 'text', 'string', 'Presets:', ...
        'position', [x_panel, y_base+292, 80, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_op_lbl_preset');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Custom|ISS|GPS|GEO|Molniya|Sun-Sync', ...
        'position', [x_panel+80, y_base+290, 195, 25], 'fontsize', 10, ...
        'tag', 'content_op_preset', 'callback', 'cb_propagator_preset()');
    
    // ---- Propagate Button ----
    uicontrol(fig, 'style', 'pushbutton', ...
        'string', '🌍 PROPAGATE ORBIT', ...
        'position', [x_panel, y_base+250, panel_w, 35], ...
        'fontsize', 12, 'fontweight', 'bold', ...
        'background', [0.6, 0.2, 0.8], 'foreground', [1, 1, 1], ...
        'callback', 'cb_propagate_orbit()', ...
        'tag', 'content_op_propagate');
    
    // ---- Results ----
    uicontrol(fig, 'style', 'text', 'string', '■ ORBIT PARAMETERS', ...
        'position', [x_panel, y_base+220, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.5, 0.1, 0.7], 'tag', 'content_op_res_title');
    
    res_labels = ['Period:       —           '; ...
                  'Apoapsis:     —           '; ...
                  'Periapsis:    —           '; ...
                  'V at peri:    —           '; ...
                  'V at apo:     —           '; ...
                  'Sp. Energy:   —           '; ...
                  'Ang. Mom:     —           '];
    
    for k = 1:7
        uicontrol(fig, 'style', 'text', ...
            'string', res_labels(k,:), ...
            'position', [x_panel, y_base+220-k*22, panel_w, 20], ...
            'fontsize', 9, 'horizontalalignment', 'left', ...
            'fontname', 'Consolas', ...
            'tag', 'content_op_result_' + string(k));
    end
    
    // Plot placeholder
    uicontrol(fig, 'style', 'text', ...
        'string', 'Orbit visualization will appear here', ...
        'position', [310, y_base+300, 870, 40], ...
        'fontsize', 14, 'horizontalalignment', 'center', ...
        'foreground', [0.5, 0.5, 0.6], ...
        'tag', 'content_op_plot_placeholder');
    
endfunction


function cb_propagator_preset()
    // Apply orbit presets
    preset = get(findobj('tag', 'content_op_preset'), 'value');
    
    select preset
    case 2  // ISS
        vals = ['6771', '0.0006', '51.6', '0', '0', '0'];
    case 3  // GPS
        vals = ['26560', '0.01', '55.0', '0', '0', '0'];
    case 4  // GEO
        vals = ['42164', '0.0001', '0.1', '0', '0', '0'];
    case 5  // Molniya
        vals = ['26600', '0.74', '63.4', '0', '270', '0'];
    case 6  // Sun-Synchronous
        vals = ['7078', '0.001', '98.2', '0', '0', '0'];
    else
        return;
    end
    
    for k = 1:6
        set(findobj('tag', 'content_op_oe' + string(k)), 'string', vals(k));
    end
endfunction


function cb_propagate_orbit()
    // Propagate orbit from GUI inputs
    
    const = orbital_constants();
    
    // Read orbital elements
    a     = strtod(get(findobj('tag', 'content_op_oe1'), 'string'));
    e_val = strtod(get(findobj('tag', 'content_op_oe2'), 'string'));
    i_deg = strtod(get(findobj('tag', 'content_op_oe3'), 'string'));
    RAAN_deg  = strtod(get(findobj('tag', 'content_op_oe4'), 'string'));
    omega_deg = strtod(get(findobj('tag', 'content_op_oe5'), 'string'));
    nu_deg    = strtod(get(findobj('tag', 'content_op_oe6'), 'string'));
    
    // Central body
    body_id = get(findobj('tag', 'content_op_body'), 'value');
    select body_id
    case 1, mu = const.mu_Earth; R_body = const.Re_Earth; J2_val = const.J2_Earth;
    case 2, mu = const.mu_Mars;  R_body = const.R_Mars;   J2_val = const.J2_Mars;
    case 3, mu = const.mu_Moon;  R_body = const.R_Moon;   J2_val = 0;
    case 4, mu = const.mu_Sun;   R_body = const.R_Sun;    J2_val = 0;
    end
    
    // Convert to state vectors
    d2r = %pi / 180;
    [r0, v0] = orbital_elements_to_state(a, e_val, i_deg*d2r, RAAN_deg*d2r, ...
                                          omega_deg*d2r, nu_deg*d2r, mu);
    
    // Duration
    dur_val = strtod(get(findobj('tag', 'content_op_duration'), 'string'));
    dur_unit = get(findobj('tag', 'content_op_dur_unit'), 'value');
    T_orbit = 2 * %pi * sqrt(a^3 / mu);
    
    select dur_unit
    case 1, t_end = dur_val * T_orbit;
    case 2, t_end = dur_val * 3600;
    case 3, t_end = dur_val * 86400;
    end
    
    // J2 option
    use_j2 = get(findobj('tag', 'content_op_j2'), 'value');
    
    opts.use_j2 = (use_j2 == 1);
    opts.J2 = J2_val;
    opts.Re = R_body;
    opts.n_steps = 1000;
    
    update_status('Propagating orbit...');
    
    // Propagate
    [t_out, states] = propagate_orbit(r0, v0, [0, t_end], mu, opts);
    
    // Update orbital parameters display
    T_min = T_orbit / 60;
    r_apo = a * (1 + e_val);
    r_peri = a * (1 - e_val);
    v_peri = sqrt(mu * (2/r_peri - 1/a));
    v_apo = sqrt(mu * (2/r_apo - 1/a));
    energy = -mu / (2*a);
    h_mag = sqrt(mu * a * (1 - e_val^2));
    
    set(findobj('tag', 'content_op_result_1'), 'string', ...
        msprintf('Period:     %.2f min (%.4f hr)', T_min, T_min/60));
    set(findobj('tag', 'content_op_result_2'), 'string', ...
        msprintf('Apoapsis:   %.2f km (alt %.1f)', r_apo, r_apo-R_body));
    set(findobj('tag', 'content_op_result_3'), 'string', ...
        msprintf('Periapsis:  %.2f km (alt %.1f)', r_peri, r_peri-R_body));
    set(findobj('tag', 'content_op_result_4'), 'string', ...
        msprintf('V at peri:  %.4f km/s', v_peri));
    set(findobj('tag', 'content_op_result_5'), 'string', ...
        msprintf('V at apo:   %.4f km/s', v_apo));
    set(findobj('tag', 'content_op_result_6'), 'string', ...
        msprintf('Sp. Energy: %.4f km²/s²', energy));
    set(findobj('tag', 'content_op_result_7'), 'string', ...
        msprintf('Ang. Mom:   %.2f km²/s', h_mag));
    
    // Plot
    ph = findobj('tag', 'content_op_plot_placeholder');
    if ph <> [] then set(ph, 'visible', 'off'); end
    
    plot_type = get(findobj('tag', 'content_op_plottype'), 'value');
    
    newaxes();
    ax = gca();
    ax.axes_bounds = [0.28, 0.05, 0.70, 0.90];
    
    select plot_type
    case 1
        // 3D Orbit
        param3d(states(1,:), states(2,:), states(3,:));
        e_curve = gce(); e_curve.foreground = color(100, 50, 200); e_curve.thickness = 2;
        
        // Central body (sphere approximation)
        param3d([0], [0], [0]);
        e_pt = gce(); e_pt.mark_mode = 'on'; e_pt.mark_style = 9; e_pt.mark_size = 3;
        e_pt.mark_foreground = color(0, 100, 255);
        
        title('3D Orbit Visualization');
        xlabel('X [km]'); ylabel('Y [km]'); zlabel('Z [km]');
        
    case 2
        // Ground Track
        [lat, lon] = compute_ground_track(states, t_out, const.omega_Earth);
        
        // Plot with discontinuity handling
        seg_start = 1;
        for k = 2:length(lon)
            if abs(lon(k) - lon(k-1)) > 180 then
                plot(lon(seg_start:k-1), lat(seg_start:k-1), 'b-', 'LineWidth', 2);
                seg_start = k;
            end
        end
        plot(lon(seg_start:$), lat(seg_start:$), 'b-', 'LineWidth', 2);
        
        plot(lon(1), lat(1), 'go', 'MarkerSize', 8);
        
        // Grid
        for lg = -120:60:120, plot([lg,lg], [-90,90], 'k:'); end
        for lt = -60:30:60, plot([-180,180], [lt,lt], 'k:'); end
        
        gca().data_bounds = [-180, -90; 180, 90];
        title('Ground Track');
        xlabel('Longitude [°]'); ylabel('Latitude [°]');
        
    case 3
        // Altitude vs Time
        r_mag = sqrt(states(1,:).^2 + states(2,:).^2 + states(3,:).^2);
        alt = r_mag - R_body;
        plot(t_out/60, alt, 'b-', 'LineWidth', 1.5);
        title('Altitude vs Time');
        xlabel('Time [min]'); ylabel('Altitude [km]');
        xgrid();
        
    case 4
        // Velocity vs Time
        v_mag = sqrt(states(4,:).^2 + states(5,:).^2 + states(6,:).^2);
        plot(t_out/60, v_mag, 'r-', 'LineWidth', 1.5);
        title('Velocity Magnitude vs Time');
        xlabel('Time [min]'); ylabel('Velocity [km/s]');
        xgrid();
        
    case 5
        // Orbital elements vs Time
        [r_mag, v_mag, a_hist, e_hist, i_hist, h_hist] = orbit_analysis(states, mu);
        
        subplot(311);
        plot(t_out/3600, a_hist, 'b-');
        title('Semi-major axis'); ylabel('a [km]'); xgrid();
        
        subplot(312);
        plot(t_out/3600, e_hist, 'r-');
        title('Eccentricity'); ylabel('e'); xgrid();
        
        subplot(313);
        plot(t_out/3600, i_hist*180/%pi, 'g-');
        title('Inclination'); xlabel('Time [hr]'); ylabel('i [°]'); xgrid();
    end
    
    update_status(msprintf('Propagation complete. Period=%.2f min, Alt range=%.0f-%.0f km', ...
        T_min, r_peri-R_body, r_apo-R_body));
    
endfunction
