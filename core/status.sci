// OrbitalMDT :: Standardized Status & Error Framework
// Standard status codes and readable error messaging.

function codes = get_status_codes()
    codes.SUCCESS          = 0;
    codes.INVALID_INPUT    = 1;
    codes.NO_SOLUTION      = 2;
    codes.NOT_CONVERGED    = 3;
    codes.NUMERICAL_ERROR  = 4;
    codes.OUT_OF_RANGE     = 5;
    codes.UNSUPPORTED_CASE = 6;
endfunction


function msg = status_message(code)
    // Convert numeric status code to human-readable message string.
    select code
    case 0, msg = "Calculation completed successfully.";
    case 1, msg = "Invalid input parameter(s). Check numerical bounds and units.";
    case 2, msg = "No physical solution exists for given trajectory geometry.";
    case 3, msg = "Solver did not converge within maximum allowed iterations.";
    case 4, msg = "Numerical error or singularity encountered.";
    case 5, msg = "Input parameter out of valid domain range.";
    case 6, msg = "Requested case or configuration is unsupported.";
    else,   msg = "Unknown status code.";
    end
endfunction
