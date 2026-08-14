// ============================================================================
// OrbitalMDT — Tsiolkovsky Rocket Equation & Propellant Budget
// ============================================================================
// Propellant mass calculations, staging analysis, and mission ΔV budgets.
// Essential for spacecraft design and mission feasibility studies.
// ============================================================================

function result = rocket_equation(dv, Isp, m_payload, g0)
    // Tsiolkovsky Rocket Equation
    // INPUTS:
    //   dv        - Required delta-V [km/s]
    //   Isp       - Specific impulse [seconds]
    //   m_payload - Payload mass (including structure) [kg]
    //   g0        - Standard gravity [km/s^2] (default 9.80665e-3)
    // OUTPUT:
    //   result - struct with mass budget
    
    if ~exists('g0', 'local') then g0 = 9.80665e-3; end
    
    // Exhaust velocity
    v_e = Isp * g0;  // [km/s]
    
    // Mass ratio
    mass_ratio = exp(dv / v_e);
    
    // Initial mass (payload + propellant)
    m_initial = m_payload * mass_ratio;
    
    // Propellant mass
    m_propellant = m_initial - m_payload;
    
    // Propellant fraction
    prop_fraction = m_propellant / m_initial;
    
    result.dv            = dv;
    result.Isp           = Isp;
    result.v_exhaust     = v_e;
    result.mass_ratio    = mass_ratio;
    result.m_payload     = m_payload;
    result.m_propellant  = m_propellant;
    result.m_initial     = m_initial;
    result.prop_fraction = prop_fraction;
    
endfunction


function result = staging_analysis(dv_total, n_stages, Isp_stages, struct_fractions, m_payload)
    // Multi-stage rocket analysis
    // INPUTS:
    //   dv_total         - Total required delta-V [km/s]
    //   n_stages         - Number of stages
    //   Isp_stages       - Vector of Isp for each stage [s] (1×n_stages)
    //   struct_fractions - Structural fraction for each stage (1×n_stages)
    //   m_payload        - Final payload mass [kg]
    // OUTPUT:
    //   result - struct with staging breakdown
    
    g0 = 9.80665e-3;  // [km/s^2]
    
    // Simple equal ΔV split if not optimized
    dv_per_stage = dv_total / n_stages * ones(1, n_stages);
    
    // Work backwards from payload
    m_upper = m_payload;
    stage_data = list();
    
    for k = n_stages:-1:1
        v_e = Isp_stages(k) * g0;
        eps = struct_fractions(k);
        
        // Mass ratio for this stage
        MR = exp(dv_per_stage(k) / v_e);
        
        // Stage initial mass (payload for this stage = everything above)
        // m0 = m_upper * MR / (1 - eps*(1 - 1/MR))
        // Simplified: m_stage_total includes structure
        m_prop = m_upper * (MR - 1) / (1 - eps * MR);
        m_struct = eps * (m_prop + m_upper * (MR - 1) / (1 - eps * MR));
        
        // Simpler approach: 
        // m_initial = m_upper / (1 - prop_frac)
        // where prop_frac comes from dv and Isp
        lambda = 1 / MR;  // payload ratio
        m_stage_initial = m_upper / lambda;
        m_stage_prop = m_stage_initial - m_upper - eps * (m_stage_initial - m_upper);
        m_stage_struct = eps * (m_stage_initial - m_upper);
        
        sd.stage_num = k;
        sd.dv = dv_per_stage(k);
        sd.Isp = Isp_stages(k);
        sd.mass_ratio = MR;
        sd.m_payload_above = m_upper;
        sd.m_propellant = m_stage_prop;
        sd.m_structure = m_stage_struct;
        sd.m_stage_total = m_stage_initial;
        
        stage_data(k) = sd;
        m_upper = m_stage_initial;
    end
    
    result.n_stages    = n_stages;
    result.dv_total    = dv_total;
    result.m_payload   = m_payload;
    result.m_liftoff   = m_upper;
    result.stages      = stage_data;
    result.mass_ratio_total = m_upper / m_payload;
    
endfunction


function result = mission_dv_budget(mission_type)
    // Pre-computed ΔV budgets for common missions
    // INPUTS:
    //   mission_type - String: "LEO", "GEO", "Moon", "Mars", "Venus", "Jupiter"
    // OUTPUT:
    //   result - struct with mission ΔV breakdown
    
    select mission_type
    case "LEO"
        result.name = "Earth to LEO (400 km)";
        result.segments = ["Ground to LEO"];
        result.dvs = [9.4];  // km/s (includes gravity & drag losses)
        result.total = 9.4;
        
    case "GEO"
        result.name = "Earth to GEO";
        result.segments = ["Ground to LEO", "LEO to GTO", "GTO to GEO"];
        result.dvs = [9.4, 2.46, 1.48];
        result.total = sum(result.dvs);
        
    case "Moon"
        result.name = "Earth to Lunar Surface";
        result.segments = ["Ground to LEO", "LEO to TLI", "LOI", "Descent"];
        result.dvs = [9.4, 3.13, 0.82, 1.87];
        result.total = sum(result.dvs);
        
    case "Mars"
        result.name = "Earth to Mars Surface";
        result.segments = ["Ground to LEO", "LEO to TMI", "MOI", "EDL"];
        result.dvs = [9.4, 3.6, 1.1, 0.6];
        result.total = sum(result.dvs);
        
    case "Venus"
        result.name = "Earth to Venus Orbit";
        result.segments = ["Ground to LEO", "LEO to TVI", "VOI"];
        result.dvs = [9.4, 3.5, 0.9];
        result.total = sum(result.dvs);
        
    case "Jupiter"
        result.name = "Earth to Jupiter Orbit";
        result.segments = ["Ground to LEO", "LEO to TJI", "JOI"];
        result.dvs = [9.4, 6.3, 2.0];
        result.total = sum(result.dvs);
        
    else
        result.name = "Custom";
        result.segments = ["Custom"];
        result.dvs = [0];
        result.total = 0;
    end
    
endfunction


function print_propellant_budget(dv, Isp, m_payload)
    // Pretty-print a propellant budget
    r = rocket_equation(dv, Isp, m_payload);
    
    mprintf("\n===== PROPELLANT BUDGET =====\n");
    mprintf("  Delta-V required:    %.3f km/s\n", r.dv);
    mprintf("  Specific impulse:    %.0f s\n", r.Isp);
    mprintf("  Exhaust velocity:    %.3f km/s\n", r.v_exhaust);
    mprintf("  Mass ratio:          %.3f\n", r.mass_ratio);
    mprintf("  Payload mass:        %.1f kg\n", r.m_payload);
    mprintf("  Propellant mass:     %.1f kg\n", r.m_propellant);
    mprintf("  Initial mass:        %.1f kg\n", r.m_initial);
    mprintf("  Propellant fraction: %.1f%%\n", r.prop_fraction * 100);
    mprintf("============================\n");
    
endfunction
