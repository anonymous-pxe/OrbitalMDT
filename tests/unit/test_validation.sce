// OrbitalMDT Unit Test :: Parameter Validation Engine
// Validates boundary, domain, and data type validation functions.

exec("core/validation.sci", -1);

m_passed = 0;
m_failed = 0;

function assert_true(cond, name)
    global m_passed m_failed;
    if cond then
        m_passed = m_passed + 1;
        printf("  [PASS] %s\n", name);
    else
        m_failed = m_failed + 1;
        printf("  [FAIL] %s\n", name);
    end
endfunction

printf("--- Running unit/test_validation.sce ---\n");

// 1. Positive scalar validation
[ok, msg] = validate_positive_scalar(42.5, "SMA");
assert_true(ok, "Positive scalar accepted (42.5)");

[ok, msg] = validate_positive_scalar(-5.0, "SMA");
assert_true(~ok, "Negative scalar rejected (-5.0)");

[ok, msg] = validate_positive_scalar(0, "SMA");
assert_true(~ok, "Zero scalar rejected for positive validator");

[ok, msg] = validate_positive_scalar(%nan, "SMA");
assert_true(~ok, "NaN scalar rejected");

[ok, msg] = validate_positive_scalar(%inf, "SMA");
assert_true(~ok, "Inf scalar rejected");

// 2. Non-negative scalar validation
[ok, msg] = validate_nonnegative_scalar(0.0, "Delta-V");
assert_true(ok, "Zero accepted for non-negative scalar (0.0)");

[ok, msg] = validate_nonnegative_scalar(-0.1, "Delta-V");
assert_true(~ok, "Negative scalar rejected for non-negative validator");

// 3. Bounded scalar validation
[ok, msg] = validate_bounded_scalar(45.0, "Inclination", 0, 180);
assert_true(ok, "Bounded scalar in range accepted (45 in [0, 180])");

[ok, msg] = validate_bounded_scalar(195.0, "Inclination", 0, 180);
assert_true(~ok, "Bounded scalar above maximum rejected (195 in [0, 180])");

[ok, msg] = validate_bounded_scalar(-10.0, "Inclination", 0, 180);
assert_true(~ok, "Bounded scalar below minimum rejected (-10 in [0, 180])");

// 4. Numeric input string parser
[val, ok, msg] = parse_numeric_input("123.456", "TestParam");
assert_true(ok & abs(val - 123.456) < 1e-10, "Valid numeric string parsed (123.456)");

[val, ok, msg] = parse_numeric_input("   78.9   ", "TestParam");
assert_true(ok & abs(val - 78.9) < 1e-10, "Whitespace trimmed and parsed (78.9)");

[val, ok, msg] = parse_numeric_input("abc", "TestParam");
assert_true(~ok, "Non-numeric string rejected (abc)");

[val, ok, msg] = parse_numeric_input("", "TestParam");
assert_true(~ok, "Empty string rejected");

[val, ok, msg] = parse_numeric_input("50", "TestParam", 0, 100);
assert_true(ok & val == 50, "String with range constraints parsed (50 in [0, 100])");

[val, ok, msg] = parse_numeric_input("150", "TestParam", 0, 100);
assert_true(~ok, "String out of range rejected (150 in [0, 100])");

// 5. 3D vector validation
[ok, msg] = validate_vector_3d([1; 2; 3], "Position");
assert_true(ok, "Valid 3x1 vector accepted");

[ok, msg] = validate_vector_3d([1, 2, 3], "Position");
assert_true(ok, "Valid 1x3 vector accepted");

[ok, msg] = validate_vector_3d([1; 2], "Position");
assert_true(~ok, "2-element vector rejected for 3D vector validator");

[ok, msg] = validate_vector_3d([1; %nan; 3], "Position");
assert_true(~ok, "Vector containing NaN rejected");

// 6. Eccentricity validation
[ok, msg] = validate_eccentricity(0.0);
assert_true(ok, "Circular orbit eccentricity (e=0) accepted");

[ok, msg] = validate_eccentricity(0.95);
assert_true(ok, "Elliptic orbit eccentricity (e=0.95) accepted");

[ok, msg] = validate_eccentricity(1.5);
assert_true(ok, "Hyperbolic orbit eccentricity (e=1.5) accepted");

[ok, msg] = validate_eccentricity(-0.05);
assert_true(~ok, "Negative eccentricity (e=-0.05) rejected");

// 7. Date bounds validation
[ok, msg] = validate_date_bounds(2026, 8, 19);
assert_true(ok, "Valid date accepted (2026-08-19)");

[ok, msg] = validate_date_bounds(1750, 1, 1);
assert_true(~ok, "Year before 1800 rejected");

[ok, msg] = validate_date_bounds(2026, 13, 1);
assert_true(~ok, "Month > 12 rejected");

[ok, msg] = validate_date_bounds(2026, 5, 35);
assert_true(~ok, "Day > 31 rejected");

// 8. State vector validation
[ok, msg] = validate_state_vector([7000; 0; 0], [0; 7.5; 0]);
assert_true(ok, "Valid orbital state vector accepted");

[ok, msg] = validate_state_vector([0; 0; 0], [0; 7.5; 0]);
assert_true(~ok, "Singular zero position vector rejected");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
