# Tooling

- OpenAPI Codegen

## OpenAPI Codegen

This project supports automatic generation of a Swift HTTP client from [LoginID's FIDO2 OpenAPI spec](https://gitlab.com/loginid/software/loginid-fido2/-/blob/main/api/rest/openapi3.yaml?ref_type=heads).

---

**Requirements**:

- Node.js must be installed to run the code generation script.

---

To generate the client, run the following command from the root directory:

```bash
cd ./openapi-gen/ && npm install && sh ./openapi-gen/openapi_generate.sh && cd ..
```

This script installs necessary dependencies and runs a generator that produces the FIDO2 MFA client at:

```bash
./LoginIDMFA/Sources/LoginIDAPIClient/
```

**NOTE**:

- The client is generated from the main branch of LoginID's FIDO2 OpenAPI definition.
- Regenerate the client any time the spec is updated to ensure you're using the latest API contract.
