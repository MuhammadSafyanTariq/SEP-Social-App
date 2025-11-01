# Agora Cloud Recording Setup Guide

## Problem
Video recordings are not being saved because Agora doesn't know where to store the recorded files.

## Solution: Configure Cloud Storage

You need to configure one of these storage options on your **BACKEND**:

### Option 1: Amazon S3 (Recommended)
```javascript
// Backend - Agora Recording Start Request
{
  "cname": "channel_name",
  "uid": "user_id",
  "clientRequest": {
    "recordingConfig": {
      "channelType": 1,
      "streamTypes": 2,
      "audioProfile": 1,
      "videoStreamType": 0,
      "maxIdleTime": 30
    },
    "storageConfig": {
      "vendor": 1,  // 1 = Amazon S3
      "region": 0,  // Your S3 region (e.g., 0 = US East)
      "bucket": "your-bucket-name",
      "accessKey": "YOUR_AWS_ACCESS_KEY",
      "secretKey": "YOUR_AWS_SECRET_KEY",
      "fileNamePrefix": ["recordings", "live-streams"]
    }
  }
}
```

### Option 2: Google Cloud Storage
```javascript
"storageConfig": {
  "vendor": 2,  // 2 = Google Cloud
  "region": 0,
  "bucket": "your-gcs-bucket",
  "accessKey": "YOUR_GCS_ACCESS_KEY",
  "secretKey": "YOUR_GCS_SECRET_KEY"
}
```

### Option 3: Microsoft Azure
```javascript
"storageConfig": {
  "vendor": 3,  // 3 = Azure
  "region": 0,
  "bucket": "your-container-name",
  "accessKey": "YOUR_AZURE_ACCOUNT_NAME",
  "secretKey": "YOUR_AZURE_ACCOUNT_KEY"
}
```

### Option 4: Alibaba Cloud OSS
```javascript
"storageConfig": {
  "vendor": 4,  // 4 = Alibaba OSS
  "region": 0,
  "bucket": "your-oss-bucket",
  "accessKey": "YOUR_OSS_ACCESS_KEY",
  "secretKey": "YOUR_OSS_SECRET_KEY"
}
```

## Backend Implementation Steps

### Step 1: Choose Storage Provider
- Amazon S3 is most common and well-documented
- Sign up at: https://aws.amazon.com/s3/

### Step 2: Create S3 Bucket
1. Log into AWS Console
2. Go to S3 service
3. Create new bucket (e.g., "myapp-live-recordings")
4. Enable public read access (or use signed URLs)
5. Set CORS policy if needed

### Step 3: Get Credentials
1. Go to IAM (Identity & Access Management)
2. Create new user for Agora
3. Give S3 permissions
4. Generate Access Key + Secret Key
5. **KEEP THESE SECRET!**

### Step 4: Update Backend Recording API

Update your backend `/api/agora/recording/start` endpoint:

```javascript
// Node.js Backend Example
const axios = require('axios');

app.post('/api/agora/recording/start', async (req, res) => {
  const { channelName, uid, resourceId } = req.body;
  
  try {
    const agoraResponse = await axios.post(
      `https://api.agora.io/v1/apps/${AGORA_APP_ID}/cloud_recording/resourceid/${resourceId}/mode/mix/start`,
      {
        cname: channelName,
        uid: uid,
        clientRequest: {
          token: generateAgoraToken(channelName, uid),
          recordingConfig: {
            channelType: 1,
            streamTypes: 2,  // Audio + Video
            audioProfile: 1,
            videoStreamType: 0,
            maxIdleTime: 30
          },
          // THIS IS THE CRITICAL PART - ADD STORAGE CONFIG
          storageConfig: {
            vendor: 1,  // Amazon S3
            region: 0,  // US East
            bucket: process.env.S3_BUCKET_NAME,
            accessKey: process.env.AWS_ACCESS_KEY,
            secretKey: process.env.AWS_SECRET_KEY,
            fileNamePrefix: ["recordings", channelName]
          }
        }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${Buffer.from(`${AGORA_CUSTOMER_ID}:${AGORA_CUSTOMER_SECRET}`).toString('base64')}`
        }
      }
    );

    res.json({
      success: true,
      resourceId: resourceId,
      sid: agoraResponse.data.sid,
      message: 'Recording started successfully'
    });
  } catch (error) {
    console.error('Start recording error:', error.response?.data);
    res.status(500).json({
      success: false,
      message: error.response?.data?.message || 'Failed to start recording'
    });
  }
});
```

### Step 5: Environment Variables (.env file on backend)
```bash
# Agora Credentials
AGORA_APP_ID=your_app_id
AGORA_APP_CERTIFICATE=your_app_certificate
AGORA_CUSTOMER_ID=your_customer_id
AGORA_CUSTOMER_SECRET=your_customer_secret

# AWS S3 Credentials
AWS_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
S3_BUCKET_NAME=myapp-live-recordings
S3_REGION=us-east-1
```

## Testing the Setup

### 1. Check Backend Logs
When you call `startRecording()`, check your backend logs for:
- ✅ Resource acquired
- ✅ Start request sent with storageConfig
- ✅ Agora returns SID

### 2. Check S3 Bucket
After stopping recording, check your S3 bucket:
- Wait 1-2 minutes for processing
- Files will appear in: `recordings/channel_name/sid/`
- Format: `{sid}_{cname}__{uid}_s_{timestamp}.m3u8`

### 3. Get Video URL
The `stopRecording()` API should return:
```json
{
  "success": true,
  "fileUrl": "https://your-bucket.s3.amazonaws.com/recordings/...",
  "serverResponse": {
    "fileList": [
      {
        "fileName": "recording.mp4",
        "trackType": "audio_and_video"
      }
    ]
  }
}
```

## Alternative: Use Firebase Storage

If you already use Firebase, you can use Firebase Storage instead of S3:

```javascript
// But Firebase is NOT directly supported by Agora
// You'd need to:
// 1. Use S3 for recording
// 2. Transfer files to Firebase via Cloud Function
// 3. Update Flutter app with Firebase URL
```

## Security Best Practices

1. **Never expose credentials in Flutter app**
2. **Use backend proxy for all Agora API calls**
3. **Implement signed URLs for video access**
4. **Set S3 bucket policies to restrict access**
5. **Enable S3 encryption at rest**
6. **Use IAM roles instead of access keys if possible**

## Estimated Costs

### AWS S3 Pricing (Example)
- Storage: $0.023 per GB/month
- PUT requests: $0.005 per 1000 requests
- GET requests: $0.0004 per 1000 requests
- Data transfer out: $0.09 per GB

**Example**: 100 recordings/month, 10 minutes each, ~500MB per recording
- Storage: 50GB × $0.023 = $1.15/month
- Requests: Negligible
- **Total: ~$2-5/month**

## Troubleshooting

### Error: "Invalid storage config"
- Check vendor ID (1=S3, 2=GCS, 3=Azure)
- Verify bucket name is correct
- Ensure access keys have write permissions

### Error: "403 Forbidden"
- Access key doesn't have S3 PutObject permission
- Bucket policy is blocking writes
- Check IAM user permissions

### Error: "No fileUrl returned"
- **This is your current issue!**
- Backend isn't sending storageConfig
- Agora has nowhere to upload the file

### Files not appearing in S3
- Wait 2-3 minutes after stopping recording
- Check Agora dashboard for recording status
- Verify bucket name and region match

## Contact Backend Team

Share this document with your backend developers and ask them to:

1. ✅ Set up AWS S3 bucket (or alternative storage)
2. ✅ Get AWS credentials (Access Key + Secret Key)
3. ✅ Update `/api/agora/recording/start` endpoint with storageConfig
4. ✅ Test recording and verify files appear in S3
5. ✅ Return proper fileUrl in stop response

## Reference Links

- [Agora Cloud Recording RESTful API](https://docs.agora.io/en/cloud-recording/restfulapi/)
- [Storage Configuration](https://docs.agora.io/en/cloud-recording/reference/rest-api/storage-configuration)
- [AWS S3 Setup Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html)
- [Agora Billing](https://docs.agora.io/en/cloud-recording/billing/billing-cloud-recording)
