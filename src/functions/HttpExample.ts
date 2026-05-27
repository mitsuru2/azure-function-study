import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

export async function HttpExample(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    let body: any = {};
    try {
        // Parse JSON body if it exists
        body = await request.json();
    } catch (error) {
        // Fallback to empty object if body is not valid JSON
    }

    // Extract parameters with priority: Query String > JSON Body > Default
    const rawName = request.query.get('name') || body?.name || 'world';
    const rawEmail = request.query.get('email') || body?.email || 'not provided';
    const rawAge = request.query.get('age') || body?.age || 'not provided';

    // Formatting Rules
    const name = rawName.split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');
    
    const email = rawEmail.toLowerCase();
    
    const parsedAge = parseInt(String(rawAge));
    const age = isNaN(parsedAge) ? "not provided" : parsedAge;

    return {
        jsonBody: { name, email, age }
    };
};

app.http('HttpExample', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: HttpExample
});
