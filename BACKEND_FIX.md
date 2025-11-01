# Backend Fix: fileNamePrefix Validation Failed

## Error from Backend
```
startRecording error status: 400
startRecording error data: {
  "cname": "test-diagnostic",
  "code": 2,
  "reason": "start: fileNamePrefix validation failed!",
  "uid": "123456"
}
```

## Root Cause
The `fileNamePrefix` in your storageConfig has invalid format or characters.

## Fix Your Backend Code

### Find this file in your backend:
```
backend/routes/agora.js
OR
backend/controllers/agoraController.js
OR
backend/server.js
```

### Locate the `/api/agora/recording/start` endpoint:

```javascript
app.post('/api/agora/recording/start', async (req, res) => {
  const { channelName, uid, resourceId } = req.body;

  try {
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
        storageConfig: {
          vendor: 1,
          region: 0,
          bucket: process.env.S3_BUCKET_NAME,
          accessKey: process.env.AWS_ACCESS_KEY,
          secretKey: process.env.AWS_SECRET_KEY,
          
          // ❌ OLD (CAUSING ERROR):
          // fileNamePrefix: ['recordings', channelName],
          
          // ✅ NEW (FIXED) - Choose ONE option below:
          
          // Option 1: Simple static folder
          fileNamePrefix: ['recordings'],
          
          // Option 2: Clean the channel name first
          // fileNamePrefix: ['recordings', channelName.replace(/[^a-zA-Z0-9_-]/g, '_')],
          
          // Option 3: Add date folder
          // fileNamePrefix: ['recordings', new Date().toISOString().split('T')[0]],
        },
      },
    };

    // ... rest of your code
  }
});
```

## Agora fileNamePrefix Rules

✅ **Allowed Characters:**
- Letters: `a-z`, `A-Z`
- Numbers: `0-9`
- Symbols: `_` (underscore), `-` (hyphen)

❌ **NOT Allowed:**
- Spaces
- Special characters: `!@#$%^&*()`
- Dots: `.`
- Slashes: `/` (except as separator between array elements)

✅ **Valid Examples:**
```javascript
fileNamePrefix: ['recordings']
fileNamePrefix: ['recordings', 'live-streams']
fileNamePrefix: ['recordings', '2025-11-01']
fileNamePrefix: ['recordings', 'channel_123']
```

❌ **Invalid Examples:**
```javascript
fileNamePrefix: ['recordings/videos']        // ❌ slash in string
fileNamePrefix: ['recordings', 'test.mp4']   // ❌ dots not allowed
fileNamePrefix: ['recordings', 'test channel'] // ❌ space not allowed
fileNamePrefix: ['recordings', 'test@123']   // ❌ @ symbol not allowed
```

## Quick Test After Fix

1. Save your backend file
2. Restart backend: `npm start`
3. In Flutter diagnostic tool:
   - Tap "1. Test Acquire"
   - Tap "2. Test Start"
4. Should now succeed! ✅

## If Still Failing

Check your backend console shows:
```javascript
console.log('Payload being sent to Agora:', JSON.stringify(payload, null, 2));
```

Make sure `fileNamePrefix` looks like:
```json
"fileNamePrefix": ["recordings"]
```

NOT like:
```json
"fileNamePrefix": "recordings"  // ❌ must be array
"fileNamePrefix": ["recordings/folder"]  // ❌ no slashes
```
