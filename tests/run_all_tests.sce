// OrbitalMDT :: Master Test Runner
// Executes all automated unit, integration, and reference mission test suites.

funcprot(0);

printf("========================================================\n");
printf("     OrbitalMDT v1.0.1 Automated Validation Suite       \n");
printf("========================================================\n\n");

total_passed = 0;
total_failed = 0;

unit_tests = [ ..
    "tests/unit/test_constants.sce", ..
    "tests/unit/test_validation.sce", ..
    "tests/unit/test_status.sce", ..
    "tests/unit/test_time.sce", ..
    "tests/unit/test_coordinates.sce", ..
    "tests/unit/test_frames.sce", ..
    "tests/unit/test_kepler.sce", ..
    "tests/unit/test_lambert.sce", ..
    "tests/unit/test_ephemeris.sce", ..
    "tests/unit/test_transfers.sce", ..
    "tests/unit/test_propagator.sce", ..
    "tests/unit/test_flyby.sce", ..
    "tests/unit/test_rocket_equation.sce", ..
    "tests/unit/test_reentry.sce", ..
    "tests/unit/test_rendezvous.sce", ..
    "tests/unit/test_groundtrack.sce", ..
    "tests/unit/test_mission_utils.sce" ..
];

integration_tests = [ ..
    "tests/integration/test_earth_mars_lambert.sce", ..
    "tests/integration/test_lambert_propagation_endpoint.sce", ..
    "tests/integration/test_porkchop_workflow.sce", ..
    "tests/integration/test_planner_to_rocket.sce", ..
    "tests/integration/test_reference_missions.sce" ..
];

printf(">>> UNIT TESTS <<<\n");
for k = 1:size(unit_tests, "*")
    tf = unit_tests(k);
    global m_passed m_failed;
    m_passed = 0; m_failed = 0;

    exec(tf, -1);

    total_passed = total_passed + m_passed;
    total_failed = total_failed + m_failed;
end

printf("\n>>> INTEGRATION & REFERENCE MISSION TESTS <<<\n");
for k = 1:size(integration_tests, "*")
    tf = integration_tests(k);
    global m_passed m_failed;
    m_passed = 0; m_failed = 0;

    exec(tf, -1);

    total_passed = total_passed + m_passed;
    total_failed = total_failed + m_failed;
end

printf("========================================================\n");
printf(" TEST RUN SUMMARY:\n");
printf("   Total Tests Passed : %d\n", total_passed);
printf("   Total Tests Failed : %d\n", total_failed);
if total_failed == 0 then
    printf("   OVERALL STATUS     : PASS (All validation checks succeeded!)\n");
else
    printf("   OVERALL STATUS     : FAIL (Check logs above for details)\n");
end
printf("========================================================\n");
