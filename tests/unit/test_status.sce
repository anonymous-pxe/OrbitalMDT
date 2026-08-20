// OrbitalMDT Unit Test :: Status Codes and Messages
// Validates standard status code assignments and message generation.

exec("core/status.sci", -1);

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

printf("--- Running unit/test_status.sce ---\n");

codes = get_status_codes();

assert_true(codes.SUCCESS == 0, "SUCCESS code is 0");
assert_true(codes.INVALID_INPUT == 1, "INVALID_INPUT code is 1");
assert_true(codes.NO_SOLUTION == 2, "NO_SOLUTION code is 2");
assert_true(codes.NOT_CONVERGED == 3, "NOT_CONVERGED code is 3");
assert_true(codes.NUMERICAL_ERROR == 4, "NUMERICAL_ERROR code is 4");
assert_true(codes.OUT_OF_RANGE == 5, "OUT_OF_RANGE code is 5");
assert_true(codes.UNSUPPORTED_CASE == 6, "UNSUPPORTED_CASE code is 6");

// Messages
msg0 = status_message(codes.SUCCESS);
assert_true(length(msg0) > 0, "Status message 0 is non-empty");

msg3 = status_message(codes.NOT_CONVERGED);
assert_true(length(msg3) > 0, "Status message for NOT_CONVERGED is informative");

msg_unk = status_message(999);
assert_true(msg_unk == "Unknown status code.", "Unknown code handling");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
