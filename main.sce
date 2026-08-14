// ============================================================================
// OrbitalMDT — Main Application Launcher
// ============================================================================
// Run this file in Scilab to launch the application:
//   exec("main.sce", -1);
// ============================================================================

clear;
clc;

disp("============================================================");
disp("  🚀 OrbitalMDT — Orbital Mechanics Mission Design Toolkit");
disp("  Professional Interplanetary Mission Analysis Suite");
disp("============================================================");
disp(" ");
disp("  Loading modules...");

// Get the directory where this script is located
script_dir = get_absolute_file_path("main.sce");

// ---- Load Core Engine Modules ----
disp("    [1/15] constants.sci");
exec(script_dir + "core/constants.sci", -1);

disp("    [2/15] kepler.sci");
exec(script_dir + "core/kepler.sci", -1);

disp("    [3/15] coordinates.sci");
exec(script_dir + "core/coordinates.sci", -1);

disp("    [4/15] ephemeris.sci");
exec(script_dir + "core/ephemeris.sci", -1);

disp("    [5/15] lambert.sci");
exec(script_dir + "core/lambert.sci", -1);

disp("    [6/15] hohmann.sci");
exec(script_dir + "core/hohmann.sci", -1);

disp("    [7/15] bielliptic.sci");
exec(script_dir + "core/bielliptic.sci", -1);

disp("    [8/15] propagator.sci");
exec(script_dir + "core/propagator.sci", -1);

disp("    [9/15] porkchop.sci");
exec(script_dir + "core/porkchop.sci", -1);

disp("    [10/15] rocket_equation.sci");
exec(script_dir + "core/rocket_equation.sci", -1);

disp("    [11/15] flyby.sci");
exec(script_dir + "core/flyby.sci", -1);

disp("    [12/15] reentry.sci");
exec(script_dir + "core/reentry.sci", -1);

disp("    [13/15] rendezvous.sci");
exec(script_dir + "core/rendezvous.sci", -1);

disp("    [14/15] groundtrack.sci");
exec(script_dir + "core/groundtrack.sci", -1);

disp("    [15/15] mission_utils.sci");
exec(script_dir + "core/mission_utils.sci", -1);

disp(" ");
disp("  Loading GUI modules...");

// ---- Load GUI Modules ----
exec(script_dir + "gui/gui_main.sci", -1);
exec(script_dir + "gui/gui_mission_planner.sci", -1);
exec(script_dir + "gui/gui_hohmann.sci", -1);
exec(script_dir + "gui/gui_lambert.sci", -1);
exec(script_dir + "gui/gui_propagator.sci", -1);
exec(script_dir + "gui/gui_solarsystem.sci", -1);
exec(script_dir + "gui/gui_rocket.sci", -1);
exec(script_dir + "gui/gui_reentry.sci", -1);

disp("  All modules loaded successfully!");
disp(" ");
disp("  Launching GUI...");
disp(" ");

// ---- Launch the Application ----
launch_orbital_mdt();

disp("============================================================");
disp("  OrbitalMDT is running!");
disp("  ");
disp("  Available Tabs:");
disp("    1. Mission Planner  — Porkchop plots & launch windows");
disp("    2. Transfers        — Hohmann & bi-elliptic maneuvers");
disp("    3. Lambert Solver   — Two-point boundary value problem");
disp("    4. Propagator       — Orbit propagation with J2");
disp("    5. Solar System     — Planet positions at any date");
disp("    6. Rocket Equation  — Mass budgets & propellant calc");
disp("    7. Re-Entry         — Atmospheric entry analysis");
disp("  ");
disp("  Tip: Use the command line for batch analysis:");
disp("    result = hohmann_transfer(6571, 42164, 398600.4418);");
disp("    [r,v] = planet_state_heliocentric(4, date_to_jd(2028,7,1));");
disp("============================================================");
