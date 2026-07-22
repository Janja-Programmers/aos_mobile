# Coverage Policy

Coverage is a diagnostic, not a target to game.

## Priority coverage

1. authentication, session expiry, and authorization-sensitive UI;
2. private/public content rules;
3. request serialization and backend error mapping;
4. mutation state transitions, duplicate prevention, optimistic rollback, and invalidation;
5. route guards, redirects, arguments, and return values;
6. validation and conditional fields;
7. realtime/media lifecycle and cleanup;
8. historically fragile regressions.

## Reporting

Feature reports should state:

- command used;
- files included in the measured scope;
- important paths covered;
- meaningful uncovered paths;
- exclusions and environment constraints.

Do not claim coverage when `lcov.info` was not generated. Do not exclude production code solely to improve a percentage.
