# Quick Start: Agora Cloud Recording Setup

## 🚀 5-Minute Backend Setup

### Step 1: Get Agora Credentials (2 mins)
1. Go to https://console.agora.io/
2. Select your project
3. Navigate to **RESTful API** section
4. Copy:
   - Customer ID: `xxxxxxxxxxxxxxxxxxxxxxxx`
   - Customer Secret: `xxxxxxxxxxxxxxxxxxxxxxxx`

### Step 2: Configure Cloud Storage (2 mins)

#### Option A: AWS S3 (Recommended)
```bash
# Create S3 bucket
aws s3 mb s3://sep-live-recordings

# Create IAM user and get credentials
aws iam create-access-key --user-name agora-recording
```

#### Option B: Use Agora's Cloud Storage
- Simplest option, no setup needed
- Files stored temporarily (48 hours)

### Step 3: Add to Agora Console (1 min)
1. Go to **Cloud Recording** → **Configuration**
2. Add storage credentials:
   - Vendor: AWS S3
   - Region: us-east-1
   - Bucket: sep-live-recordings
   - Access Key: your_key
   - Secret Key: your_secret
3. Click **Test** → Should show ✅

### Step 4: Backend Code (Copy & Paste)

Create `routes/agora-recording.js`:

```javascript
const express = require('express');
const axios = require('axios');
const router = express.Router();

const AGORA_APP_ID = '1d34f3c04fe748049d660e3b23206f7a';
const CUSTOMER_ID = process.env.AGORA_CUSTOMER_ID;
const CUSTOMER_SECRET = process.env.AGORA_CUSTOMER_SECRET;

const auth = Buffer.from(`${CUSTOMER_ID}:${CUSTOMER_SECRET}`).toString('base64');

// 1. Acquire
router.post('/acquire', async (req, res) => {
  try {
    const { channelName, uid } = req.body;
    const response = await axios.post(
      `https://api.agora.io/v1/apps/${AGORA_APP_ID}/cloud_recording/acquire`,
      {
        cname: channelName,
        uid: uid,
        clientRequest: { resourceExpiredHour: 24, scene: 0 }
      },
      { headers: { Authorization: `Basic ${auth}` } }
    );
    res.json({ success: true, resourceId: response.data.resourceId });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 2. Start
router.post('/start', async (req, res) => {
  try {
    const { channelName, uid, resourceId } = req.body;
    const response = await axios.post(
      `https://api.agora.io/v1/apps/${AGORA_APP_ID}/cloud_recording/resourceid/${resourceId}/mode/mix/start`,
      {
        cname: channelName,
        uid: uid,
        clientRequest: {
          recordingConfig: {
            maxIdleTime: 30,
            streamTypes: 2,
            channelType: 0
          },
          recordingFileConfig: {
            avFileType: ["hls", "mp4"]
          },
          storageConfig: {
            vendor: 1, // AWS S3
            region: 0,
            bucket: process.env.S3_BUCKET,
            accessKey: process.env.S3_ACCESS_KEY,
            secretKey: process.env.S3_SECRET_KEY,
            fileNamePrefix: ["recordings", channelName]
          }
        }
      },
      { headers: { Authorization: `Basic ${auth}` } }
    );
    res.json({ success: true, sid: response.data.sid, resourceId: response.data.resourceId });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. Stop
router.post('/stop', async (req, res) => {
  try {
    const { channelName, uid, resourceId, sid } = req.body;
    const response = await axios.post(
      `https://api.agora.io/v1/apps/${AGORA_APP_ID}/cloud_recording/resourceid/${resourceId}/sid/${sid}/mode/mix/stop`,
      {
        cname: channelName,
        uid: uid,
        clientRequest: {}
      },
      { headers: { Authorization: `Basic ${auth}` } }
    );
    
    const fileList = response.data.serverResponse?.fileList || [];
    const fileUrl = fileList.length > 0 
      ? `https://${process.env.S3_BUCKET}.s3.amazonaws.com/${fileList[0].fileName}`
      : null;
    
    res.json({ 
      success: true, 
      fileUrl,
      serverResponse: response.data.serverResponse 
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
```

### Step 5: Add to Your Server

In `server.js` or `app.js`:
```javascript
const agoraRecording = require('./routes/agora-recording');
app.use('/api/agora/recording', agoraRecording);
```

### Step 6: Environment Variables

`.env`:
```env
AGORA_CUSTOMER_ID=your_customer_id_here
AGORA_CUSTOMER_SECRET=your_customer_secret_here
S3_BUCKET=sep-live-recordings
S3_ACCESS_KEY=your_aws_access_key
S3_SECRET_KEY=your_aws_secret_key
```

## ✅ Test It!

```bash
# 1. Start your backend
npm start

# 2. Test in Flutter app
# - Start a live stream as host
# - Click the record button (should turn red)
# - Wait a few seconds
# - Click stop
# - Check your S3 bucket for the recording!
```

## 🎯 Quick Troubleshooting

| Error | Solution |
|-------|----------|
| 401 Unauthorized | Check Customer ID/Secret |
| 404 Not Found | Resource ID expired (only valid 5 min) |
| Storage Error | Verify S3 credentials in Agora Console |
| No recording file | Wait 1-2 minutes after stop |

## 💰 Costs

**Example**: 100 users, 10 min streams
- Agora Recording: $1.49
- AWS S3 Storage: $0.23/month
- Total: **~$2/month**

## 📞 Need Help?

1. Check logs: `console.log(error.response?.data)`
2. Agora Console → Usage → Cloud Recording
3. Support: support@agora.io

---

**That's it! Your cloud recording is now ready! 🎉**
