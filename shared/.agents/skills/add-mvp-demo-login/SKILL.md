---
name: add-mvp-demo-login
description: Add or revise an MVP demo-account helper on any web login page. Use when asked for a top-right info button that unlocks demo credentials, an access-code modal, selectable MVP users, or an autofill-only demo login flow.
---

# Add MVP Demo Login

Implement a guided way for MVP evaluators to access approved demo accounts. The feature reveals credentials and fills the normal login form; it never submits the form or creates a session itself.

## Required Flow

1. Put an information button in the top-right area of the login page. Give it a clear accessible name, such as `Demo account information`.
2. Open a modal when the button is activated. The first view asks for the MVP access code.
3. Compare the entered code with the access-code value loaded from frontend environment configuration. Use the project/page name followed by `159` as the normal value convention, for example `my-app159`.
4. When the code matches, show a confirmation view that asks whether to use demo access once or remember it for one month.
5. For **Use once**, unlock the configured list of demo users only for the current modal interaction. For **Remember for one month**, store an expiring “demo access unlocked” record in `localStorage` and unlock the list.
6. When the evaluator chooses a user, copy that user's email and password into the existing login form, close the modal, and place focus on the form's normal sign-in button or the last filled field.
7. Do not sign in automatically. The evaluator must explicitly activate the normal login action.

When a valid, unexpired saved-access record is present, opening the information button must go directly to the demo-user list and skip the access-code prompt. Keep modal state local: closed, requesting code, code error, confirmation, and unlocked. Reset the entered access code whenever the modal closes. Reset the one-time unlocked state when the modal closes.

Persist only a small record containing an unlock marker and an expiry timestamp set to 30 days after confirmation. On every read, validate the record and remove it when it is malformed or expired. Do not store the MVP access code, selected email, password, or user object. If `localStorage` is unavailable, fall back to **Use once** behavior.

## Environment and Demo User Source

Inspect the project's seed data before creating the demo-user configuration. When suitable seeded users exist, derive every demo entry from those seed users: use their email, password, label, and role rather than inventing credentials.

Write the resulting configuration to `.env.example`, not as literal values in frontend source. Use the frontend toolchain's required public-variable prefix and provide two values: one for the access code and one serialized demo-user list. For example:

```dotenv
PUBLIC_DEMO_ACCESS_CODE=my-app159
PUBLIC_DEMO_USERS=[{"label":"Demo user","email":"demo@example.test","password":"seed-password","role":"viewer"}]
```

Read and parse those values through the application's environment/configuration layer. Keep frontend source limited to variable names, parsing, validation, and UI behavior; never embed the access code, email, or password in it.

If no applicable seed users exist, leave the demo-user environment value empty, for example `PUBLIC_DEMO_USERS=`. Treat a missing or blank value as an empty list. After a valid access code, show a clear empty state such as `No demo accounts are currently available`; do not fabricate users, credentials, or a fallback administrator account.

## Data and Security Boundaries

Use the normal authentication endpoint when the evaluator submits the filled form. Do not create tokens, sessions, or privileged users in the browser.

Treat the frontend access code as a discovery barrier only, not security: frontend environment values and any bundled demo credentials can be inspected by a determined user. The backend must still enforce every role and permission.

Use only limited, non-production demo accounts. Do not expose real user credentials, secrets, unrestricted administrator access, or a backend bypass. Prefer resettable demo data and explain any data limitations in the modal.

If the credential list must be genuinely protected, fetch it from an authenticated or server-validated endpoint after the access code is verified. Do not rely on a frontend environment variable for that protection.

## Interaction and Accessibility

- Use a semantic button for the top-right trigger and a clear visible focus state.
- Label the modal and its access-code input. Use an appropriate password-style input if the code should not be visible while typed.
- Show an understandable incorrect-code message without revealing the expected value; announce it through the application's live-error pattern.
- Clearly label the confirmation choices, for example **Use once** and **Remember for one month**, and explain that the latter expires after 30 days and can be cleared through browser storage.
- Keep focus inside the modal while open, support Escape and a visible close control, and return focus to the trigger when it closes normally.
- Make every demo user selectable by keyboard. Do not use color alone to communicate a user's role or selection.
- Prevent duplicate actions while validating the code or applying credentials, and preserve a usable login form if any step fails.

## Validate

1. Confirm the info button is top-right, keyboard accessible, and opens the modal.
2. Confirm an invalid code keeps credentials hidden and shows an accessible error.
3. Confirm `.env.example` contains the access-code and demo-user variables, and frontend source contains no literal demo credentials.
4. Confirm a valid configured code presents the one-time/one-month confirmation before showing approved seeded demo users or the clear empty state.
5. Confirm **Use once** requires the code again after the modal closes.
6. Confirm **Remember for one month** skips the code across browser restarts until 30 days have elapsed, then clears the saved record and requires the code again.
7. Confirm no code, credential, or selected-user data is persisted; only the unlock marker and expiry timestamp are stored.
8. Confirm selecting each user fills the correct email and password, closes the modal, and does not send a login request.
9. Confirm the normal login button remains the only action that authenticates.
10. Confirm focus management, responsive layout, and automated accessibility checks.

## Common Requests

- “Add demo accounts to the login page”: implement the full access-code, user-selection, and autofill-only flow.
- “Make it log in after selecting a demo user”: do not change this behavior unless explicitly requested; the default feature stops at autofill.
- “Keep real credentials behind a frontend environment variable”: explain that this is not secret protection and require a server-validated solution instead.
