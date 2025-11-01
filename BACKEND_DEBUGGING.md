# Backend Recording Debugging Guide

## Common "Start Failed" Errors

### 1. **resourceId Expired**
```
Error: "Resource expired"
```
**Cause**: resourceId is only valid for 5 minutes after acquire  
**Solution**: Call acquire → start within 5 minutes

### 2. **Invalid Channel/UID**
```
Error: "Invalid parameter", "Channel not found"
```
**Cause**: channelName or uid doesn't match active Agora session  
**Solution**: 
- Use exact channelName from your live stream
- Use the same uid that joined the channel
- Ensure the channel is actually live (someone is broadcasting)

### 3. **Backend Agora Credentials Missing**
```
Error: "401 Unauthorized", "Invalid authentication"
```
**Cause**: Backend missing Agora App ID / Customer ID / Secret  
**Solution**: Check backend .env file has:
```env
AGORA_APP_ID=your_app_id
AGORA_CUSTOMER_ID=your_customer_id
AGORA_CUSTOMER_SECRET=your_customer_secret
```

### 4. **Storage Configuration Missing**
```
Success: true, but fileUrl: null in stop response
```
**Cause**: Backend doesn't send storageConfig to Agora  
**Solution**: See `AGORA_RECORDING_SETUP.md`

### 5. **Backend Not Running**
```
Error: "Failed to connect", "Network error", "Connection refused"
```
**Cause**: Backend server not running at http://67.225.241.58:4004  
**Solution**: 
```bash
cd backend
npm start
```

### 6. **CORS Issues**
```
Error: "CORS policy blocked"
```
**Cause**: Backend not allowing Flutter app origin  
**Solution**: Add CORS headers in backend:
```javascript
app.use(cors({
  origin: '*', // or your specific domain
  methods: ['GET', 'POST'],
}));
```

---

## How to Check Backend Logs

### Start Your Backend
```bash
cd backend
npm start
# or
node server.js
```

### Watch the Console
When you call `/api/agora/recording/start`, you should see:
```
POST /api/agora/recording/start
Request body: { channelName: "testchannel", uid: "12345", resourceId: "..." }
Calling Agora API: POST https://api.agora.io/v1/apps/{appId}/cloud_recording/...
Agora Response: { success: true, sid: "..." }
```

### Common Backend Errors to Look For

#### ❌ Missing Environment Variables
```
Error: AGORA_APP_ID is not defined
Error: Cannot read property 'CUSTOMER_ID' of undefined
```
**Fix**: Create `.env` file with credentials

#### ❌ Axios/Request Error
```
Error: Request failed with status code 400
Error: Invalid parameter
```
**Fix**: Check if you're sending correct data to Agora

#### ❌ Authentication Error
```
Error: 401 Unauthorized
```
**Fix**: Verify Agora credentials are correct

---

## Backend Code Example (Correct Implementation)

### `/api/agora/recording/start` Endpoint
```javascript
app.post('/api/agora/recording/start', async (req, res) => {
  const { channelName, uid, resourceId } = req.body;

  console.log('START REQUEST:', { channelName, uid, resourceId });

  try {
    const appId = process.env.AGORA_APP_ID;
    const customerId = process.env.AGORA_CUSTOMER_ID;
    const customerSecret = process.env.AGORA_CUSTOMER_SECRET;

    // Generate Basic Auth
    const auth = Buffer.from(`${customerId}:${customerSecret}`).toString('base64');

    const agoraUrl = `https://api.agora.io/v1/apps/${appId}/cloud_recording/resourceid/${resourceId}/mode/mix/start`;

    const payload = {
      cname: channelName,
      uid: uid,
      clientRequest: {
        recordingConfig: {
          channelType: 0,
          streamTypes: 2,
          audioProfile: 1,
          videoStreamType: 0,
          maxIdleTime: 30,
        },
        // ⚠️ CRITICAL: Without this, fileUrl will be null
        storageConfig: {
          vendor: 1, // AWS S3
          region: 0,
          bucket: process.env.S3_BUCKET_NAME,
          accessKey: process.env.AWS_ACCESS_KEY,
          secretKey: process.env.AWS_SECRET_KEY,
          fileNamePrefix: ['recordings', channelName],
        },
      },
    };

    console.log('CALLING AGORA API:', agoraUrl);
    console.log('PAYLOAD:', JSON.stringify(payload, null, 2));

    const response = await axios.post(agoraUrl, payload, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`,
      },
    });

    console.log('AGORA RESPONSE:', response.data);

    res.json({
      success: true,
      resourceId: resourceId,
      sid: response.data.sid,
      message: 'Recording started successfully',
    });

  } catch (error) {
    console.error('START ERROR:', error.response?.data || error.message);
    
    res.status(500).json({
      success: false,
      message: error.response?.data?.message || error.message,
      details: error.response?.data,
    });
  }
});
```

---

## Quick Debugging Steps

### 1. Test Backend Directly (Postman/curl)

**Test Acquire:**
```bash
curl -X POST http://67.225.241.58:4004/api/agora/recording/acquire \
  -H "Content-Type: application/json" \
  -d '{
    "channelName": "test123",
    "uid": "12345"
  }'
```

Expected response:
```json
{
  "success": true,
  "resourceId": "long_string_here"
}
```

**Test Start (use resourceId from above):**
```bash
curl -X POST http://67.225.241.58:4004/api/agora/recording/start \
  -H "Content-Type: application/json" \
  -d '{
    "channelName": "test123",
    "uid": "12345",
    "resourceId": "YOUR_RESOURCE_ID_HERE"
  }'
```

Expected response:
```json
{
  "success": true,
  "resourceId": "...",
  "sid": "pXbJNBsw75YMA"
}
```

### 2. Check Backend Console

Look for these specific error patterns:

- **"Resource expired"** → Wait less than 5 min between acquire/start
- **"Channel not found"** → Channel must be live (someone broadcasting)
- **"401 Unauthorized"** → Check Agora credentials
- **"storageConfig missing"** → Add S3 configuration

### 3. Enable Verbose Backend Logging

Add this to your backend start endpoint:
```javascript
console.log('=== START RECORDING DEBUG ===');
console.log('Request:', req.body);
console.log('Agora URL:', agoraUrl);
console.log('Payload:', JSON.stringify(payload, null, 2));
console.log('Auth:', `Basic ${auth.substring(0, 20)}...`);
```

---

## What to Share When Asking for Help

1. **Flutter App Logs** (from diagnostic screen)
2. **Backend Console Output** (copy the errors)
3. **Backend Environment Check**:
   ```bash
   echo $AGORA_APP_ID
   echo $AGORA_CUSTOMER_ID
   # (don't share actual values, just confirm they exist)
   ```
4. **Agora Dashboard** - Check if recording mode is enabled

---

## Next Steps

1. ✅ Open your backend console
2. ✅ Run the diagnostic tool in Flutter app
3. ✅ When "start failed" appears, immediately check backend console
4. ✅ Copy the exact error message from backend
5. ✅ Match it to errors above for solution
