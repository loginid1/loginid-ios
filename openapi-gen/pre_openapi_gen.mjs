import * as fs from 'fs'
import * as yaml from 'js-yaml'

const file = fs.readFileSync('./openapi.yaml', 'utf8')
const data = yaml.load(file)

const allowedTags = new Set([
  'reg',
  'auth',
  'tx',
  'passkeys',
  'mfa',
  'client-events'
]);
const allowedSchemas = new Set()

const allowedSecurityHeaders = new Set([
  "jwt_header_Authorization",
  "sessionAuth_header_Authorization",
]);

const extractSchemas = (schema) => {
  if (!schema) return;

  // Add the schema to allowedSchemas if it has a $ref (reference)
  if (schema.$ref) {
    let schemaName = schema.$ref.replace('#/components/schemas/', '');
    allowedSchemas.add(schemaName)

    const schemaRef = data.components.schemas[schemaName]
    // If it's an object, recursively extract nested schemas
    if (schemaRef.type === 'object' && schemaRef.properties) {
      Object.values(schemaRef.properties).forEach(extractSchemas);
    }

    // If it's an array, check its items
    if (schemaRef.type === 'array' && schemaRef.items) {
      extractSchemas(schemaRef.items);
    }
  }

  // If it's an array, check its items
  if (schema.type === 'array' && schema.items) {
    extractSchemas(schema.items);
  }
};

// Remove disallowed tags from the global "tags" section
if (data.tags) {
  data.tags = data.tags.filter((tag) => allowedTags.has(tag.name))
}

for (const pathKey in data.paths) {
  const path = data.paths[pathKey]

  for (const methodKey in path) {
    const method = path[methodKey]

    const hasAllowedTag = method.tags?.some((tag) => allowedTags.has(tag))

    if (hasAllowedTag) {
      if (method.security?.some((sec) => Object.keys(sec).some((key) => allowedSecurityHeaders.has(key)))) {
        if (!method.parameters) {
          method.parameters = []
        }

        method.parameters.push({
          name: 'Authorization',
          in: 'header',
          description: 'JWT Authorization header',
          required: false,
          schema: { type: 'string' },
        })
      }

      if (method.requestBody) {
        const requestBodyContent = method.requestBody.content;
        for (const mediaType in requestBodyContent) {
          extractSchemas(requestBodyContent[mediaType].schema);
        }
      }

      if (method.responses) {
        for (const statusCode in method.responses) {
          const response = method.responses[statusCode];
          if (response.content) {
            for (const mediaType in response.content) {
              extractSchemas(response.content[mediaType].schema);
            }
          }
        }
      }
    } else {
      delete path[methodKey]
    }
  }

  if (Object.keys(path).length === 0) {
    delete data.paths[pathKey]
  }
}

if (data.components && data.components.schemas) {
  for (const schemaKey in data.components.schemas) {
    const schema = data.components.schemas[schemaKey]

    // Filter out schemas not in the allowed list
    if (!allowedSchemas.has(schemaKey)) {
      delete data.components.schemas[schemaKey]
      continue
    }

    switch (schemaKey) {
      case 'MfaNext':
      case 'Mfa' : {
        schema.properties.flow.enum = schema.properties.flow.enum.map(value => value.toLowerCase())
        schema.properties.flow.enum.push('checkout')
        schema.properties.flow.enum.push('signUp')
        schema.properties.flow.enum.push('signIn')
        break;
      }

      case 'RegInit':
        schema.properties.action.enum = [...schema.properties.action.enum, ''];
        break;

      case 'AuthInit':
        schema.required = schema.required.filter((req) => req !== 'assertionOptions');
        break;
      
      case 'Passkey':
        delete schema.properties.createdAt.format;
        break;

      case 'PublicKeyCredentialParameters':
        delete schema.properties.alg.enum;
        break;

      case 'PublicKeyCredentialRequestOptions':
      case 'PublicKeyCredentialCreationOptions':
        delete schema.properties.extensions;
        break;

      case 'User':
      case 'UserLogin':
        delete schema.properties.usernameType.enum;
        schema.required = schema.required.filter((req) => req !== 'usernameType');
        break;

      default:
        break;
    }
  }
}

fs.writeFileSync('./mod-openapi.yaml', yaml.dump(data), 'utf8')
