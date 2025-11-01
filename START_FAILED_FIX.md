# 🚨 Quick Fix: "Start Failed" Error

## What You Told Me
- ✅ Acquire works (got resourceId)
- ❌ Start fails
- Need to check backend logs

---

## **IMMEDIATE ACTION: Check Backend Console**

### Step 1: Open Your Backend Terminal
Your backend should be running at: `http://67.225.241.58:4004`

If you don't have backend terminal open:
```bash
cd /path/to/your/backend
npm start
# or
node server.js
```

### Step 2: Look for Error Message
When you pressed "Test Start" in the diagnostic tool, your backend received the request.

**Look for these lines in backend console:**
```
POST /api/agora/recording/start
Request body: { channelName: "...", uid: "...", resourceId: "..." }
```

**Then you should see one of these errors:**

---

## Common Errors & Quick Fixes

### ❌ Error 1: "Resource expired"
```
Error: The resource is expired
```
**WHY**: resourceId only valid for 5 minutes  
**FIX**: In diagnostic tool, tap Acquire again, then immediately tap Start

---

### ❌ Error 2: "Channel not found" / "Invalid parameter"
```
Error: Invalid parameter, channel not found
```
**WHY**: The channel must be LIVE (someone broadcasting)  
**FIX**: 
1. Start a real live stream first
2. While live, use the diagnostic tool
3. Use the EXACT channelName from your live session

---

### ❌ Error 3: "401 Unauthorized"
```
Error: 401 Unauthorized
```
**WHY**: Backend missing Agora credentials  
**FIX**: Check backend `.env` file has:
```env
AGORA_APP_ID=your_app_id_here
AGORA_CUSTOMER_ID=your_customer_id_here
AGORA_CUSTOMER_SECRET=your_customer_secret_here
```

---

### ❌ Error 4: Backend Not Running
```
Flutter error: Failed to connect, Connection refused
```
**WHY**: Backend server is not running  
**FIX**:
```bash
cd backend
npm install
npm start
```

---

### ❌ Error 5: "Cannot read property..."
```
TypeError: Cannot read property 'CUSTOMER_ID' of undefined
```
**WHY**: Environment variables not loaded  
**FIX**: Create `.env` file in backend root:
```env
AGORA_APP_ID=your_app_id
AGORA_CUSTOMER_ID=your_customer_id
AGORA_CUSTOMER_SECRET=your_secret
```

And in your server code:
```javascript
require('dotenv').config();
```

---

## What to Send Me

Copy and paste from your backend console:

1. The POST request log
2. The error message
3. Any stack trace

Example of what I need to see:
```
POST /api/agora/recording/start
Request body: { channelName: "test123", uid: "12345", resourceId: "..." }
Error: Resource expired
  at axios.post (/backend/routes/agora.js:45)
```

---

## Quick Test: Is Backend Working?

Open a browser and go to:
```
http://67.225.241.58:4004/health
```

If you see a response (any response), backend is running ✅  
If you get "Can't reach this page", backend is NOT running ❌

---

## Most Likely Issue

Based on "start failed", the most common cause is:

### **ResourceId Expired (5 min timeout)**

**Solution**: 
1. In diagnostic tool, tap "1. Test Acquire" 
2. **Immediately** tap "2. Test Start" (within 30 seconds)
3. Don't wait more than 5 minutes between steps

---

## Need More Help?

Share:
1. ✅ Screenshot of diagnostic tool showing the error
2. ✅ Backend console output (copy/paste the error)
3. ✅ Confirm backend is running (yes/no)
4. ✅ Confirm you're using correct channelName (copy/paste it)
