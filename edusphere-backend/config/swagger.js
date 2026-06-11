// config/swagger.js
const swaggerJsdoc = require('swagger-jsdoc');

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'EduSphere University ERP Core Engine REST API Matrix',
            version: '1.0.0',
            description: 'Comprehensive API documentation directory, providing live sandbox tools for end-to-end interface route testing.',
        },
        servers: [
            {
                url: 'http://localhost:5000',
                description: 'Local Development Server Environment',
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                    description: 'Paste your active Admin, Faculty, or Student Access Token to unblock endpoint constraints.',
                },
            },
        },
        // 🚀 SAFE ENTRY: Define paths using strict object hierarchy to prevent duplicate key crashes
        paths: {
            '/api/auth/register': {
                post: {
                    summary: 'Provision a fresh system identity credentials slot',
                    tags: ['Authentication Module'],
                    requestBody: {
                        required: true,
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'object',
                                    required: ['email', 'password', 'role'],
                                    properties: {
                                        email: { type: 'string', example: 'teacher.green@edusphere.edu' },
                                        password: { type: 'string', example: 'SecurePass123!' },
                                        role: { type: 'string', example: 'Teacher' }
                                    }
                                }
                            }
                        }
                    },
                    responses: {
                        201: { description: 'Identity registered successfully.' },
                        400: { description: 'Execution breakdown or duplicate key conflict.' }
                    }
                }
            },
            '/api/auth/login': {
                post: {
                    summary: 'Authenticate user profile credentials and return dual session tokens',
                    tags: ['Authentication Module'],
                    requestBody: {
                        required: true,
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'object',
                                    required: ['email', 'password'],
                                    properties: {
                                        email: { type: 'string', example: 'admin@edusphere.edu' },
                                        password: { type: 'string', example: 'secretAdminPassword' }
                                    }
                                }
                            }
                        }
                    },
                    responses: {
                        200: { description: 'Authentication successful. Tokens generated.' },
                        401: { description: 'Access denied due to invalid credentials.' }
                    }
                }
            }
        }
    },
    apis: [], // Clear out route scanning to prevent old inline comments from being read
};

const swaggerSpecs = swaggerJsdoc(options);
module.exports = swaggerSpecs;