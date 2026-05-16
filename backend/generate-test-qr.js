const crypto = require('crypto');
const JWT_SECRET = 'your-super-secret-jwt-key-min-32-chars-change-this';
const institutionId = '69d131ab-d158-4257-87a4-af16f92fc84b';
const actorId = '948b89f8-d44a-436f-b1e6-f56191986422';
const timestamp = Date.now();
const payloadData = `${institutionId}:${actorId}:${timestamp}`;
const signature = crypto.createHmac('sha256', JWT_SECRET).update(payloadData).digest('hex');
console.log(JSON.stringify({ institution_id: institutionId, spoc_id: actorId, timestamp, signature }));
